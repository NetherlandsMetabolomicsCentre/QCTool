<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="qctool"/>
</head>

<body>
<table>
    <tr>
        <td valign="top" style="border: thin solid #dcdcdc; padding: 25px; width: 300px">
            <strong>new project</strong>
            <g:form name="createProject" action="index">
                <table>
                    <tr>
                        <td style="padding: 5px;" align="right" valign="top" nowrap>Project Name</td>
                        <td>
                            <g:textField name="name" value="${params.name ?: ''}"/>
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 5px;" align="right" valign="top" nowrap>Project Description</td>
                        <td>
                            <g:textArea cols="5" rows="3" name="description" value="${params.description ?: ''}"/>
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td><g:submitButton name="submit" class="btn" value="create"/></td>
                    </tr>
                </table>
            </g:form>
        </td>
        <td valign="top" style="width:100%; padding: 0 25px;">
            <h2>Projects</h2>
            <ul>
                <g:each in="${projects}" var="project">
                    <li><g:link action="view" id="${project.id}">${project}</g:link></li>
                </g:each>
            </ul>
        </td>
    </tr>
</table>
</body>
</html>
