import nl.nmc.general.config.AdditiveStabilizer
import nl.nmc.general.config.GeneralConfig
import nl.nmc.general.config.Matrix
import nl.nmc.general.config.Platform
import nl.nmc.importers.GeneralConfigImporter
import nl.nmc.*

class BootStrap {
    public static def generalConfig;

    def init = { servletContext ->
        new Project(name: "NMC-000-01", description: "some description").save(flush: true)
        def project = new Project(name: "NMC-09-013DEMO", description: "Demo Project").save(flush: true)
        this.generalConfig = importGeneralConfig("general_config.xlsx")   // Filename need to go into grails config or in properties file

        if (project) {
            def platform = Platform.get(1) ?: null
            def matrix = Matrix.get(1) ?: null
            def additive = AdditiveStabilizer.get(1) ?: null
            def opt = ['0', '1', '2']
            if (platform && matrix && additive) {
                def setting = new Settings(name: 'testSetting', settings: ['options': opt as List], project: project, platforms: platform, matrixes: matrix, additiveStabilizers: additive)
                if (!setting.save(flush: true)) {
                    flash.message = "was unable to save the Setting"
                }
            } else {
                println "Error: project: ${project}, platforms: ${platform}, matrixes: ${matrix}, additiveStabilizers: ${additive}"
            }
            def file1 = new File("NMC09013_Batch01_NotTG_Blanks.txt")
            def newData1 = new Data(name: "${file1.name.toLowerCase()}", project: project, filename: "${UUID.randomUUID().toString()}").save(flush: true)
            new AntBuilder().copy(file: file1, tofile: new File(project.nameOfDirectory() + "/" + newData1.filename), overwrite: true)

            def file2 = new File("NMC09013_Batch01_TGCE_Blanks.txt")
            def newData2 = new Data(name: "${file2.name.toLowerCase()}", project: project, filename: "${UUID.randomUUID().toString()}").save(flush: true)
            new AntBuilder().copy(file: file2, tofile: new File(project.nameOfDirectory() + "/" + newData2.filename), overwrite: true)
            new Sample(project: project, name: 'dummy sample', sampleID: 'S1.d', level: 'C3', comment: 'dummy - S1',
                    sampleOrder: 1, batch: 1, preparation: 1, injection: 2,
                    outlier: false, suspect: false, sample: false, qc: false, cal: true, blank: false, wash: false, sst: false, proc: false).save(flush: true)
        }
        grails.converters.JSON.registerObjectMarshaller(Settings) {
            def returnArray = [:]
            returnArray['name'] = it.name
            def settingsMap = [:]
            it.settings.each {
                settingsMap << [(it.key): (it.value as List)?.join(',')]
            }
            returnArray['settings'] = it.settings
            returnArray['platform'] = it.platforms
            returnArray['matrix'] = it.matrixes
            returnArray['stabilizer'] = it.additiveStabilizers
            return returnArray
        }
        grails.converters.JSON.registerObjectMarshaller(QCJob) {
            def JOB_MAP = [
                    pth: it.inputFolder,
                    out_path: it.outputFolder,
                    mea_path: it.meaFolder,
                    NMCcode: it.code,
                    JobName: it.name ?: it.project.name,
                    MeaNames: it.meaNames,
                    MailTo: it.mailTo
            ]
            return JOB_MAP
        }
    }
    def destroy = {
    }

    private def importGeneralConfig(configFile) {

        def importer = new GeneralConfigImporter(configFile)
        def generalConfigInstance = new GeneralConfig()

        def platformMapList = importer.getPlatformList()
        println "platformMapList = ${platformMapList}"

        platformMapList.each { Map platformParams ->
            def platform = new Platform(platformParams)
            generalConfigInstance.addToPlatforms(platform)
        }
        generalConfigInstance.errors
        def matrixMapList = importer.matrixList
        println "matrixMapList = ${matrixMapList}"

        matrixMapList.each { Map matrixParams ->
            def matrix = new Matrix(matrixParams)
            generalConfigInstance.addToMatrixes(matrix)
        }
        generalConfigInstance.errors
        def additiveMapList = importer.additiveList
        additiveMapList.each { Map additiveParams ->
            def additive = new AdditiveStabilizer(additiveParams)
            generalConfigInstance.addToAdditiveStabilizers(additive)
        }
        generalConfigInstance.errors
        //def generalConfigInstance = new GeneralConfig(platforms:[platformMapList.toList()], matrixes:matrixMapList, additivestabilizers:additiveMapList)
        //[generalConfigInstance:new GeneralConfig(platforms:platformMapList, matrixes:matrixMapList, additivestabilizers:additiveMapList)]

        if (!generalConfigInstance.save(flush: true)) {
            println "Error in loading Config"
        }
        return generalConfigInstance
    }
}
