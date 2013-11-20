<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>QC Report</title>
    <meta name="layout" content="qctool"/>
    <meta http-equiv="X-UA-Compatible" content="IE=10"/>
    <r:require modules="jquery"/>
    <r:require modules="jquery-ui"/>
    <g:javascript library="application"/>
    <r:layoutResources/>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'js/nvd3/src', file: 'nv.d3.css')}" type="text/css">
    <link rel="stylesheet" media="screen" href="${resource(dir: 'js/slickGrid', file: 'slick.grid.css')}"
          type="text/css">
    <link rel="stylesheet" media="screen" href="${resource(dir: 'css', file: 'slick-mzQuality-theme.css')}"
          type="text/css">
    <link rel="stylesheet" media="screen" href="${resource(dir: 'js/slickGrid/controls', file: 'slick.pager.css')}"
          type="text/css">
    <script src="${resource(dir: 'js/slickGrid/lib', file: 'jquery.event.drag-2.2.js')}"></script>
    <script src="${resource(dir: 'js/slickGrid', file: 'slick.core.js')}"></script>
    <script src="${resource(dir: 'js/slickGrid/plugins', file: 'slick.rowselectionmodel.js')}"></script>
    <script src="${resource(dir: 'js/slickGrid', file: 'slick.grid.js')}"></script>
    <script src="${resource(dir: 'js/slickGrid', file: 'slick.dataview.js')}"></script>
    <script src="${resource(dir: 'js/slickGrid/controls', file: 'slick.pager.js')}"></script>
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
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBar.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBarChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'multiBar.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'multiBarChart.js')}"></script>
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

    .tree {
        min-height: 20px;
        padding: 19px;
        margin-bottom: 20px;
        background-color: #fbfbfb;
        border: 1px solid #999;
        -webkit-border-radius: 4px;
        -moz-border-radius: 4px;
        border-radius: 4px;
        -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
        -moz-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
        box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05)
    }

    .tree li {
        list-style-type: none;
        margin: 0;
        padding: 10px 5px 0 5px;
        position: relative
    }

    .tree li::before, .tree li::after {
        content: '';
        left: -20px;
        position: absolute;
        right: auto
    }

    .tree li::before {
        border-left: 1px solid #999;
        bottom: 50px;
        height: 100%;
        top: 0;
        width: 1px
    }

    .tree li::after {
        border-top: 1px solid #999;
        height: 20px;
        top: 25px;
        width: 25px
    }

    .tree li span {
        -moz-border-radius: 5px;
        -webkit-border-radius: 5px;
        border: 1px solid #999;
        border-radius: 5px;
        display: inline-block;
        padding: 3px 8px;
        text-decoration: none
    }

    .tree li.parent_li>span {
        cursor: pointer
    }

    .tree>ul>li::before, .tree>ul>li::after {
        border: 0
    }

    .tree li:last-child::before {
        height: 30px
    }

    .tree li.parent_li>span:hover, .tree li.parent_li>span:hover+ul li span {
        background: #eee;
        border: 1px solid #94a0b4;
        color: #000
    }

    .progress {
        position: relative;
    }

    .bar {
        z-index: 1;
        position: absolute;
    }

    .progress span {
        position: absolute;
        top: 0;
        z-index: 2;
        text-align: center;
        width: 100%;
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
        $.each(filterAnalyte(Dashboard, 'Metabolite'), function (i, comp) {
            comboList.append($("<option></option>")
                    .attr("value", i)
                    .text(comp.Name));
        });
        //initInfoTable(Dashboard.Table);
        drawContextBrush();
        //drawLegend();
        drawVisibleCharts();
        //drawISAreaMultiChart();
        //drawQcFitMultiChart();
        //drawFocusChart();
        $('#pleaseWaitDialog').modal('hide');
    }

    function percentCompleteBar(row, cell, value, columnDef, dataContext) {
        if (value == null || value === "") {
            return "";
        }
        var bar, newVal = Math.round(value * 100);
        if (newVal < 30) {
            bar = "bar-danger";
        } else if (newVal < 70) {
            bar = "bar-warning";
        } else {
            bar = "bar-success";
        }
        return "<div class='progress'>" +
                "<div class='" + bar + " bar' style='width:" + newVal + "%;'></div>" +
                "<span>" + value + "</span>" +
                "</div>"
    }

    function initInfoTable(tableData) {
        var dataView;
        var grid;
        var data = [];
        var columns = [
            {id: "sel", name: "#", field: "num", behavior: "select", cssClass: "cell-selection", width: 40, resizable: false, sortable: true, selectable: false },
            {id: "analyte", name: "Analyte", field: "analyte", sortable: true, width: 120, minWidth: 120, cssClass: "cell-title"},
            {id: "RSDRatioQC", name: "RSDRatioQC", field: "RSDRatioQC", width: 100, sortable: true, formatter: percentCompleteBar },
            {id: "RSDRatioreps", name: "RSDRatioreps", field: "RSDRatioreps", width: 100, sortable: true, formatter: percentCompleteBar}
        ];

        var options = {
            editable: true,
            enableAddRow: false,
            enableCellNavigation: true,
            asyncEditorLoading: true,
            forceFitColumns: false,
            topPanelHeight: 25
        };

        var sortcol = "title";
        var sortdir = 1;
        var percentCompleteThreshold = 0;
        var searchString = "";

        function myFilter(item, args) {
            return item["RSDRatioQC"] >= args;
        }

        function DataItem(i) {
            this.num = i;
            this.id = "id_" + i;
            this.RSDRatioQC = tableData.RSDRatioQC[i];
            this.RSDRatioreps = tableData.RSDRatioreps[i];
            this.analyte = tableData.Analyte[i];

        }

        // prepare the data
        $.each(tableData.Analyte, function (i, key) {
            data[i] = new DataItem(i);
        });


        dataView = new Slick.Data.DataView({ inlineFilters: true });
        grid = new Slick.Grid("#infoTable", dataView, columns, options);
        grid.setSelectionModel(new Slick.RowSelectionModel());
        var pager = new Slick.Controls.Pager(dataView, grid, $("#pager"));

        // wire up model events to drive the grid
        dataView.onRowCountChanged.subscribe(function (e, args) {
            grid.updateRowCount();
            grid.render();
        });

        dataView.onRowsChanged.subscribe(function (e, args) {
            grid.invalidateRows(args.rows);
            grid.render();
        });

        function filterAndUpdate() {
            var isNarrowing = percentCompleteThreshold > prevPercentCompleteThreshold;
            var isExpanding = percentCompleteThreshold < prevPercentCompleteThreshold;
            var renderedRange = grid.getRenderedRange();

            dataView.setFilterArgs(percentCompleteThreshold);
            dataView.setRefreshHints({
                ignoreDiffsBefore: renderedRange.top,
                ignoreDiffsAfter: renderedRange.bottom + 1,
                isFilterNarrowing: isNarrowing,
                isFilterExpanding: isExpanding
            });
            dataView.refresh();

            prevPercentCompleteThreshold = percentCompleteThreshold;
        }


        // initialize the model after all the events have been hooked up
        dataView.beginUpdate();
        dataView.setItems(data);
        dataView.setFilter(myFilter);
        dataView.setFilterArgs(0);
        dataView.endUpdate();
    }

    function updateSettingsDlg() {
        var ignoreList = ['Info', 'Table', 'Dictionary'];
        var contentDiv = $('#settingform div');
        contentDiv.empty();
        var treeRootHtml = $('<div/>', {
            "class": "tree",
            title: 'Dashboard Settings',
            id: "DashboardGraphSettings"
        }).appendTo(contentDiv);
        var trunk = $("<ul/>");
        $.each(Object.keys(Dashboard), function (i, key) {
            if ((ignoreList.indexOf(key) != -1)) return;
            var firstParent = $("<li><span><i class='icon-minus-sign icon-calendar'></i> " + key + "</span></li>");
            var secondParent = $("<ul/>");
            var obj = eval('Dashboard.' + key) instanceof Array ? eval('Dashboard.' + key)[0] : eval('Dashboard.' + key);
            $.each(Object.keys(obj), function (j, subkey) {
                secondParent.append("<li class='hide'><span class='badge badge-success'> " + subkey + " <input type='checkbox' id='Dashboard.'" + key + "." + subkey + "'></span></li>");

            });
            firstParent.append(secondParent);
            trunk.append(firstParent);
        });
        treeRootHtml.append(trunk);
        $(function () {
            $('.tree li:has(ul)').addClass('parent_li').find(' > span').attr('title', 'Collapse this branch');
            $('.tree li.parent_li > span').on('click', function (e) {
                var children = $(this).parent('li.parent_li').find(' > ul > li');
                if (children.is(":visible")) {
                    children.hide('fast');
                    $(this).attr('title', 'Expand this branch').find(' > i').addClass('icon-plus-sign').removeClass('icon-minus-sign');
                } else {
                    children.show('fast');
                    $(this).attr('title', 'Collapse this branch').find(' > i').addClass('icon-minus-sign').removeClass('icon-plus-sign');
                }
                e.stopPropagation();
            });
        });
    }

    $(function () {
        $('#pleaseWaitDialog').modal('show');
        $("#compound").change(function () {
            var selectedValues = $('#compound').val();
            drawVisibleCharts();
            //drawISAreaMultiChart();
            //drawQcFitMultiChart();
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

            <div id="infoTable" class="table table-hover" style="width:400px; height:200px;"></div>

            <div id="pager" style="width:400px;height:20px;"></div>

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

            %{--<div class="navbar affix-top" data-spy="affix" data-offset-top="250">--}%
                %{--<div class="navbar-inner">--}%
                    %{--<div class="container">--}%
                        %{--<div><svg id="mainLegend"></svg></div>--}%
                    %{--</div>--}%
                %{--</div>--}%
            %{--</div>--}%

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