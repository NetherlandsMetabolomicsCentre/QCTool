<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="qctool"/>
    <meta http-equiv="X-UA-Compatible" content="IE=10"/>
    <r:require modules="jquery"/>
    <g:javascript library="application"/>
    <r:layoutResources/>
    <script src="${resource(dir: 'js', file: 'jquery.handsontable.full.js')}"></script>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'css', file: 'jquery.handsontable.full.css')}"
          type="text/css">
</head>

<body>
<div style="float: right;">
    <g:formatDate date="${project.dateCreated}" type="datetime" style="MEDIUM"/>
</div>

<h1>${project.name}<br/></h1>

<h2><small>${project.description}</small></h2>

<hr/>

<ul class="nav nav-tabs">
    <li class="active"><a href="#mf" data-toggle="tab">Measurement files</a></li>
    <g:if test="${project.samples.size() > 1}">
        <li><a href="#sampList" data-toggle="tab"
               onclick="<g:remoteFunction controller="project" action="listSamples" id="${project?.id}"
                                          onSuccess="callbackGrid(data)"/>">Sample List</a></li>
    </g:if>
</ul>

<div class="tab-content">
    <div class="tab-pane active" id="mf">
        <div style="width: 450px; border: thin solid #cdcdcd; padding: 10px;">
            <strong>Upload Measurement Files here!</strong>
            <g:uploadForm controller="project" action="addFiles" id="${project?.id}" name="myUpload">
                <input class="btn-large" type="file" name="fileUpload" multiple
                       accept="text/plain,text/csv,.csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"/>
                <g:submitButton class="btn" name="submit" value="submit"/>
            </g:uploadForm>
        </div>

        <ul>
            <g:each in="${project.datas}" var="data">
                <li><g:link action="showFile" id="${project.id}" params="[data: data.id]">${data.name}</g:link></li>
            </g:each>
        </ul>
        <g:if test="${project.datas}">
            <g:form name="proceedToSettings" action="generateSampleList" controller="project" id="${project?.id}">
                <g:submitButton name="submit" class="btn" value="Proceed to Report Settings"/>
            </g:form>
        </g:if>
    </div>

    <div class="tab-pane" id="sampList">
        <div id="sampleList" style="height:405px; border: thin solid #cdcdcd; padding: 0px; overflow: auto">
        </div>
        <g:if test="${project.samples.size() > 2}">
            <g:form name="viewGraph" action="viewGraph" controller="project" id="${project?.id}">
                <table>
                    <tr>
                        <td>&nbsp;</td>
                        <td><g:hiddenField name="jobId" value="${params.job}"/></td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td><g:submitButton class="btn" name="viewGraph" value="Proceed to Correction Settings"/></td>
                    </tr>
                </table>
            </g:form>
        </g:if>
    </div>
    <script>
        function saveChange(change, source) {
            if (source === 'loadData') {
                return; // data is just loaded don't save this change
            }
            if (change && change[0][2] === change[0][3])  return; // no change same old value
            var rowId = change[0][0];
            var rowData = $('#sampleList').data('handsontable').getData()[rowId];
            var editedSample_id = rowData.id;
            if (!editedSample_id) return;
            var samp = {};
            samp[change[0][1]] = change[0][3];
            $.ajax({
                url: "/QCPipeline/sample/update/" + editedSample_id,
                dataType: "json",
                type: "POST",
                cache: false,
                data: samp,
                statusCode: {
                    404: function () {
                        //console.log("page not found");
                    }
                },
                success: function (data) {
                    //console.log(data);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    //console.log(textStatus, errorThrown);
                }
            });
        }

        function readonlyRenderer(instance, td, row, col, prop, value, cellProperties) {
            Handsontable.TextCell.renderer.apply(this, arguments);
            if (cellProperties.readOnly) {
                td.style.fontStyle = 'italic';
                //td.style.fontWeight = 'bold';
                td.style.color = '#777';
            }
        }
        var onProp = 'none';
        function rowFormatter(instance, td, row, col, prop, value, cellProperties) {
            var colorArr = {none: "", qc: "#ff8c00", cal: "#dff0d8", blank: "#d9edf7", sample: "#f2dede"}
            if (prop === 'qc' && value === true) onProp = 'qc';
            else if (prop === 'cal' && value === true) onProp = 'cal';
            else if (prop === 'blank' && value === true) onProp = 'blank';
            else if (prop === 'sample' && value === true) onProp = 'sample';
            $(td.parentNode.childNodes).each(function () {
                if (this.tagName != 'TH') {
                    this.style.backgroundColor = colorArr[onProp];
                }
            });
            Handsontable.CheckboxCell.renderer.apply(this, arguments);
        }
        var container = $("#sampleList");
        var handsontable = container.data('handsontable');
        function callbackGrid(myData) {
            container.handsontable({
                        data: myData,
                        onChange: saveChange,
                        minSpareRows: 0, //always keep at least 1 spare row at the bottom,
                        currentRowClassName: 'currentRow',
                        currentColClassName: 'currentCol',
                        rowHeaders: true,
                        contextMenu: false,
                        stretchH: 'all',
                        scrollH: 'auto',
                        scrollV: 'auto',
                        undo: true,
                        autoWrapRow: true,
                        autoWrapCol: true,
                        manualColumnResize: true,
                        fillHandle: true,
                        colHeaders: true,
                        colHeaders: ['Order', 'Name', 'Id', 'Level', 'isOutlier', 'Comment', 'Batch', 'Preparation', 'Injection', 'isSample', 'isQC', 'isCal', 'isBlank'],
                        columns: [
                            {data: "sampleOrder", type: 'numeric', readonly: true},
                            {data: "name", readonly: true},
                            {data: "sampleID"},
                            {data: "level"},
                            {data: "outlier", type: Handsontable.CheckboxCell},
                            //{data: "suspect", type: Handsontable.CheckboxCell},
                            {data: "comment"},
                            {data: "batch", type: 'numeric'},
                            {data: "preparation", type: 'numeric'},
                            {data: "injection", type: 'numeric'},
                            {data: "sample", type: {renderer: rowFormatter}},
                            {data: "qc", type: {renderer: rowFormatter}},
                            {data: "cal", type: {renderer: rowFormatter}},
                            {data: "blank", type: {renderer: rowFormatter}}
                            //{data: "wash", type: Handsontable.CheckboxCell},
                            //{data: "sst", type: Handsontable.CheckboxCell},
                            //{data: "proc", type: Handsontable.CheckboxCell}
                        ],
                        cells: function (row, col, prop) {
                            var cellProperties = {};
                            if (prop === 'sampleOrder' || prop === 'name') {
                                cellProperties.readOnly = true;
                                cellProperties.type = {
                                    renderer: readonlyRenderer
                                }
                                return cellProperties;
                            }

                        }
                    }
            );
        }
    </script>
</div>
<hr/>
</body>
</html>
