<%@ page import="grails.converters.JSON" contentType="text/html;charset=UTF-8" %>
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
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterChart.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'scatterPlusLineChart.js')}"></script>
    <style>
    #chart1 {
        margin: 0;
    }

    #chart1 svg {
        height: 500px;
    }

    #chart2 svg {
        height: 500px;
    }
    </style>
</head>

<body>
<script type="text/javascript">
    var X;
    var jsonObj;
    var ratioChart, areaChart;

    <g:remoteFunction controller="project" id="${project.id}" action="getUncorrectedData" onSuccess="callbackGrid(data)"></g:remoteFunction>
    function callbackGrid(matlabX) {
        jsonObj = $.parseJSON(matlabX);
        if (jsonObj.X) {
            jsonObj = jsonObj.X;
            X = jsonObj;
        }
        var comboList = $("#compound");
        $.each(jsonObj.tcomps, function (i, comp) {
            comboList.append($("<option></option>")
                    .attr("value", i)
                    .text(comp));
        });

        nv.addGraph(function () {
            var myData = randomData(jsonObj, [0]);
            var minMax = getMinMax(myData);
            ratioChart = nv.models.scatterChart()
                    .showDistX(true)
                    .showDistY(true)
                //.height(500)
                    .useVoronoi(true)
                    .color(d3.scale.category10().range());

            ratioChart.xAxis
                    .tickFormat(d3.format('d'))
                    .axisLabel('Order');

            ratioChart.yAxis
                    .tickFormat(d3.format('.02f'))
                    .axisLabel('Ratio');

            ratioChart.forceY([(minMax.min - minMax.min * .1 ), (minMax.max + minMax.max * .1 )]);
            //ratioChart.forceX([0, jsonObj.OrderAll.length]);
            ratioChart.sizeDomain([100, 100])
                    .sizeRange([100, 100]);
            ratioChart.tooltipContent(tooltipContent);

            d3.select('#chart1 svg')
                    .datum(myData)
                    .transition().duration(700)
                    .call(ratioChart);
            nv.utils.windowResize(ratioChart.update);

            ratioChart.dispatch.on('stateChange', function (e) {
                console.log('New State:', JSON.stringify(e));
            });
//            ratioChart.dispatch.on('onClick', function (e) {
//                console.log('New State:', JSON.stringify(e));
//            });

            return ratioChart;
        });

        //2nd Plot
        nv.addGraph(function () {
            var myData = randomData2(jsonObj, [0]);
            var minMax = getMinMax(myData);
            areaChart = nv.models.scatterChart()
                    .showDistX(false)
                    .showDistY(true)
                //.height(500)
                    .useVoronoi(true)
                    .color(d3.scale.category10().range());

            areaChart.xAxis
                    .tickFormat(d3.format('d'))
                    .axisLabel('Order');
            areaChart.yAxis
                    .tickFormat(d3.format('.02f'))
                    .axisLabel('Area');

            areaChart.forceY([(minMax.min - minMax.min * .1 ), (minMax.max + minMax.max * .1 )]);
            //ratioChart.forceX([0, jsonObj.OrderAll.length]);
            areaChart.sizeDomain([100, 100])
                    .sizeRange([100, 100]);
            areaChart.tooltipContent(tooltipContent);

            d3.select('#chart2 svg')
                    .datum(myData)
                    .transition().duration(700)
                    .call(areaChart);
            nv.utils.windowResize(areaChart.update);

            areaChart.dispatch.on('stateChange', function (e) {
                console.log('New State:', JSON.stringify(e));
            });

            return areaChart;
        });
    }

    $(function () {
        $("#compound").change(function () {
            var selectedValues = $('#compound').val();
            redraw(jsonObj, selectedValues);
        });
    });

    function tooltipContent(key, x, y, e, graph) {
        return '<h3>' + key + '</h3>' +
                '<p>Batch :' + jsonObj.batch[x] + ' Sample :' + jsonObj.samplabs[x] + '</p>' +
                '<p>' + y + ' on ' + x + '</p>';

    }

    function getMinMax(data) {
        var minY, maxY;
        data.forEach(function (d) {
            minY = maxY = d.values[0].y
            d.values.forEach(function (s) {
                minY = Math.min(minY, s.y);
                maxY = Math.max(maxY, s.y);
            });
        });
        return { min: minY, max: maxY}
    }

    function redraw(obj, idx) {
        var ratioData = randomData(obj, [idx]);
        var minMax = getMinMax(ratioData);
        d3.select('#chart1 svg')
                .datum(randomData(obj, [idx]))
                .transition().duration(800)
                .call(ratioChart);
        ratioChart.forceY([(minMax.min - minMax.min * .1 ), (minMax.max + minMax.max * .1 )]);
        ratioChart.update();
        var areaData = randomData2(obj, [idx]);
        minMax = getMinMax(areaData);
        d3.select('#chart2 svg')
                .datum(randomData2(obj, [idx]))
                .transition().duration(800)
                .call(areaChart);
        areaChart.forceY([(minMax.min - minMax.min * .1 ), (minMax.max + minMax.max * .1 )]);
        areaChart.update();
    }

    function randomData(objX, tcompsIdx) { //# groups,# points per group
        var data = [],
                shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square'],
                random = d3.random.normal();

        for (i = 0; i < tcompsIdx.length; i++) {

            data.push({
                key: objX.tcomps[tcompsIdx[i]],
                values: [],
                slope: 1,
                intercept: Math.random() - .5
            });

            for (j = 0; j < objX.Ratio.length; j++) {
                var yVal = objX.Ratio[j][tcompsIdx[i]];
                // apply filter and show only QC Sample and Sample objX.is.QCSample
                yVal = $.isNumeric(yVal) ? yVal : null;
                if (!yVal) {
                    //console.log("NaN value at > compound:" + tcompsIdx[i] + ",Ratio index:" + j, i, objX.Ratio[j][tcompsIdx[i]]);
                    continue
                } else if (yVal < 0)
                    console.log("Negative value at:" + j, yVal);
                data[i].values.push({
                    x: objX.OrderAll[j][0],
                    y: yVal,
                    size: 1,
                    shape: shapes[j % 6]
                });
            }
        }

        return data;
    }

    function randomData2(objX, tcompsIdx) { //# groups,# points per group
        var data = [],
                shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square'],
                random = d3.random.normal();

        for (i = 0; i < tcompsIdx.length; i++) {
            data.push({
                key: objX.tcomps[tcompsIdx[i]],
                values: [],
                slope: 1,
                intercept: Math.random() - .5
            });

            for (j = 0; j < objX.Area.length; j++) {
                var yVal = objX.Area[j][tcompsIdx[i]];
                yVal = $.isNumeric(yVal) ? yVal : null;
                if (!yVal) {
                    //console.log("NaN value at > compound:" + tcompsIdx[i] + ",Ratio index:" + j, i, objX.Ratio[j][tcompsIdx[i]]);
                    continue
                } else if (yVal < 0)
                    console.log("Negative value at:" + j, yVal);
                data[i].values.push({
                    x: objX.OrderAll[j][0],
                    y: yVal,
                    size: 1,
                    shape: shapes[j % 6]
                });
            }
        }

        return data;
    }

    //    var data;
    //    function randomData2(groups, points) { //# groups,# points per group
    //        data = [],
    //                shapes = ['circle', 'cross', 'triangle-up', 'triangle-down', 'diamond', 'square'],
    //                random = d3.random.normal();
    //
    //        for (i = 0; i < groups; i++) {
    //            data.push({
    //                key: 'Group ' + i,
    //                values: [],
    //                slope: 1,
    //                intercept: 0
    //            });
    //
    //            for (j = 0; j < points; j++) {
    //                data[i].values.push({
    //                    x: random(),
    //                    y: random(),
    //                    size: Math.random(),
    //                    shape: shapes[j % 6]
    //                });
    //            }
    //        }
    //
    //        return data;
    //    }

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

            <div id="chart1">
                <svg></svg>
            </div>

            <br>
            <strong>Area Graph</strong>

            <div id="chart2">
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