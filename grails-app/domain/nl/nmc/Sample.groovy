package nl.nmc

class Sample {
    Date dateCreated
    Date lastUpdated
    String name, sampleID, level, comment
    int sampleOrder, batch, preparation, injection
    boolean outlier, suspect, sample, qc, cal, blank, wash, sst, proc

    static constraints = {
        comment(nullable: true, blank: true)
    }

    static belongsTo = [project: Project]
}
