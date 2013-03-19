package nl.nmc.general.config

class GeneralConfig {
    Date dateCreated
    Date lastUpdated
    List<Platform> platforms
    List<Matrix> matrixes
    List<AdditiveStabilizer> additiveStabilizers

    static constraints = {
    }

    static hasMany = [additiveStabilizers: AdditiveStabilizer, matrixes: Matrix, platforms: Platform]
}
