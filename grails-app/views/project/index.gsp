<div class="nav" role="navigation">
    <ul>
        <li><a class="home" href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
    </ul>
</div>

<g:form name="createProject" action="index">
    Project Name:<g:textField name="name" value="${params.name ?: ''}"/>
    <br>
    Project Description:<g:textArea name="description" value="${params.description ?: ''}" rows="5" cols="40"/>
    <g:submitButton name="submit" value="createNewProject"/>
</g:form>

<ul>
    <g:each in="${projects}" var="project">
        <li><g:link action="view" id="${project.id}">${project}</g:link></li>
    </g:each>
</ul>