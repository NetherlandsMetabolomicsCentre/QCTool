package nl.nmc

class QCJob {
    Date dateCreated, lastUpdated
    String name, type, inputFolder, outputFolder, meaFolder, code
    String[] meaNames // should be a regular expression
    String mailTo // should be moved to User/Person in security layer

    static constraints = {
        name(nullable: true, blank: true)
        code(nullable: false, blank: false)
        type(nullable: false, blank: false)
        meaNames(nullable: false, blank: false)
        mailTo(email: true, nullable: true, blank: false)
    }
    static belongsTo = [project: Project]
    //static hasMany = [sample: Sample]
}
