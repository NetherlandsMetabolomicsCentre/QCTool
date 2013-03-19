package nl.nmc.importers

import org.grails.plugins.excelimport.DefaultImportCellCollector
import org.codehaus.groovy.grails.commons.ApplicationHolder

/**
 * Created with IntelliJ IDEA.
 * User: ishtiaq
 * Date: 3/11/13
 * Time: 8:19 AM
 * To change this template use File | Settings | File Templates.
 */
class DefaultSettingImporter {
    def static cellReporter = new DefaultImportCellCollector()
    def excelImportService

    public DefaultSettingImporter() {
        super()
    }

    public DefaultSettingImporter(fileName) {
        super(fileName)
        def ctx = ApplicationHolder.getApplication().getMainContext()
        excelImportService = ctx.getBean("excelImportService")
    }
}
