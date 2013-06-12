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
    <script src="${resource(dir: 'js/nvd3/lib', file: 'fisheye.js')}"></script>
    <script src="${resource(dir: 'js/nvd3', file: 'nv.d3.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'tooltip.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src', file: 'utils.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'axis.js')}"></script>
    <script src="${resource(dir: 'js/nvd3/src/models', file: 'legend.js')}"></script>
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

    <g:remoteFunction controller="project" id="${project.id}" action="getCorrectedData" onSuccess="callbackGrid(data)"></g:remoteFunction>
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

            //ratioChart.forceY([0, 100]);
            //ratioChart.forceX([0, jsonObj.OrderAll.length]);

            d3.select('#chart1 svg')
                    .datum(randomData(jsonObj, [0]))
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

            //ratioChart.forceY([0, 100]);
            //ratioChart.forceX([0, jsonObj.OrderAll.length]);

            d3.select('#chart2 svg')
                    .datum(randomData2(jsonObj, [0]))
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

    function redraw(obj, idx) {
        d3.select('#chart1 svg')
                .datum(randomData(obj, [idx]))
                .transition().duration(800)
                .call(ratioChart);
        ratioChart.update();
        d3.select('#chart2 svg')
                .datum(randomData2(obj, [idx]))
                .transition().duration(800)
                .call(areaChart);
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
                yVal = $.isNumeric(yVal) ? yVal : null;
                if (yVal && yVal < 0) console.log(j, yVal, tcompsIdx[i]);
                data[i].values.push({
                    x: objX.OrderAll[j][0],
                    y: yVal,
                    size: Math.random(),
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

            for (j = 0; j < objX.Ratio.length; j++) {
                var yVal = objX.Area[j][tcompsIdx[i]];
                yVal = $.isNumeric(yVal) ? yVal : null;
                if (yVal && yVal < 0) console.log(j, yVal, tcompsIdx[i]);
                data[i].values.push({
                    x: objX.OrderAll[j][0],
                    y: yVal,
                    size: Math.random(),
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