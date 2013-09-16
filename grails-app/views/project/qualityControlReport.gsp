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
    <script src="${resource(dir: 'js/nvd3/lib', file: 'd3.v2.js')}"></script>
    <script src="${resource(dir: 'js/nvd3', file: 'nv.d3.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'tooltip.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'utils.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'legend.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'axis.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'distribution.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatter.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'line.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'modifyMultiChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterPlusLineChart.js')}"></script>
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

    #chart1 svg {
        height: 500px;
        margin: 10px;
        min-width: 100px;
        min-height: 100px;
    }
    </style>
</head>

<body>
<script type="text/javascript">
    var shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square'], random = d3.random.normal();
    var Dashboard;
    var jsonObj;
    var qcSamplesRatioArr = [], qcSamplesAreaArr = [];
    var ratioChart, ratioQChart, areaChart, rtChart;

    var chartsSettingArr = {   // charts array and its default values
        ratioChart: {
            key: 'Ratio',
            sampleType: 'Sample',
            groupBy: 'batch',
            xAxisLabel: 'Order',
            yAxisLabel: 'Ratio (uncorrected)',
            visible: true,
            chartObject: nv.models.scatterChart()
        },
        ratioQChart: {
            key: 'RatioQ',
            sampleType: 'Sample',
            groupBy: 'batch',
            xAxisLabel: 'Order',
            yAxisLabel: 'Ratio (QC corrected)',
            visible: true,
            chartObject: nv.models.scatterChart()
        },
        areaChart: {
            key: 'Area',
            sampleType: 'Sample',
            groupBy: 'batch',
            xAxisLabel: 'Order',
            yAxisLabel: 'Area',
            visible: true,
            chartObject: nv.models.scatterChart()
        },
        rtChart: {
            key: 'RT',
            sampleType: 'Sample',
            groupBy: 'batch',
            xAxisLabel: 'Order',
            yAxisLabel: 'Retention Time',
            visible: true,
            chartObject: nv.models.scatterChart()
        }
    };

    <g:remoteFunction controller="project" id="${project.id}" action="getDashboardData" onSuccess="callbackGrid(data)"></g:remoteFunction>
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
        drawMultiChart();
    }

    $(function () {
        $("#compound").change(function () {
            var selectedValues = $('#compound').val();
            drawVisibleCharts();
            drawMultiChart();
        });
    });

    function tooltipContent(key, x, y, e, graph) {
        var selectedValues = $('#compound').val();
        //console.log(eval('Dashboard.metabolites['+selectedValues+'].'+key));
        return '<h3>' + key + '</h3>' +
                '<p>Batch :' + e.point.batch + ' Sample :' + e.point.sampLab + '</p>' +
                '<p>' + y + ' on ' + x + '</p>';

    }

    function getMinMax(data) {
        var minY, maxY, minX, maxX;
        data.forEach(function (d) {
            minY = maxY = d.values[0].y;
            minX = maxX = d.values[0].x;
            d.values.forEach(function (s) {
                minX = Math.min(minX, s.x);
                maxX = Math.max(maxX, s.x);
                minY = Math.min(minY, s.y);
                maxY = Math.max(maxY, s.y);
            });
        });
        return { minX: minX, minY: minY, maxX: maxX, maxY: maxY}
    }

    function filterMetaboliteData(dashboard, metIdx, sampleType, response, groupBy) { //# groups,# points per group
        var data = [];
        var metabolite = dashboard.metabolites[metIdx];
        /*var sampleTypeObj;
         switch (sampleType) {
         case 'Sample' :
         sampleTypeObj = metabolite.Sample;
         break;
         case 'QCsample':
         sampleTypeObj = metabolite.QCsample;
         break;
         case 'Cal' :
         sampleTypeObj = metabolite.Cal;
         break;
         }*/

        var sampleTypeObj = eval('metabolite.' + sampleType);
        if (!sampleTypeObj) {
            console.error("SampleType:" + sampleType + " does not exist");
            console.error("Object does not have property name:", sampleType);
            return
        }

        /*var responseVals = [];
         switch (response) {
         case 'Area' :
         responseVals = sampleTypeObj.Area;
         break;
         case 'RT':
         responseVals = sampleTypeObj.RT;
         break;
         case 'Ratio' :
         responseVals = sampleTypeObj.Ratio;
         break;
         case 'RatioQ' :
         responseVals = sampleTypeObj.RatioQ;
         break;
         }*/

        var responseVals = eval('sampleTypeObj.' + response);
        if (!responseVals) {
            console.error("No such response type exist:", response);
            return
        }
        /*
         * check if we need to make groups
         * some time you don't need to group for example QCSample are not grouped by batches
         */
        if (groupBy) {
            // make obj according to group
            switch (groupBy) {
                case 'batch' :
                    var batchArr = sampleTypeObj.batch.map(function (x) {    //convert string values to int
                        return parseInt(x);
                    });

                    for (i = 0; i < d3.max(batchArr); i++) {    // fill the batch number i.e. batch 1, batch 2 etc
                        data.push({
                            key: "Batch " + (i + 1),
                            values: []
                        });
                        /* fill obj
                         *  Assume values are filled as sorted group#
                         */
                        for (j = 0; j < sampleTypeObj.OrderAll.length; j++) {
                            var b = parseInt(sampleTypeObj.batch[j]);
                            if ((b - 1 ) != i) continue;
                            var yVal = responseVals[j];
                            data[i].values.push({
                                        x: sampleTypeObj.OrderAll[j],
                                        y: yVal, sampLab: sampleTypeObj.samplabs[j],
                                        batch: b
                                    }
                            )
                            ;
                        }
                    }
                    break;
            }
        }
        else { // single obj will be return
            // make response obj according
            if (responseVals && sampleTypeObj) {
                data.push({
                    key: sampleType,
                    values: []
                });
                /*
                 console.log("Mean->", d3.mean(responseVals));
                 console.log("Median->", d3.median(responseVals));
                 var v = variance(responseVals);
                 var sd = Math.sqrt(v);
                 console.log("Standard Deviation->", sd);
                 */
                $.each(responseVals, function (idx, val) {
                    data[0].values.push({
                        x: sampleTypeObj.OrderAll[idx],
                        y: val,
                        sampLab: sampleTypeObj.samplabs[idx],
                        batch: sampleTypeObj.batch[idx]
                    })
                });
            }
        }
        return data;
    }
    function variance(x) {
        var n = x.length;
        if (n < 1) return NaN;
        if (n === 1) return 0;
        var mean = d3.mean(x),
                i = -1,
                s = 0;
        while (++i < n) {
            var v = x[i] - mean;
            s += v * v;
        }
        return s / (n - 1);
    }

    function removeGraph(setting) {
        var chartId = setting.key + 'Graph';
        if ($('#' + chartId).length) {
            $('#' + chartId).remove();
        }  //else does not exist

    }

    function updateGraph(data, setting) {
        var chartId = setting.key + 'Graph';
        if ($('#' + chartId).length) {
            var minMax = getMinMax(data);
            var chart = setting.chartObject;
            if (chart) {
                chart.forceY([(minMax.minY - minMax.minY * .1 ), (minMax.maxY + minMax.maxY * .1 )]);
                chart.update();
                d3.select('#' + chartId + ' svg')
                        .datum(data)
                        .transition().duration(500)
                        .call(chart);
            } else {
                console.error("UpdateError:Chart object does not exist ");
            }
        } else {
            // does not exist creat it instead
        }

    }

    function drawGraph(data, setting) {
        var chartId = setting.key + 'Graph';
        if ($('#' + chartId).length) {  // exist update it instead
            updateGraph(data, setting);

        } else {
            $('<div/>', {
                "class": "dashboardChart",
                title: setting.key + 'Graph',
                id: chartId
            }).appendTo('#DashboardChartArea').prepend('<svg/>');

            $('#' + chartId).prepend("<div class='row'>" +
                    "<div class='span10 text-center'>" +
                    "<p><span class='label label-important'>" + setting.key + " Chart</span></p>" +
                    "</div></div>");

            var gp = function () {
                var minMax = getMinMax(data);
                var chart = setting.chartObject
                        .showDistX(true)
                        .showDistY(true)
                        .useVoronoi(true)
                        .color(d3.scale.category10().range());

                chart.xAxis
                        .tickFormat(d3.format('d'))
                        .axisLabel(setting.xAxisLabel);

                chart.yAxis
                        .tickFormat(d3.format('.02f'))
                        .axisLabel(setting.yAxisLabel);

                chart.forceY([(minMax.minY - minMax.minY * .1 ), (minMax.maxY + minMax.maxY * .1 )]);
                //chart.forceX([0, jsonObj.OrderAll.length]);
                chart.sizeDomain([100, 100])
                        .sizeRange([100, 100]);
                chart.tooltipContent(tooltipContent);

                d3.select('#' + chartId + ' svg')
                        .datum(data)
                        .transition().duration(500)
                        .call(chart);
                nv.utils.windowResize(chart.update);

                chart.dispatch.on('stateChange', function (e) {
                    console.log('New State:', JSON.stringify(e));
                });
                chart.scatter.dispatch.on('elementClick', function (_) {
                    var g = d3.select(d3.event.target);
                    //g.select('.nv-point-paths').style('pointer-events', 'all');
                    console.log(d3.event.target, d3.select(d3.event.target));
                    //point = d3.select(d3.event.target);
                    d3.select(d3.event.target).classed("hover", true);
                    //console.log('Clicked Element:', JSON.stringify(_));
                });
                setting.chartObject = chart;
                return chart;
            }
            nv.addGraph(gp);
        }
    }

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

    function drawVisibleCharts() {
        $.each(Object.keys(chartsSettingArr), function (idx, ch) {
            var chartSetting = eval('chartsSettingArr.' + ch);
            var selectedMetabolite = $('#compound').val();
            if (chartSetting.visible) {
                var btData = filterMetaboliteData(Dashboard, selectedMetabolite, chartSetting.sampleType, chartSetting.key, chartSetting.groupBy);
                var qcSampleData = filterMetaboliteData(Dashboard, selectedMetabolite, 'QCsample', 'Ratio');
                qcSampleData = $.extend(qcSampleData[0], {color: 'black', slope: 1});
                btData = btData.concat(qcSampleData);
                drawGraph(btData, chartSetting);
            } else {
                // remove it from dom element
                removeGraph(chartSetting);
            }

        });

    }
    var points = 10 + Math.random() * 100;
    var testdata = stream_layers(7, points, .1).map(function (data, i) {
        return {
            key: 'Stream' + i,
            values: data.map(function (a) {
                a.y = a.y * (i <= 1 ? -1 : 1);
                return a
            })
        };
    });

    testdata[0].type = "line"
    testdata[0].yAxis = 1
    testdata[1].type = "area"
    testdata[1].yAxis = 1
    testdata[2].type = "line"
    testdata[2].yAxis = 1
    testdata[3].type = "scatter"
    testdata[3].yAxis = 2
    testdata[4].type = "scatter"
    testdata[4].yAxis = 2
    testdata[5].type = "bar"
    testdata[5].yAxis = 2
    testdata[6].type = "scatter"
    testdata[6].yAxis = 1

    $.each(testdata, function (i, obj) {
        if (obj.type === "scatter") {
            for (var j = 0; j < points; j++) {
                obj.values[j] = {
                    x: random(),
                    y: random(),
                    size: 1,
                    shape: shapes[j % 6]
                };
            }
        } else if (obj.type === "bar") {
            // obj = $.extend(obj, {color: 'black'});
        }
    });

    function drawMultiChart() {
        var selectedMetabolite = $('#compound').val();
        var btData = filterMetaboliteData(Dashboard, selectedMetabolite, chartsSettingArr.areaChart.sampleType, chartsSettingArr.areaChart.key, chartsSettingArr.areaChart.groupBy);
        var qcSampleData = filterMetaboliteData(Dashboard, selectedMetabolite, 'QCsample', 'Ratio');
        var isAreaData = filterMetaboliteData(Dashboard, selectedMetabolite, 'All', 'ISArea');
        isAreaData[0].key = "ISArea";
        $.each(btData, function (i, d) {
            d = $.extend(d, {type: 'scatter', yAxis: 1});
        });
        isAreaData = $.extend(isAreaData[0], {type: 'line', yAxis: 2});
        qcSampleData = $.extend(qcSampleData[0], {color: 'black', type: 'scatter', yAxis: 1});
        btData = btData.concat(qcSampleData);
        testdata = btData.concat(isAreaData);

        nv.addGraph(function () {
            var chart = nv.models.multiChart()
                    .margin({top: 30, right: 60, bottom: 50, left: 70})
                    .color(d3.scale.category10().range());

            chart.xAxis
                    .tickFormat(d3.format('d'))
                    .axisLabel("Order");

            chart.yAxis1
                    .tickFormat(d3.format('.02f'))
                    .axisLabel("Area");

            chart.yAxis2
                    .tickFormat(d3.format('.02f'))
                    .axisLabel("ISArea");


            chart.scatter1.sizeDomain([100, 100])
                    .sizeRange([100, 100]);

            chart.scatter2.sizeDomain([100, 100])
                    .sizeRange([100, 100]);

            chart.tooltipContent(tooltipContent);


            d3.select('#chart1 svg')
                    .datum(testdata)
                    .transition().duration(500).call(chart);
            return chart;
        });
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

            <div id="DashboardChartArea"></div>

            <div id="chart1">
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