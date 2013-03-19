package nl.nmc.general.config

class AdditiveStabilizer {
    Date dateCreated
    Date lastUpdated
    String name      // descriptive name
    String l3    // @TODO need to be given a more descriptive name

    static constraints = {
        l3(unique:true)
        name(blank: true, nullable:true)
    }

    @Override
    public String toString(){
        name
    }
}
