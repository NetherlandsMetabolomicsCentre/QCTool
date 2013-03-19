<%--
  Created by IntelliJ IDEA.
  User: ishtiaq
  Date: 2/7/13
  Time: 10:19 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>${project.name}</title>
    <r:require modules="jquery"/>
    <r:layoutResources/>
    <script src="${resource(dir: 'js', file: 'jquery.handsontable.full.js')}"></script>
    <link rel="stylesheet" media="screen" href="${resource(dir: 'css', file: 'jquery.handsontable.full.css')}"
          type="text/css">
</head>

<body>
<p>${project.name} - Sample list</p>

<div id="sampleList" style="height:490px; overflow: auto"></div>

<script>
    function readonlyRenderer(instance, td, row, col, prop, value, cellProperties) {
        Handsontable.TextCell.renderer.apply(this, arguments);
        if (cellProperties.readOnly) {
            td.className = 'dimmed';
        }
    }
    var $container = $("#sampleList");
    function callbackGrid(myData) {
        $container.handsontable({
                    data:myData,
                    minSpareRows:1,
                    //always keep at least 1 spare row at the bottom,
                    currentRowClassName:'currentRow',
                    currentColClassName:'currentCol',
                    rowHeaders:true,
                    contextMenu:true,
                    undo:true,
                    autoWrapRow:true,
                    autoWrapCol:true,
                    manualColumnResize:true,
                    fillHandle:true,
                    colHeaders:true,
                    colHeaders:['Order', 'Name', 'Id', 'Level', 'isOutlier', 'isSuspect', 'Comment', 'batch', 'Preparation', 'Injection', 'isSample', 'isQC', 'isCal', 'isBlank', 'isWash', 'isSST', 'isProc'],
                    columns:[
                        {data:"sampleOrder", type:{renderer:readonlyRenderer}, readonly:true},
                        {data:"name"},
                        {data:"sampleID"},
                        {data:"level"},
                        {data:"outlier", type:Handsontable.CheckboxCell},
                        {data:"suspect", type:Handsontable.CheckboxCell},
                        {data:"comment"},
                        {data:"batch"},
                        {data:"preparation"},
                        {data:"injection"},
                        {data:"sample", type:Handsontable.CheckboxCell},
                        {data:"qc", type:Handsontable.CheckboxCell},
                        {data:"cal", type:Handsontable.CheckboxCell},
                        {data:"blank", type:Handsontable.CheckboxCell},
                        {data:"wash", type:Handsontable.CheckboxCell},
                        {data:"sst", type:Handsontable.CheckboxCell},
                        {data:"proc", type:Handsontable.CheckboxCell}

                    ]
                }
        )
        ;
    }
    <g:remoteFunction controller="project" action="listSamples" id="${project?.id}"
    onSuccess="callbackGrid(data)"
    />

</script>
</body>
</html>