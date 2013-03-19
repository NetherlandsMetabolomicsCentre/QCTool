package nl.nmc

class Data {
    Date dateCreated
    Date lastUpdated
    String name
    String filename

    static constraints = {
    }

    static belongsTo = [project: Project]
}
