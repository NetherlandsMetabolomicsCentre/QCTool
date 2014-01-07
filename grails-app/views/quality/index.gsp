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
    <script src="${resource(dir: 'js/slickGrid/lib', file: 'jquery.event.drag-2.2.js')}"></script>
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
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'lineWithFocusChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBar.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBarChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'multiBar.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'multiBarChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'multiBarTimeSeries.js')}"></script>
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
    <g:if test="${session.qualityJson}">
    $(function () {
        $('#pleaseWaitDialog').modal('show')
    });
    <g:remoteFunction controller="quality" action="remoteData" onSuccess="callbackGrid(data)"></g:remoteFunction>
    </g:if>

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
        reportSettingsDlg();
        drawContextBrush();
        //drawLegend();
        drawVisibleCharts();
        $('#pleaseWaitDialog').modal('hide');
    }

    function reportSettingsDlg() {
        var contentDiv = $('#settingform div');
        contentDiv.empty();
        //contentDiv.addClass("controls controls-row")
        var groupContainer = $('<div class="container"></div>')
                .appendTo(contentDiv);
        var groupRow = $('<label for="groupBy" class="control-label input-group">Group By</label>')
                .appendTo(groupContainer)
        var groupDiv = $('<div/>', {
            class: 'btn-group',
            'data-toggle': 'buttons-radio',
            title: 'GroupBy Settings',
            id: 'GroupBySettings'
        }).appendTo(groupRow);
        var row;
        $.each(Dashboard.PlotInfo.Group, function (idx, group) {
            var radioBtn = $('<input type="radio" name="groupBy" value="' + idx + '">')
            radioBtn.prop('checked', idx == 0 ? true : false)
            if (idx % 4 == 0)
                row = $('<div class="row-fluid"></div>').appendTo(groupDiv)
            row.append($('<label class="btn btn-default">' + group + '</label>').append(radioBtn))
        })

        $.each(Dashboard.PlotInfo.Plots, function (idx, chartSetting) {
            var chartId = 'show' + chartSetting.Title.hashCode();
            contentDiv.append($('<label class="checkbox"><input type="checkbox" id="' + chartId + '" checked> ' + chartSetting.Title + '</label>'))
        })
    }
    // register events
    $(function () {
        $("#compound").change(function () {
            drawVisibleCharts()
        });

        $("#settingform").submit(function (event) {
            event.preventDefault();
            var checkboxs = $("#settingform input[type='checkbox']")
            $.each(Dashboard.PlotInfo.Plots, function (idx, chartSetting) {
                var chartId = 'show' + chartSetting.Title.hashCode();
                checkboxs.each(function (idx, checkbox) {
                    if (checkbox.id == chartId) {
                        chartSetting.visible = checkbox.checked ? true : false;
                    }
                });
            })
            $('#advancedSettings').modal('hide');
            drawVisibleCharts();
        });

        $('#htmlMetaboliteTable table').on('click', 'tbody tr', function(event) {
            $(this).addClass('error').siblings().removeClass('error');
        });
    });

    function tableRowClicked(name) {
        $("#compound option").filter(function () {
            return $(this).text() == name;
        }).prop('selected', true);
        drawVisibleCharts();
    }
</script>

<g:if test="${session.qualityJson}">
    <g:link action="index" params="['renewJson': true]" role="button"
            class="btn btn-primary pull-right">Upload new file</g:link>
    <a href="#advancedSettings" role="button" data-toggle="modal"
       class="btn btn-warning pull-right">Settings</a>
    <H4>Quality Control Report</H4>

    <div class="tab-pane fade in active" id="home">
        <table>
            <tr>
                <td style="padding: 5px;" align="right" valign="top" nowrap>Selected Compound :</td>
                <td>
                    <select class="dropdown" name="compound" id="compound"/>
                </td>
            </tr>
        </table>

        <div id="htmlMetaboliteTable" style="overflow: auto; height:250px;">
            <report:metaboliteTable qcData="${session.qualityJson.toString(false)}"/>
        </div>
        <!--
                <div id="infoTable" class="table table-hover" style="width:400px; height:200px;"></div>
                <div id="pager" style="width:400px;height:20px;"></div>
      -->
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
    </div>
</g:if>
<g:else>
    <div style="width: 450px; border: thin solid #cdcdcd; padding: 10px;">
        <strong>Upload Matlab Generated JSON File here!</strong>
        <g:uploadForm controller="quality" action="index" name="qualityFileUpload">
            <input class="btn-small" type="file" name="qualityFile" accept="text/x-json,application/json,text/plain"/>
            <g:submitButton class="btn" name="submit" value="submit"/>
        </g:uploadForm>
    </div>
</g:else>

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
                                <button type="submit" class="btn btn-warning">Update Graphs</button>
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
<hr/>
</body>
</html>