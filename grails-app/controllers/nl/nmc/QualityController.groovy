package nl.nmc

import grails.converters.JSON

class QualityController {

    def index() {

        if (params.renewJson) {
            session.qualityJson = ""
        }

        //check if new file post
        if (params.qualityFile) {
            // read it
            def multipartFile = request.getFile('qualityFile')
            File uploadedJSONFile = File.createTempFile("qualityFile", ".json.scrap")
            uploadedJSONFile.deleteOnExit()
            multipartFile.transferTo(uploadedJSONFile)
            try {
                // store it into the session
                session.qualityJson = JSON.parse(new FileInputStream(uploadedJSONFile), "UTF-8") as JSON
            } catch (e) {
                print(e)
                log.error("File error")
            }
        }
    }

    def remoteData() {
        render(session.qualityJson ?: "{}") as JSON
    }
}
