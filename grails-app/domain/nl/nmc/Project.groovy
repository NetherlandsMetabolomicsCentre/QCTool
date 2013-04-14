package nl.nmc

class Project {
    String name
    String description
    Date dateCreated
    Date lastUpdated

    def grailsApplication

    static mapping = {
        description type: 'text'
    }

    static constraints = {
        description(nullable: true, blank: true)
    }

    static transients = ['datas', 'settings', 'samples', 'qcJobs']

    @Override
    String toString() {
        return name
    }

    String nameOfDirectory() {
        /**
         * Default location
         */
        def ctx = grailsApplication.parentContext
        def location = "${ctx.getResource('/').getFile()}/${this.id}/"

        /**
         * if upload location is defined in properties file then use it
         */

        def uploadFolder = grailsApplication.config.uploadFolder
        if (uploadFolder) {
            uploadFolder = uploadFolder.replaceAll(/"/, '')
            location = "${uploadFolder + File.separator + this.id}"
        }
        //def location = "${ApplicationHolder.getApplication().getParentContext().getResource('/')}/${this.id.encodeAsBase64()}/"
        new File(location).mkdirs()

        return location
    }

    List getDatas() {
        return Data.findAllByProject(this)
    }

    List getSettings() {
        return Settings.findAllByProject(this)
    }

    List getSamples() {
        return Sample.findAllByProject(this, [sort: 'sampleOrder', order: 'asc'])
    }

    List getQcJobs() {
        return QCJob.findAllByProject(this)
    }
}
