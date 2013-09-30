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
    <script src="${resource(dir: 'js', file: 'scatterWithFocusChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/examples', file: 'stream_layers.js')}"></script>

    <style>
    .dashboardChart svg {
        height: 500px;
    }

    .dashboardChart {
        margin: 0;
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

    .highlight {
        stroke-width: 7px;
        stroke: #f00;
        fill-opacity: .95 !important;
        stroke-opacity: .95 !important;
    }

    circle {
        -webkit-transition: fill-opacity 250ms linear;
    }

    .selecting circle {
        fill-opacity: .2;
    }

    .selecting circle.selected {
        stroke: #f00;
    }

    .resize path {
        fill: #666;
        fill-opacity: .8;
        stroke: #000;
        stroke-width: 1.5px;
    }

    .axis path, .axis line {
        fill: none;
        stroke: #000;
        shape-rendering: crispEdges;
    }

    .brush .extent {
        fill-opacity: .125;
        shape-rendering: crispEdges;
    }
    </style>
</head>

<body>
<script type="text/javascript">
    var focusChart;
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
        //drawFocusChart();
        drawContextBrush();
        $('#pleaseWaitDialog').modal('hide');
    }
    $(function () {
        $('#pleaseWaitDialog').modal('show');
        $("#compound").change(function () {
            var selectedValues = $('#compound').val();
            drawVisibleCharts();
            drawISAreaMultiChart();
            drawQcFitMultiChart();
            //drawFocusChart();
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

        //var data = filterMetaboliteData(Dashboard, 0, 'All', 'ISArea');
        //data[0].key = "ISArea";
        var selectedMetabolite = $('#compound').val();
        var btData = filterMetaboliteData(Dashboard, selectedMetabolite, chartsSettingArr.ratioChart.sampleType, chartsSettingArr.ratioChart.key, chartsSettingArr.ratioChart.groupBy);
        var qcSampleData = filterMetaboliteData(Dashboard, selectedMetabolite, 'QCsample', chartsSettingArr.ratioChart.key);
        qcSampleData = $.extend(qcSampleData[0], {color: 'black', slope: 1});
        btData = btData.concat(qcSampleData);

        if (focusChart !== undefined) {  // exist update it instead
            var chart = focusChart;
            var minMax = getMinMax(btData);
            chart.forceY([(minMax.minY - minMax.minY * .5 ), (minMax.maxY + minMax.maxY * .5 )]);
            chart.update();
            d3.select('#chart svg')
                    .datum(btData)
                    .transition().duration(500)
                    .call(chart);
        } else {
            nv.addGraph(function () {
                var chart = nv.models.scatterWithFocusChart();

                chart.xAxis
                        .tickFormat(d3.format('d'));
                chart.x2Axis
                        .tickFormat(d3.format('d'));

                chart.yAxis
                        .tickFormat(d3.format(',.02f'));
                chart.y2Axis
                        .tickFormat(d3.format(',.2f'));

                chart.scatter.sizeDomain([100, 100])
                        .sizeRange([100, 100]);

                chart.scatter2.sizeDomain([100, 100])
                        .sizeRange([100, 100]);
                var minMax = getMinMax(btData);
                chart.forceY([(minMax.minY - minMax.minY * .5 ), (minMax.maxY + minMax.maxY * .5 )]);
                d3.select('#chart svg')
                        .datum(btData)
                        .transition().duration(250)
                        .call(chart);

                nv.utils.windowResize(chart.update);
                focusChart = chart;
                return chart;
            });
        }
    }

    /*
     *
     * Let's create the context brush that will let us zoom and pan the chart
     *
     */

    function drawContextBrush() {

        var selectedMetabolite = $('#compound').val();
        var data = Dashboard.metabolites[selectedMetabolite].All.OrderAll;
        var dMin = d3.min(data);
        var dMax = d3.max(data);
        var margin = {top: 0, right: 60, bottom: 20, left: 60},
                width = null,
                height = 50 - margin.top - margin.bottom;

        $('#contextBrush').prepend("<div class='row'>" +
                "<div class='span00 text-center'>" +
                "<p><span class='label label-info'>Select sample order window to zoom-in</span></p>" +
                "</div></div>");


        var svg = d3.select("#contextBrush svg")

        var availableWidth = (width || parseInt(svg.style('width')) || 960) - margin.left - margin.right;

        svg.attr("width", availableWidth + margin.left + margin.right)
                .attr("height", height + margin.top + margin.bottom + 10)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        var x = d3.scale.linear()
                .domain([dMin, dMax])
                .range([0, availableWidth]);

        var y = d3.random.normal(height / 2, height / 8);

        var brush = d3.svg.brush()
                .x(x)
            //.extent([20, 100])
                .on("brushstart", brushstart)
                .on("brush", brushmove)
                .on("brushend", brushend);

        var arc = d3.svg.arc()
                .outerRadius(height / 2)
                .startAngle(0)
                .endAngle(function (d, i) {
                    return i ? -Math.PI : Math.PI;
                });

        var g = svg.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + height + ")")
                .call(d3.svg.axis()
                        .scale(x)
                        .orient("bottom")
                        .tickFormat(d3.format('d'))
                        //.tickSize(10)
                        //.tickPadding(9)
                );

        var axisLabel = g.append('text')
                .attr("class", "nv-axislabel")
                .text("Order")
                .attr('text-anchor', 'middle')
                .attr('y', height)
                .attr('x', availableWidth / 2);

        var circle = svg.append("g").selectAll("circle")
                .data(data)
                .enter().append("circle")
                .attr("r", 3.5)
                .attr("transform", function (d) {
                    //console.log(d);
                    return "translate(" + x(d) + "," + y() + ")";
                });


        var brushg = svg.append("g")
                .attr("class", "brush")
                .call(brush);

        brushg.selectAll(".resize").append("path")
                .attr("transform", "translate(0," + height / 2 + ")")
                .attr("d", arc);

        brushg.selectAll("rect")
                .attr("height", height);

        brushstart();
        brushmove();

        function brushstart() {
            svg.classed("selecting", true);
        }

        function brushmove() {
            var s = brush.extent();
            circle.classed("selected", function (d) {
                return s[0] <= d && d <= s[1];
            });
        }

        function brushend() {
            //svg.classed("selecting", !d3.event.target.empty());
            if (!d3.event.target.empty()) {
                var extent = brush.extent().map(Math.round);
                drawVisibleCharts(extent);
            } else {
                //reset all graphs
                drawVisibleCharts();
            }
        }
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

            <!-- Wait Modal -->
            <div id="pleaseWaitDialog" class="modal hide fade" tabindex="-2" role="dialog"
                 aria-labelledby="pleaseWaitDialog"
                 aria-hidden="true">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                    <h4>Processing...</h4>
                </div>

                <div class="modal-body">
                    <div class="row-fluid">
                        <div class="tab-content">
                            <div class="tab-pane active">
                                <div class="control-group">
                                    <div class="progress progress-striped active">
                                        <div class="bar" style="width: 100%;"></div>
                                    </div>

                                    <p>Please wait! we are loading a large Metabolites / Compound list</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="contextBrush">
                <svg></svg>
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