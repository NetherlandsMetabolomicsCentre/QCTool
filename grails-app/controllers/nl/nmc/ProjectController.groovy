package nl.nmc

import grails.converters.JSON
import nl.nmc.exporters.JobListExporter
import nl.nmc.general.config.AdditiveStabilizer
import nl.nmc.general.config.GeneralConfig
import nl.nmc.general.config.Matrix
import nl.nmc.general.config.Platform
import nl.nmc.importers.SampleListImporter

class ProjectController {
    enum AcceptedExt {
        xlsx,
        xls,
        csv,
        tab,
        tsv,
        txt;
    }

    def index() {
        if (params?.submit == "createNewProject") {
            def project = new Project(params)
            if (!project.save(flush: true)) {
                flash.message = "was unable to save the Project - ${params}"
            }
        }
        [projects: Project.list()]
    }

    def view() {
        if (!params?.id) {
            redirect(action: "index", params: params)
        }
        [project: Project.get(params.id), config: GeneralConfig.get(1)]
    }

    def viewSampleList() {
        if (!params?.id) {
            redirect(action: "index", params: params)
        }
        [project: Project.get(params.id)]
    }

    def addSetting() {
        def project = Project.get(params.id) ?: null
        if (params?.submit == "createProjectSetting" && project) {
            def platform = Platform.get(params.platform) ?: null
            def matrix = Matrix.get(params.matrix) ?: null
            def additive = AdditiveStabilizer.get(params.additive) ?: null
            def opt = params.options as List ?: null

            if (platform && matrix && additive) {
                def setting = new Settings(name: params.name, settings: ['options': opt], project: project, platforms: platform, matrixes: matrix, additiveStabilizers: additive)
                if (!setting.save(flush: true)) {
                    flash.message = "was unable to save the Setting - ${params}"
                }
            }

        }

        //return to where you came from...
        redirect(action: "view", params: [id: params.id])
    }

    def addFiles() {
        def uploadedFiles = request.getFiles('fileUpload')

        def project = Project.get(params.id) ?: null

        if (!uploadedFiles.isEmpty() && project) {

            uploadedFiles.each {  uploadedfile ->

                //determine extension of uploaded file
                def filename = uploadedfile.getOriginalFilename().toLowerCase()
                def ext = filename.tokenize(".")[-1]

                // select correct way of processing the file based on extension
                switch (ext) {

                    case 'zip':    // uploaded zip
                        def zipLocation = "/tmp/${UUID.randomUUID().toString()}"
                        def zipLocationFile = new File("${zipLocation}")
                        zipLocationFile.mkdirs()

                        def zippedFile = new File("${zipLocation}/zippedFile.zip")
                        zippedFile.setWritable(true, false) && zippedFile.canWrite()

                        uploadedfile.transferTo(zippedFile)

                        def ant = new AntBuilder()
                        ant.unzip(
                                src: zippedFile.canonicalPath,
                                dest: zipLocation,
                                overwrite: "true"
                        )

                        //loop over files from zip and add the mzxml files!!!
                        zipLocationFile.eachFile {

                            //determine extension of unzipped files
                            def unzippedFilename = it.absolutePath.toLowerCase()
                            def unzippedName = unzippedFilename.tokenize("/")[-1]
                            def unzippedExt = unzippedName.tokenize(".")[-1]

                            if (unzippedExt in AcceptedExt) {
                                def unzippedData = new Data(name: "${unzippedName}", project: project, filename: "${UUID.randomUUID().toString()}").save(flush: true)
                                ant.copy(file: it, tofile: new File(project.nameOfDirectory() + "/" + unzippedData.filename), overwrite: true)
                            }
                        }

                        break

                    case 'xlsx':
                    case 'xls':
                    case 'csv':
                    case 'tsv':
                    case 'tab':
                    case 'txt':
                        def newData = new Data(name: "${filename}", project: project, filename: "${UUID.randomUUID().toString()}")
                        newData.save(flush: true)
                        uploadedfile.transferTo(new File(project.nameOfDirectory() + "/" + newData.filename))
                        break

                    default:    //unsupported file!
                        log.error("Unsupported filetype!")
                }
            }

        }

        //return to where you came from...
        redirect(action: "view", params: params)
    }

    def prepareQCReport() {
        if (!params?.id) {
            redirect(action: "index", params: params)
        }

        def project = Project.get(params.id) ?: null
        def setting = Settings.get(params.setting) ?: null
        def dataList = project?.datas

        if (params?.submit == "prepare QC Report" && project && setting && dataList) {
            //cross validate it
            if (setting.project == project) {

                def folderLocation = grailsApplication.config.dataFolder
                folderLocation = folderLocation.replaceAll(/"/, '')
                def jobListLocationFile = new File("${folderLocation}")
                jobListLocationFile.mkdirs()

                def jobListFile = new File(jobListLocationFile.absolutePath + File.separator + "DCL Joblist_v3.xlsx")
                JobListExporter jobListExporter

                if (jobListFile.exists())
                    jobListExporter = new JobListExporter(jobListFile.absolutePath)
                else
                    jobListExporter = new JobListExporter()
                jobListExporter.addSetting(setting)
                jobListExporter.export()

                jobListFile.setWritable(true, false) && jobListFile.canWrite()
                FileOutputStream fileOut = new FileOutputStream(jobListFile);
                jobListExporter.save(fileOut)
                fileOut.close();

                // add measurements files to folder stature
                def projectFolderLocation = "${folderLocation + setting.platforms.toArray()[0].toString()}/${project.name}"
                def projectFolder = new File("${projectFolderLocation}")
                projectFolder.mkdirs()
                def inputFolder = new File("${projectFolderLocation + File.separator }input")
                inputFolder.mkdir()
                def meaFolder = new File("${projectFolderLocation + File.separator}mea")
                meaFolder.mkdir()
                def outputFolder = new File("${projectFolderLocation + File.separator}output")
                outputFolder.mkdir()

                def ant = new AntBuilder()
                dataList.each {
                    ant.copy(file: new File(project.nameOfDirectory() + File.separator + it.filename), tofile: new File(projectFolderLocation + File.separator + "mea" + File.separator + it.name), overwrite: true)
                }
                /*
                //zippedFile.setWritable(true, false) && zippedFile.canWrite()
                ant.zip(
                        basedir: projectFolderLocation,
                        destfile: "${folderLocation}/${project.name}.zip",
                        level: 9
                )
                def zippedFile = new File("${folderLocation}/${project.name}.zip")
                if (zippedFile.exists()) {
                    response.setContentType("application/octet-stream")
                    response.setHeader("Content-disposition", "filename=${project.name}.zip")
                    response.outputStream << zippedFile.bytes
                    return
                }

                */

                def commandLiteral = grailsApplication.config.matlabCommand
                commandLiteral = commandLiteral.replaceAll(/"/, '')
                /*
                def scriptFile = new File("/tmp/test.m")
                if (!scriptFile.exists())
                    scriptFile.createNewFile()
                else
                    scriptFile.delete()

                scriptFile << "addpath('/Users/ishtiaq/Documents/MATLAB/QCreport31072012/NMC_v3', '-begin');${System.getProperty("line.separator")}addpath('/Users/ishtiaq/Documents/MATLAB/QCreport31072012/tools', '-begin');${System.getProperty("line.separator")}addpath('/Users/ishtiaq/Documents/MATLAB', '-begin');${System.getProperty("line.separator")}path${System.getProperty("line.separator")}dclqc_v3()"
                */
                println("${commandLiteral}")
                ant.exec(outputproperty: "cmdOut",
                        errorproperty: "cmdErr",
                        resultproperty: "exitValue",
                        failonerror: "true",
                        dir: "${jobListLocationFile}",
                        executable: "${commandLiteral}") {
                    arg(line: "-nodesktop -nosplash -logfile /tmp/matlab_log -r \"dclqc_v3(1)\"")
                }

                def result = new Expando(
                        text: ant.project.properties.cmdOut,
                        error: ant.project.properties.cmdErr,
                        exitValue: ant.project.properties.exitValue as Integer,
                        toString: {text}
                )
                println ant.project.properties.cmdOut
                println ant.project.properties.cmdErr

                if (result.exitValue != 0) {
                    throw new Exception("""command failed with ${result.exitValue}
                        executed: ${commandLiteral}
                        error: ${result.error}
                        text: ${result.text} ${}""")

                } else {
                    /**
                     *  successful??
                     *  clear the old sample list
                     */
                    project.getSamples()?.each { s ->
                        s.delete(flush: true)
                    }
                    def importer = new SampleListImporter("${projectFolderLocation + File.separator }input" + File.separator + "samplelist.xlsx")
                    def sampleListMap = importer.getSampleList()
                    sampleListMap.each { Map sampleParams ->
                        new Sample(project: project,
                                sampleOrder: sampleParams['sampleOrder'] as int,
                                name: sampleParams['name'],
                                sampleID: sampleParams['sampleID'],
                                level: sampleParams['level'],
                                outlier: "${sampleParams['outlier'] as int}".toBoolean(),
                                suspect: "${sampleParams['suspect'] as int}".toBoolean(),
                                comment: sampleParams['comment'],
                                batch: sampleParams['batch'] as int,
                                preparation: sampleParams['preparation'] as int,
                                injection: sampleParams['injection'] as int,
                                sample: "${sampleParams['sample'] as int}".toBoolean(),
                                qc: "${sampleParams['qc'] as int}".toBoolean(),
                                cal: "${sampleParams['cal'] as int}".toBoolean(),
                                blank: "${sampleParams['blank'] as int}".toBoolean(),
                                wash: "${sampleParams['wash'] as int}".toBoolean(),
                                sst: "${sampleParams['sst']}".toBoolean(),
                                proc: "${sampleParams['proc'] as int}".toBoolean()
                        ).save(flush: true)
                    }
                }

                /*
                ProcessBuilder processBuilder = new ProcessBuilder("/Applications/MATLAB_R2012a.app/Contents/MacOS/StartMATLAB")
                processBuilder = processBuilder.directory(jobListLocationFile)
                processBuilder.command("${folderLocation}/${project.name}")
                Process p = processBuilder.start()
                println p.dump()

                p.consumeProcessOutput(System.out, System.err)

                p.waitFor()

                println "Matlab exit value: ${p.exitValue()}"
                */

                /*
                def result = [project: project, setting: setting]

                render result as JSON
                */
            } else
                println "Error: Project and Setting doesnot crospond to each other"
        } else {
            println("Error: Either one of the Project, Setting or Data files are missing... dump:${project}, ${setting}, ${dataList}")
        }

        redirect(action: "index", params: [])
    }

    def generateSampleList = {
        if (!params?.id) {
            redirect(action: "index", params: params)
        }

        def project = Project.get(params.id) ?: null
        def dataList = project?.datas

        if (params?.submit == "Proceed to Report Settings" && project.equals(null) && dataList) {
            def folderLocation = grailsApplication.config.dataFolder
            folderLocation = folderLocation.replaceAll(/"/, '')

            // add measurements files to folder stature
            def projectFolderLocation = "${folderLocation + File.separator }${project.name}"
            def projectFolder = new File("${projectFolderLocation}")
            projectFolder.mkdirs()
            def inputFolder = new File("${projectFolderLocation + File.separator }input")
            inputFolder.mkdir()
            def meaFolder = new File("${projectFolderLocation + File.separator}mea")
            meaFolder.mkdir()
            def outputFolder = new File("${projectFolderLocation + File.separator}output")
            outputFolder.mkdir()

            def ant = new AntBuilder()
            dataList.each {
                ant.copy(file: new File(project.nameOfDirectory() + File.separator + it.filename), tofile: new File("${meaFolder}" + File.separator + it.name), overwrite: true)
            }

            def job = new QCJob(project: project, inputFolder: "${inputFolder}", outputFolder: "${outputFolder}",
                    meaFolder: "${meaFolder}",
                    code: "None",
                    name: project.name,
                    meaNames: "*.*",
                    mailTo: "i.ahmad@uva.nl")

            job.save(flush: true)

            render job as JSON
            return

            def result = runMATLAB("generate_sampleist()", projectFolder)
            println result.text
            println result.error

        } else {
            println("Error: Either one of the Project or Data files are missing... dump:${project}, ${dataList}")
        }

        redirect(action: "index", params: [])
    }

    def listQCJob = {
        if (!params?.id) {
            response.status = 404 //Not Found
        }
        def job = QCJob.get(params.id)
        if (job.equals(null)) {
            response.status = 404 //Not Found
            render """This Job ID="${params?.id}" does not exist. Request must include job ID"""
        } else {
            def project = job.project ?: null
            def dataList = project?.datas
            if (project.equals(null) && dataList) {
                render job as JSON
            } else {
                response.status = 404 //Not Found
                render """This Project ID="${project?.id}" does not exist or Data files are missing."""
            }
        }
    }

    def getCorrectedData = {
        if (!params?.id) {
        }
        def project = Project.get(params.id) ?: null
        if (project) {
            def folderLocation = grailsApplication.config.dataFolder
            folderLocation = folderLocation.replaceAll(/"/, '')
            def projectFolderLocation = "${folderLocation + project.settings.get(0).platforms.toArray()[0].toString()}/${project.name}"
            def json = new File("${projectFolderLocation + File.separator }output" + File.separator + "correctData.json").text
            render json as String
        }
    }

    def listSamples = {
        if (!params?.id) {
        }
        def project = Project.get(params.id) ?: null
        if (project) {
            render project.samples as JSON
        }
    }

    def jsonProject() {
        if (!params?.id) {
            response.status = 404 //Not Found
        }
        def project = Project.get(params.id) ?: null
        def rowMap = [:]
        if (project) {
            rowMap << [projectName: project.name]
            def dataList = project?.datas ?: []
            rowMap << [dataFile: dataList]
            def setting = Settings.get(params.setting) ?: project.settings
            rowMap << [setting: setting]
            render rowMap as JSON
        } else {
            response.status = 404 //Not Found
            render """This Project ID="${params?.id}" does not exist. Request must include project ID"""
        }
    }

    private runMATLAB(String MATLABScriptName, File baseDir) {
        def ant = new AntBuilder()
        def commandLiteral = grailsApplication.config.matlabCommand
        commandLiteral = commandLiteral.replaceAll(/"/, '')
        ant.exec(outputproperty: "cmdOut",
                errorproperty: "cmdErr",
                resultproperty: "exitValue",
                failonerror: "true",
                dir: "${baseDir}",
                executable: "${commandLiteral}") {
            arg(line: "-nodesktop -nosplash -logfile /tmp/matlab_log -r \"${MATLABScriptName}\"")
        }

        def result = new Expando(
                text: ant.project.properties.cmdOut,
                error: ant.project.properties.cmdErr,
                exitValue: ant.project.properties.exitValue as Integer,
                toString: {text}
        )
        if (result.exitValue != 0) {
            throw new Exception("""command failed with ${result.exitValue}
                        executed: ${commandLiteral}
                        error: ${result.error}
                        text: ${result.text} ${}""")

        }
        return result
    }
}
