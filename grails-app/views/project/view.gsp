<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="qctool"/>
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
                <li><g:link controller="data" action="view" id="${data.id}">${data.name}</g:link></li>
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
</div>
<hr/>
</body>
</html>
