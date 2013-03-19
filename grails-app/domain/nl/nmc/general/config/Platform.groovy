package nl.nmc.general.config

class Platform {
    Date dateCreated
    Date lastUpdated
    String name      // descriptive name
    String shortName
    String l1    // @TODO need to be given a more descriptive name
    Integer sopCode
    String spike, ISspike
    double RSDQCThreshold, RSDRepsThreshold, RSDCalThreshold, RSDselect


    static constraints = {
        l1(unique:true)
        name(blank: true, nullable:true)
        shortName(blank: true, nullable:true)
        spike(blank: true, nullable:true)
        ISspike(blank: true,nullable: true)
    }

    @Override
    public String toString(){
        return "${l1} - ${shortName}"
    }
}
