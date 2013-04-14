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

    #chart2 svg {
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
            <td>&nbsp;</td>
            <td>
                <g:submitButton name="submit" class="btn" value="Correct & Download"/>
            </td>
        </tr>
    </table>
</g:form>
</br>
</br>
</br>
Experimental Part:
<div id="chart2">
    <svg></svg>
</div>

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

<script>
    function barChartData() {
        var amount = {
            key: "Amount",
            color: "#2ca02c",
            values: [
            ]
        };
        var jsonObj = ${ MatlabObjX.opts.barVals as JSON};
        var peaks = [];
        $.each(jsonObj, function (index, area) {
            var vals = [];
            $.each(area, function (i, value) {
                vals.push({
                    "label": i,
                    "value": value
                });
            });
            amount.values = vals;
            peaks[index] = amount;
        });
        return peaks;
    }
    nv.addGraph(function () {

        var chart = nv.models.discreteBarChart()
                .x(function (d) {
                    return d.label
                })
                .y(function (d) {
                    return d.value
                })
                .staggerLabels(true)
                .tooltips(false)
                .showValues(true);

        d3.select('#chart1 svg')
                .datum(barChartData)
                .transition().duration(500)
                .attr("width", 10)
                .call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    });

    function lineData() {
        var line = [];

        for (var i = 0; i < 100; i++) {
            line.push({x: i, y: 5});
        }

        return [
            {
                values: line,
                key: "Cut off",
                color: "#ff7f0e"
            }
        ];
    }
    /*
     nv.addGraph(function () {
     var chart = nv.models.lineChart()
     .margin({top: 20, right: 20, bottom: 20, left: 20})
     chart
     .x(function (d, i) {
     return i
     })


     chart.xAxis // chart sub-models (ie. xAxis, yAxis, etc) when accessed directly, return themselves, not the parent chart, so need to chain separately
     .tickFormat(d3.format(',.1f'));

     chart.yAxis
     .axisLabel('Voltage (v)')
     .tickFormat(d3.format(',.1f'));
     chart.lines.forceY([-5]);

     d3.select('#chart1 svg')
     //.datum([]) //for testing noData
     .datum(lineData())
     .call(chart);
     nv.utils.windowResize(chart.update);
     chart.dispatch.on('stateChange', function (e) {
     nv.log('New State:', JSON.stringify(e));
     });

     return chart;
     });
     */

    var jsonObj = ${ MatlabObjX.opts.barVals as JSON};
    var peaks = [];
    $.each(jsonObj, function (index, area) {
        var vals = [];
        $.each(area, function (i, value) {
            vals.push({x: i, y: value});
        });
        peaks[index] = vals;
    });

    var cutoffValsSeries = [];
    for (var i = 0; i < 25; i++) {
        cutoffValsSeries.push({x: i, y: 5.0 });
    }
    var aMap = { "key": "QCSamples", "bar": true, "values": peaks[0] }, bMap = { "key": "Cutoff", "values": cutoffValsSeries};

    var combineData = [aMap, bMap];
    /**
     *
     var combineData = [aMap, bMap].map(function (series) {
     series.values = series.values.map(function (d) {
     return {x: d[0], y: d[1] }
     });
     return series;
     });
     */

    nv.addGraph(function () {
        var chart = nv.models.linePlusBarChart()
                .margin({top: 30, right: 60, bottom: 50, left: 70})
                .x(function (d, i) {
                    return i
                })
                .color(d3.scale.category10().range());

        chart.xAxis.tickFormat(function (d) {
            var dx = combineData[0].values[d] && combineData[0].values[d].x || 0;
            return dx;
        });

        chart.y1Axis
                .tickFormat(d3.format(',f'));

        chart.y2Axis
                .tickFormat(function (d) {
                    return d3.format(',.2f')(d) + '%'
                });

        chart.bars.forceY([0]);
        //chart.lines.forceY([0]);

        d3.select('#chart2 svg')
                .datum(combineData)
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
