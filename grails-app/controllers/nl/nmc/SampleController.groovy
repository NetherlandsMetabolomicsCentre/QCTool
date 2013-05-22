package nl.nmc

import grails.converters.JSON
import org.springframework.dao.DataIntegrityViolationException

class SampleController {

    static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

    def index() {
        redirect(action: "list", params: params)
    }

    def list(Integer max) {
        params.max = Math.min(max ?: 10, 100)
        [sampleInstanceList: Sample.list(params), sampleInstanceTotal: Sample.count()]
    }

    def create() {
        [sampleInstance: new Sample(params)]
    }

    def save() {
        def sampleInstance = new Sample(params)
        if (!sampleInstance.save(flush: true)) {
            render(view: "create", model: [sampleInstance: sampleInstance])
            return
        }

        flash.message = message(code: 'default.created.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.id])
        redirect(action: "show", id: sampleInstance.id)
    }

    def show(Long id) {
        def sampleInstance = Sample.get(id)
        if (!sampleInstance) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            redirect(action: "list")
            return
        }

        [sampleInstance: sampleInstance]
    }

    def edit(Long id) {
        def sampleInstance = Sample.get(id)
        if (!sampleInstance) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            redirect(action: "list")
            return
        }

        [sampleInstance: sampleInstance]
    }

    def update(Long id, Long version) {
        def resultMap = [
                message: "Some errors occurred!",
                statusCode: 404,
                result: "Error"
        ]
        def sampleInstance = Sample.get(id)
        if (!sampleInstance) {
            //flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            //redirect(action: "list")
            response.status = 400
            resultMap.message = "Sample not found"
            resultMap.statusCode = 400
            resultMap.result ="Error"
            render resultMap as JSON
        }

        if (version != null) {
            if (sampleInstance.version > version) {
                sampleInstance.errors.rejectValue("version", "default.optimistic.locking.failure",
                        [message(code: 'sample.label', default: 'Sample')] as Object[],
                        "Another user has updated this Sample while you were editing")
                //render(view: "edit", model: [sampleInstance: sampleInstance])
                response.status = 400
                resultMap.message = "Another user has updated this Sample while you were editing"
                resultMap.statusCode = 400
                resultMap.result ="Error"
                render resultMap as JSON
            }
        }

        sampleInstance.properties = params

        if (!sampleInstance.save(flush: true)) {
            //render(view: "edit", model: [sampleInstance: sampleInstance])
            response.status = 406
            resultMap.message = "Unable to update requested properties ${params}"
            resultMap.statusCode = 406
            resultMap.result ="Error"
            render resultMap as JSON
        }

        //flash.message = message(code: 'default.updated.message', args: [message(code: 'sample.label', default: 'Sample'), sampleInstance.id])
        response.status = 200
        resultMap.message = "Sample updated successfully"
        resultMap.statusCode = 200
        resultMap.result ="OK"
        render resultMap as JSON
    }

    def delete(Long id) {
        def sampleInstance = Sample.get(id)
        if (!sampleInstance) {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            redirect(action: "list")
            return
        }

        try {
            sampleInstance.delete(flush: true)
            flash.message = message(code: 'default.deleted.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            redirect(action: "list")
        }
        catch (DataIntegrityViolationException e) {
            flash.message = message(code: 'default.not.deleted.message', args: [message(code: 'sample.label', default: 'Sample'), id])
            redirect(action: "show", id: id)
        }
    }
}
