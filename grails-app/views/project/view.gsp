<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="qctool"/>
    <r:require modules="jquery"/>
    <g:javascript library="application"/>
    <r:layoutResources/>
    <script src="${resource(dir: 'js', file: 'jquery.handsontable.full.js')}"></script>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'css', file: 'jquery.handsontable.full.css')}"
          type="text/css">
    <style class="common">
    .dimmed {
        font-style: italic;
        color: #777;
    }
    </style>
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
    <li><a href="#old" data-toggle="tab">Old stuff</a></li>
</ul>

<div class="tab-content">
    <div class="tab-pane active" id="mf">
        <div style="width: 450px; border: thin solid #cdcdcd; padding: 10px;">
            <strong>Upload Measurement Files here!</strong>
            <g:uploadForm controller="project" action="addFiles" id="${project?.id}" name="myUpload">
                <input type="file" name="fileUpload" multiple
                       accept="text/plain,text/csv,.csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"/>
                <g:submitButton class="btn" name="submit" value="submit"/>
            </g:uploadForm>
        </div>

        <ul>
            <g:each in="${project.datas}" var="data">
                <li><g:link action="showFile" id="${project.id}" params="[data: data.id]">${data.name}</g:link></li>
            </g:each>
        </ul>

        <g:form name="proceedToSettings" action="generateSampleList" controller="project" id="${project?.id}">
            <g:submitButton name="submit" class="btn" value="Proceed to Report Settings"/>
        </g:form>

    </div>

    <div class="tab-pane" id="old">

        <h2>Old Stuff down</h2>

        <h2>Settings section</h2>

        <g:form name="prepare" action="prepareQCReport" controller="project" id="${project?.id}">
            Current associated setting with project  ${project.name}
            <g:select from="${project?.settings}" name="setting" value="${setting?.id}" optionValue="name"
                      optionKey="id"/>
            <g:submitButton name="submit" class="btn" value="prepare QC Report"/>
        </g:form>

        <g:if test="${project.samples}">
            <h3>Sample List</h3>
            <ul>
                <li><g:link controller="project" action="viewSampleList" id="${project.id}">Sample List</g:link></li>
            </ul>
        </g:if>

        <g:if test="${project.samples.size() > 2}">
            <h3>QC Report</h3>
            <ul>
                <li><g:link controller="project" action="getCorrectedData"
                            id="${project.id}">Corrected Data</g:link></li>
            </ul>
        </g:if>

        <h4>Define New Project setting here!</h4>
        <g:form name="createSetting" action="addSetting" controller="project" id="${project?.id}">
            Name: <g:field type="text" name="name" required="true" value="Default Setting"/>
            <br>
            Select Platform:
            <g:select from="${config.platforms}" name="platform" value="${platform?.id}" optionKey="id"/>
            <br>
            Matrix Used:
            <g:select from="${config.matrixes}" name="matrix" value="${matrix?.id}" optionKey="id"/>
            <br>
            Stabilizer
            <g:select from="${config.additiveStabilizers}" name="additive" value="${additive?.id}" optionKey="id"/>
            <br>
            Options (can be combined):
            <br>
            // need to be moved to Congif.groovy
            <g:select from="${options = [
                    '0': 'DEBUG: Does not fill output column when finished',
                    '1': 'FORCE: recreate settings.xlsm',
                    '2': 'FORCE: recreate samplelist.xlsx',
                    '3': 'FORCE: reload data (removes mea\\data.mat)',
                    '4': 'OVERRULE: If codes are non NMC force type to validation (default: study/normal)',
                    '5': 'DEBUG: leave setting.xlsm open upon creation',
            ]}" name="options" multiple="true" value="${options?.key}" optionKey="key" optionValue="value"/>
            <br>
            <g:submitButton name="submit" class="btn" value="createProjectSetting"/>
        </g:form>
    </div>

    <div class="tab-pane" id="sampList">
        <div id="sampleList" style="height:405px; border: thin solid #cdcdcd; padding: 0px; overflow: auto">
        </div>
        <g:submitButton class="btn" name="refreshSampleList" value="refresh"/>
        <span class="input-xlarge uneditable-input">Lorem Ipsum and then some</span>
    </div>
    <script>
        $('#refreshSampleList').click(function () {
            $('#sampleList').data('handsontable').render();
        });
        function saveChange(change, source) {
            if (source === 'loadData') {
                return; // data is just loaded don't save this change
            }
            if(change && change[0][2]===change[0][3])  return; // no change same old value
            var rowId = change[0][0];
            var rowData = $('#sampleList').data('handsontable').getData()[rowId];
            var editedSample_id = rowData.id;
            if(!editedSample_id) return;
            var samp = {};
            samp[change[0][1]] = change[0][3];
            $.ajax({
                url: "/QCPipeline/sample/update/" + editedSample_id,
                dataType: "json",
                type: "POST",
                cache:false,
                data: samp,
                statusCode: {
                    404: function() {
                        console.log("page not found");
                    }
                },
                success: function (data) {
                    console.log(data);
                },
                error: function (jqXHR, textStatus, errorThrown ) {
                    console.log(textStatus,errorThrown);
                }
            });
        }

        function readonlyRenderer(instance, td, row, col, prop, value, cellProperties) {
            if (cellProperties.readOnly) {
                td.className = 'dimmed'; //'input-xlarge uneditable-input';
            }
            Handsontable.NumericCell.renderer.apply(this, arguments);
        }
        var $container = $("#sampleList");
        var handsontable = $container.data('handsontable');
        function callbackGrid(myData) {
            $container.handsontable({
                        data: myData,
                        onChange: saveChange,
                        minSpareRows: 1, //always keep at least 1 spare row at the bottom,
                        currentRowClassName: 'currentRow',
                        currentColClassName: 'currentCol',
                        rowHeaders: true,
                        contextMenu: true,
                        undo: true,
                        autoWrapRow: true,
                        autoWrapCol: true,
                        manualColumnResize: true,
                        fillHandle: true,
                        colHeaders: true,
                        colHeaders: ['Order', 'Name', 'Id', 'Level', 'isOutlier', 'isSuspect', 'Comment', 'Batch', 'Preparation', 'Injection', 'isSample', 'isQC', 'isCal', 'isBlank', 'isWash', 'isSST', 'isProc'],
                        columns: [
                            {data: "sampleOrder", type: {renderer: readonlyRenderer}, readonly: true},
                            {data: "name", renderer: readonlyRenderer},
                            {data: "sampleID", type: 'numeric'},
                            {data: "level"},
                            {data: "outlier", type: Handsontable.CheckboxCell},
                            {data: "suspect", type: Handsontable.CheckboxCell},
                            {data: "comment"},
                            {data: "batch", type: 'numeric'},
                            {data: "preparation", type: 'numeric'},
                            {data: "injection", type: 'numeric'},
                            {data: "sample", type: Handsontable.CheckboxCell},
                            {data: "qc", type: Handsontable.CheckboxCell},
                            {data: "cal", type: Handsontable.CheckboxCell},
                            {data: "blank", type: Handsontable.CheckboxCell},
                            {data: "wash", type: Handsontable.CheckboxCell},
                            {data: "sst", type: Handsontable.CheckboxCell},
                            {data: "proc", type: Handsontable.CheckboxCell}
                        ]
                    }
            );
        }
    </script>
</div>
<hr/>
</body>
</html>
