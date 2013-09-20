<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>QC Report</title>
    <meta name="layout" content="qctool"/>
    <meta http-equiv="X-UA-Compatible" content="IE=10"/>
    <r:require modules="jquery"/>
    <g:javascript library="application"/>
    <r:layoutResources/>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'js/nvd3/src', file: 'nv.d3.css')}" type="text/css">
    <script src="${resource(dir: 'js/nvd3/lib', file: 'd3.v3.js')}"></script>
    <script src="${resource(dir: 'js/nvd3', file: 'nv.d3.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'tooltip.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'utils.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'legend.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'axis.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'distribution.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatter.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'line.js')}"></script>
    <script src="${resource(dir: 'js', file: 'modifyMultiChart.js')}"></script>
    <script src="${resource(dir: 'js', file: 'qualityControl.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterPlusLineChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/lib', file: 'crossfilter.min.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'lineWithFocusChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/examples', file: 'stream_layers.js')}"></script>

    <style>
    .dashboardChart svg {
        height: 500px;
    }

    .dashboardChart {
        margin: 0;
    }

    svg {
        height: 500px;
    }

    #ISAreaMultiChart svg {
        height: 500px;
        margin: 10px;
        min-width: 100px;
        min-height: 100px;
    }

    #QCfitMultiChart svg {
        height: 500px;
        margin: 10px;
        min-width: 100px;
        min-height: 100px;
    }
    </style>
</head>

<body>
<script type="text/javascript">
    <g:remoteFunction controller="project" id="${project.id}" action="getDashboardData" onSuccess="callbackGrid(data)"></g:remoteFunction>

    /*
     var url = "https://dl.dropboxusercontent.com/s/afaxphho9v2rrhf/Dashboard.json";
     d3.json(url, function (error, jsonData) {
     if (error) return console.warn(error);
     else {
     callbackGrid(jsonData);
     }
     });
     */

    function callbackGrid(matlabX) {
        jsonObj = matlabX;
        if (jsonObj.Dashboard) {
            jsonObj = jsonObj.Dashboard;
        }
        Dashboard = jsonObj;

        var comboList = $("#compound");
        $.each(Dashboard.metabolites, function (i, comp) {
            comboList.append($("<option></option>")
                    .attr("value", i)
                    .text(comp.Name));
        });

        drawVisibleCharts();
        drawISAreaMultiChart();
        drawQcFitMultiChart();
        drawFocusChart();
    }
    $(function () {
        $("#compound").change(function () {
            var selectedValues = $('#compound').val();
            drawVisibleCharts();
            drawISAreaMultiChart();
            drawQcFitMultiChart();
        });
    });

    $(function () {
        $("#settingform").submit(function (event) {
            event.preventDefault();
            $("#settingform input").each(function (idx, checkboxs) {
                switch (checkboxs.id) {
                    case "showArea" :
                        chartsSettingArr.areaChart.visible = checkboxs.checked ? true : false;
                        break;
                    case "showRT":
                        chartsSettingArr.rtChart.visible = checkboxs.checked ? true : false;
                        break;
                    case "showRatioUnc" :
                        chartsSettingArr.ratioChart.visible = checkboxs.checked ? true : false;
                        break;
                    case "showRatioQ" :
                        chartsSettingArr.ratioQChart.visible = checkboxs.checked ? true : false;
                        break;
                    default :
                        //reset default here
                        break;
                }
            });
            $('#advancedSettings').modal('hide');
            drawVisibleCharts();
        })
    });

    function drawFocusChart() {
        nv.addGraph(function () {
            var chart = nv.models.lineWithFocusChart();

            chart.xAxis
                    .tickFormat(d3.format(',f'));
            chart.x2Axis
                    .tickFormat(d3.format(',f'));

            chart.yAxis
                    .tickFormat(d3.format(',.2f'));
            chart.y2Axis
                    .tickFormat(d3.format(',.2f'));

            var dimension = testCrossfilterData().data;
            /*

             var data = normalizeData(dimension.top(Infinity),
             [
             {
             name: 'Stream #1',
             key: 'stream1'
             },
             {
             name: 'Stream #2',
             key: 'stream2'
             },
             {
             name: 'Stream #3',
             key: 'stream3'
             }
             ], 'x');
             */
            var data = filterMetaboliteData(Dashboard, 0, 'All', 'ISArea');
            data[0].key = "ISArea";
            d3.select('#chart svg')
                    .datum(data)
                    .transition().duration(500)
                    .call(chart);

            nv.utils.windowResize(chart.update);

            return chart;
        });
    }

    extend = function (destination, source) {
        for (var property in source) {
            if (property in destination) {
                if (typeof source[property] === "object" &&
                        typeof destination[property] === "object") {
                    destination[property] = extend(destination[property], source[property]);
                } else {
                    continue;
                }
            } else {
                destination[property] = source[property];
            }
            ;
        }
        return destination;
    };

    function normalizeData(data, series, xAxis) {
        var sort = crossfilter.quicksort.by(function (d) {
            return d[xAxis];
        });
        var sorted = sort(data, 0, data.length);

        var result = [];

        series.forEach(function (serie, index) {
            result.push({key: serie.name, values: [], color: serie.color});
        });

        data.forEach(function (data, dataIndex) {
            series.forEach(function (serie, serieIndex) {
                result[serieIndex].values.push({x: data[xAxis], y: data[serie.key]});
            });
        });

        return result;
    }
    ;

    function testCrossfilterData() {
        var data = crossfilter(testData());

        try {
            data.data = data.dimension(function (d) {
                return d.y;
            });
        } catch (e) {
            console.log(e.stack);
        }

        return data;
    }

    function testData() {

        var data1 = [];
        var data2 = [];
        var data3 = [];

        stream_layers(3, 128, .1).map(function (layer, index) {
            layer.forEach(function (item, i) {
                var object = { x: item.x };
                object['stream' + (index + 1)] = item.y;
                eval('data' + (index + 1)).push(object);
            });
        });

        var data = extend(data1, data2);
        var result = extend(data, data3);

        return result;
    }

</script>

<div class="tabbable tabs-left">
    <ul class="nav nav-tabs ulfloatleft liremovefloat">
        <li class="active"><a href="#home" data-toggle="tab">Dashboard</a></li>
        <li><a href="#profile" data-toggle="tab">ISTD and RT outliers</a></li>
        <li><a href="#messages" data-toggle="tab">PCA outlining points</a></li>
        <li><a href="#settings" data-toggle="tab">Linearity</a></li>
        <li><a href="#contact" data-toggle="tab">Calibrant Correction</a></li>
        <li><a href="#contact1" data-toggle="tab">Blanks Effects</a></li>
    </ul>

    <div class="tab-content">
        <div class="tab-pane fade in active" id="home">
            <table>
                <tr>
                    <td style="padding: 5px;" align="right" valign="top" nowrap>Selected Compound :</td>
                    <td>
                        <select class="dropdown" name="compound" id="compound"/>
                    </td>
                </tr>
                <tr>
                    <td><g:hiddenField name="jobId" value="${jobId}"/></td>
                    <td></td>
                </tr>
            </table>
            <a href="#advancedSettings" role="button" data-toggle="modal"
               class="btn btn-warning pull-right">Settings</a>

            <!-- Advanced Setting Modal -->
            <div id="advancedSettings" class="modal hide fade" tabindex="-1" role="dialog"
                 aria-labelledby="advancedSettings"
                 aria-hidden="true">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                    <ul class="nav nav-pills pull-right">
                        <li class="active">
                            <a href="#screenSetting" data-toggle="pill">Screen settings</a>
                        </li>
                    </ul>
                    <h4>Multiple Graphs on the same screen</h4>
                </div>

                <div class="modal-body">
                    <div class="row-fluid">
                        <div class="tab-content">
                            <div class="tab-pane active" id="screenSetting">
                                <div class="control-group">
                                    <form id="settingform" action="#" title="">
                                        <fieldset>
                                            <div class="controls controls-row">
                                                <label class="checkbox">
                                                    <input type="checkbox" id="showArea" checked> Area
                                                </label>
                                                <label class="checkbox">
                                                    <input type="checkbox" id="showRT" checked> Retention Time
                                                </label>
                                                <label class="checkbox">
                                                    <input type="checkbox" id="showRatioUnc"
                                                           checked> Ratio (uncorrected)
                                                </label>
                                                <label class="checkbox">
                                                    <input type="checkbox" id="showRatioQ" checked> Ratio (QC corrected)
                                                </label>
                                            </div>
                                            <button type="submit" class="btn btn-warning">Save</button>
                                        </fieldset>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="chart">
                <svg style="height: 500px;"></svg>
            </div>

            <div id="DashboardChartArea"></div>

            <div id="ISAreaMultiChart">
                <svg></svg>
            </div>

            <div id="QCfitMultiChart">
                <svg></svg>
            </div>

        </div>

        <div class="tab-pane fade" id="profile">
            <h3>ISTD and RT outliers</h3>

        </div>

        <div class="tab-pane fade" id="messages">
            <h3>PCA outlining points</h3>

        </div>

        <div class="tab-pane fade" id="settings">
            <h3>Linearity</h3>

        </div>

        <div class="tab-pane fade" id="contact">
            <h3>Calibrant Correction</h3>

        </div>

        <div class="tab-pane fade" id="contact1">
            <h3>Blanks Effects</h3>

        </div>
    </div>
</div>
<hr/>
</body>
</html>