<%@ page import="grails.converters.JSON" contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Graph View</title>
    <meta name="layout" content="qctool"/>
    <r:require modules="jquery"/>
    <g:javascript library="application"/>
    <r:layoutResources/>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'js/nvd3/src', file: 'nv.d3.css')}" type="text/css">
    <style>

    body {
        overflow-y: scroll;
    }

    text {
        font: 12px sans-serif;
    }

    svg {
        display: block;
    }

    #chart1 svg {
        height: 500px;
        min-width: 100px;
        min-height: 100px;
    }
    </style>
</head>

<body>

<div id="chart1">
    <svg></svg>
</div>
<g:form name="createSetting" action="addCorrectionSetting" controller="project" id="${project?.id}">

    <table>
        <tr>
            <td style="padding: 5px;" align="right" valign="top" nowrap>Blank Correction (in %):</td>
            <td>
                <g:select from="${1..100}" keys="${1..100}" name="blank" id="blank"
                          value="${MatlabObjX.opts.blank * 100}"/>
            </td>
        </tr>
        <tr>
            <td style="padding: 5px;" align="right" valign="top" nowrap>Correct by fitting trend through QCs :</td>
            <td>
                <g:select from="${['Yes', 'No']}" keys="${['y', 'n']}" name="qc" id="qc"
                          value="${MatlabObjX.opts.qc}"/>
            </td>
        </tr>
        <tr>
            <td style="padding: 5px;" align="right" valign="top" nowrap>Correct inter batch effects :</td>
            <td>
                <g:select from="${['Yes', 'No']}" keys="${['y', 'n']}" name="qcinter" id="qcinter"
                          value="${MatlabObjX.opts.qcinter}"/>
            </td>
        </tr>
        <tr>
            <td style="padding: 5px;" align="right" valign="top" nowrap>Export corrected data options :</td>
            <td>
                <g:select from="${exportOptions = [
                        1: "Running Samples (average preparations/injections)",
                        2: "Running Samples (average preparations/first injection)",
                        3: "Running Samples (first preparation/average injections)",
                        4: "Running Samples (first preparation/first injection)",
                        5: "Running Samples (unchanged)",
                        6: "Running Samples+QC's (unchanged)",
                        7: "Everything (including QC's calibrants etc)",
                ]}" name="exportOption" value="${MatlabObjX.opts.export_what}" optionKey="key" optionValue="value"/>
            </td>
        </tr>
        <tr>
            <td><g:hiddenField name="jobId" value="${jobId}"/></td>
            <td>
                <g:submitButton name="submit" class="btn" value="Correct & Download"/>
            </td>
        </tr>
    </table>
</g:form>
<g:if test="${MatlabObjX}">
    <g:form name="viewReport" action="qcReport" controller="project" id="${project?.id}">
        <table>
            <tr>
                <td style="padding: 5px;" align="right" valign="top">&nbsp;</td>
                <td><g:hiddenField name="jobId" value="${params.job}"/></td>
            </tr>
            <tr>
                <td style="padding: 5px;" align="right" valign="top" nowrap>&nbsp;</td>
                <td><g:submitButton class="btn" name="viewReport" value="view QC Report"/></td>
            </tr>
        </table>
    </g:form>
</g:if>
</br>
</br>
</br>
<script src="${resource(dir: 'js/nvd3/lib', file: 'd3.v2.js')}"></script>
<script src="${resource(dir: 'js/nvd3', file: 'nv.d3.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src', file: 'tooltip.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src', file: 'utils.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'axis.js')}"></script>

<script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBar.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'discreteBarChart.js')}"></script>

<script src="${resource(dir: 'js/nvd3/src/models', file: 'legend.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'scatter.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'line.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'historicalBar.js')}"></script>
<script src="${resource(dir: 'js/nvd3/src/models', file: 'linePlusBarChart.js')}"></script>

<script type="text/javascript">
    var jsonObj = ${ MatlabObjX.opts.barVals as JSON};
    var peaks = [];
    var chart;
    var defaultCutoff =${MatlabObjX.opts.blank * 100};
    var graphData = [
        { "key": "QC Samples", "bar": true, "values": barData() },
        { "key": "Blank Correction Cutoff", "values": lineData()}
    ];

    function barData() {
        peaks = [];
        $.each(jsonObj, function (index, area) {
            var vals = [];
            $.each(area, function (i, value) {
                if (value > 0) {
                    vals.push({x: i, y: value});
                }
            });
            peaks[index] = vals;
        });
        return peaks[0].concat(peaks[1]);
    }

    function lineData(yAxisVal) {
        var cutoffValsSeries = [];
        if (!yAxisVal)
            yAxisVal = defaultCutoff;
        for (var i = 0; i < peaks[0].concat(peaks[1]).length; i++) {
            cutoffValsSeries.push({x: i, y: yAxisVal });
        }
        return cutoffValsSeries;
    }
    /*
     var aMap = { "key": "QC Samples", "bar": true, "values": peaks[0].concat(peaks[1]) }, bMap = { "key": "Blank Correction Cutoff", "values": cutoffValsSeries};

     var combineData = [aMap, bMap];
     var max = combineData[0].values[combineData[0].values.length - 1].y;
     */
    // register drop down change event
    $(function () {
        $("#blank").change(function () {
            graphData[1].values = lineData(this.value);
            //aMap = { "key": "QC Samples", "bar": true, "values": peaks[0].concat(peaks[1]) }, bMap = { "key": "Blank Correction Cutoff", "values": cutoffValsSeries};
            //combineData = [aMap, bMap];
            //max = combineData[0].values[combineData[0].values.length - 1].y;
            redraw();
        });
    });

    function redraw() {
        d3.select('#chart1 svg')
            //.datum(combineData)
                .datum(graphData)
                .transition().duration(500)
                .call(chart);
    }

    nv.addGraph(function () {
        chart = nv.models.linePlusBarChart()
                .margin({top: 30, right: 60, bottom: 50, left: 80})
                .x(function (d, i) {
                    return i
                })
                .color(d3.scale.category10().range());
        /*
         chart.xAxis.tickFormat(function (d) {
         var dx = combineData[0].values[d] && combineData[0].values[d].x || 0;
         return dx;
         });
         */
        chart.xAxis
                .axisLabel('Metabolite #');

        chart.y1Axis
                .axisLabel('%')
                .tickFormat(function (d) {
                    return d3.format(',f')(d) + '%'
                }).tickValues([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])

        chart.y2Axis
                .tickFormat(
                function (d) {
                    //return d3.format(",d")(d)
                    return
                }).tickValues([0, 100])
        //}).tickValues([0,10,20,30,40,50,60,70,80,90,100])

        chart.bars.forceY([0, 100]);
        chart.bars.forceX([0, peaks[0].concat(peaks[1]).length] + 1);
        chart.lines.forceY([0, 100]);

        d3.select('#chart1 svg')
            //.datum(combineData)
                .datum(graphData)
                .transition().duration(500).call(chart);

        nv.utils.windowResize(chart.update);

        chart.dispatch.on('stateChange', function (e) {
            nv.log('New State:', JSON.stringify(e));
        });

        return chart;
    });

</script>
</body>
</html>
