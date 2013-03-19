package nl.nmc.exporters

import nl.nmc.Settings
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.grails.plugins.excelimport.AbstractExcelImporter

import static org.grails.plugins.excelimport.ExpectedPropertyType.StringType

/**
 * Created with IntelliJ IDEA.
 * User: ishtiaq
 * Date: 11/30/12
 * Time: 12:06 PM
 * To change this template use File | Settings | File Templates.
 */
class JobListExporter extends AbstractExcelImporter {
    def excelExportService
    def List<Settings> settingsList = new ArrayList<Settings>()

    JobListExporter() {
        super()
        excelExportService = ApplicationHolder.getApplication().getMainContext().getBean("excelImportService")
        this.createEmpty()
    }

    JobListExporter(String fileName) {
        super(fileName)
        excelExportService = ApplicationHolder.getApplication().getMainContext().getBean("excelImportService")
    }

    def void addSetting(Settings setting) {
        settingsList.add(setting)
    }

    def export() {
        !hasHeaderRow() && writeHeaderRow()
        settingsList.each {
            def optionsList = it.settings['options'] as List ?: null
            def rowMap = [Platform: it.platforms.toArray()[0].toString(), Jobs: it.project.name, Options: optionsList?.join(','), Output: " "]
            writeRow(rowMap)
        }
    }

    def void writeRow(rowMap) {
        // First create the row at bottom of sheet
        sheet.createRow(sheet.getLastRowNum() + 1)
        def rowIdx = sheet.getLastRowNum()
        rowIdx = rowIdx + 1

        // clear cellMap of last insert
        CONFIG_DCL_JOBLIST_COLUMN_MAP.cellMap = [:]

        CONFIG_DCL_JOBLIST_COLUMN_MAP.columnMap.each {
            CONFIG_DCL_JOBLIST_COLUMN_MAP.cellMap << [(it.key + "" + rowIdx): it.value]
        }
        excelExportService.setValues(
                rowMap,
                workbook,
                CONFIG_DCL_JOBLIST_COLUMN_MAP,
                configuratiomMap
        )
    }

    def void writeHeaderRow() {
        def headerRow = sheet.createRow(0)
        CONFIG_DCL_JOBLIST_COLUMN_MAP.columnMap.each {
            excelExportService.setCellValueByColName(it.value, headerRow, it.key, evaluator, configuratiomMap)
        }
    }

    def boolean hasHeaderRow() {
        sheet = workbook.getSheet(CONFIG_DCL_JOBLIST_COLUMN_MAP.sheet)
        def headerRow = sheet.getRow(0)
        return headerRow && headerRow?.lastCellNum == CONFIG_DCL_JOBLIST_COLUMN_MAP.columnMap.size
    }

    @Override
    def createEmpty() {
        workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()
        evaluator = workbook.creationHelper.createFormulaEvaluator()
        sheet = workbook.createSheet(CONFIG_DCL_JOBLIST_COLUMN_MAP.sheet)
        return this
    }

    def save(OutputStream out) {
        workbook.write(out);
    }


    static Map configuratiomMap = [
            Jobs: ([expectedType: StringType, defaultValue: null]),
            Platform: ([expectedType: StringType, defaultValue: null]),
            Options: ([expectedType: StringType, defaultValue: null]),
            Output: ([expectedType: StringType, defaultValue: null]),
    ]

    static Map CONFIG_DCL_JOBLIST_COLUMN_MAP = [
            sheet: 'Jobs',
            startRow: 1,
            columnMap: [
                    'A': 'Platform',
                    'B': 'Jobs',
                    'C': 'Options',
                    'D': 'Output',
            ],
            cellMap: [:]
    ]

}
