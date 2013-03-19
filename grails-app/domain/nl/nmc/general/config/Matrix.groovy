package nl.nmc.general.config

class Matrix {
    Date dateCreated
    Date lastUpdated
    String name      // descriptive name
    String l2    // @TODO need to be given a more descriptive name

    static constraints = {
        l2(unique:true)
        name(blank: true, nullable:true)
    }

    @Override
    public String toString(){
        name
    }
}
