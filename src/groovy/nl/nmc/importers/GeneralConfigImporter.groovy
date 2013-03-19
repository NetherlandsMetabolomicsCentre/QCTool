package nl.nmc.importers

import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.util.CellReference
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.grails.plugins.excelimport.AbstractExcelImporter
import org.grails.plugins.excelimport.DefaultImportCellCollector

/**
 * Created with IntelliJ IDEA.
 * User: ishtiaq
 * Date: 10/15/12
 * Time: 9:17 AM
 * To change this template use File | Settings | File Templates.
 */
class GeneralConfigImporter extends AbstractExcelImporter {
    def static cellReporter = new DefaultImportCellCollector()
    def excelImportService

    public GeneralConfigImporter() {
        super()
    }

    public GeneralConfigImporter(fileName) {
        super(fileName)
        def ctx = ApplicationHolder.getApplication().getMainContext()
        excelImportService = ctx.getBean("excelImportService")
    }

    List<Map> getPlatformList() {
        def sheet = workbook.getSheet(s_CONFIG_PLATFORM_COLUMN_MAP.sheet)
        def excelRow = sheet.getRow(0)
        def columnMap = buildColumnMapFromHeaderRow(excelRow)
        s_CONFIG_PLATFORM_COLUMN_MAP.columnMap = columnMap
        excelImportService.columns(
                workbook,
                s_CONFIG_PLATFORM_COLUMN_MAP,
                cellReporter,
                s_configurationMap
        )
    }

    def buildColumnMapFromHeaderRow(excelRow) {
        def columnMap = [:]
        if (excelRow) {
            def columnCount = excelRow?.lastCellNum
            columnCount.times { columnIndex ->
                def cell = excelRow.getCell(columnIndex)
                /*
                 excelImportService don't tack 0-based cell index
                 CellReference is needed to go back 0-based base-10 column and returns a ALPHA-26
                 */
                if (cell || cell.getCellType() == Cell.CELL_TYPE_BLANK) {
                    // Can't be this cell - it's empty
                }
                if (cell.getCellType() == Cell.CELL_TYPE_STRING) {
                    String stringValue = cell.stringCellValue

                    switch (stringValue) {
                        case ~/^L1/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'l1']     //0-based base-10 column and returns a ALPHA-26
                            break
                        case ~/^L2/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'l2']
                            break
                        case ~/^L3/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'l3']
                            break
                        case ~/^Platform|Matrix|Additive/:   // will map to name
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'name']
                            break
                        case ~/^platform/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'shortName']
                            break
                        case ~/^SOP/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'sopCode']
                            break
                        case ~/(?i)^spike/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'spike']
                            break
                        case ~/(?i)^RSDQCThreshold/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'RSDQCThreshold']
                            break
                        case ~/(?i)^RSDRepsThreshold/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'RSDRepsThreshold']
                            break
                        case ~/(?i)^RSDCalThreshold/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'RSDCalThreshold']
                            break
                        case ~/(?i)^ISspike/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'ISspike']
                            break
                        case ~/(?i)^RSDselect/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'RSDselect']
                            break
                        default:
                            break
                    }
                }
            }


        }
        return columnMap
    }

    List<Map> getMatrixList() {
        def sheet = workbook.getSheet(s_CONFIG_MATRIX_COLUMN_MAP.sheet)
        def excelRow = sheet.getRow(0)
        def columnMap = buildColumnMapFromHeaderRow(excelRow)
        s_CONFIG_MATRIX_COLUMN_MAP.columnMap = columnMap

        excelImportService.columns(
                workbook,
                s_CONFIG_MATRIX_COLUMN_MAP,
                cellReporter,
                s_configurationMap
        )

    }

    List<Map> getAdditiveList() {
        def sheet = workbook.getSheet(s_CONFIG_ADDITIVE_COLUMN_MAP.sheet)
        def excelRow = sheet.getRow(0)
        def columnMap = buildColumnMapFromHeaderRow(excelRow)
        s_CONFIG_ADDITIVE_COLUMN_MAP.columnMap = columnMap
        excelImportService.columns(
                workbook,
                s_CONFIG_ADDITIVE_COLUMN_MAP,
                cellReporter,
                s_configurationMap
        )
    }

    static Map s_configurationMap = [
            l1: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            l2: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            l3: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            name: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            shortName: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            sopCode: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            spike: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            ISspike: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            RSDQCThreshold: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.DoubleType, defaultValue: 0.0]),
            RSDRepsThreshold: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.DoubleType, defaultValue: 0.0]),
            RSDCalThreshold: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.DoubleType, defaultValue: 0.0]),
            RSDselect: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.DoubleType, defaultValue: 0.0]),
    ]

    static Map s_CONFIG_PLATFORM_COLUMN_MAP = [
            sheet: 'SP20_L1',
            startRow: 1,
            columnMap: [
                    'A': 'L1',
                    'B': 'Platform',
                    'C': 'platform',
                    'D': 'SOP',
                    'E': 'spike',
                    'F': 'RSDQCThreshold',
                    'G': 'RSDRepsThreshold',
                    'H': 'RSDCalThreshold',
                    'I': 'ISspike',
                    'J': 'RSDselect',
            ]
    ]

    static Map s_CONFIG_MATRIX_COLUMN_MAP = [
            sheet: 'SP20_L2',
            startRow: 1,
            columnMap: [
                    'A': 'l2',
                    'B': 'name',
            ]
    ]

    static Map s_CONFIG_ADDITIVE_COLUMN_MAP = [
            sheet: 'SP20_L3',
            startRow: 1,
            columnMap: [
                    'A': 'l3',
                    'B': 'name',
            ]
    ]
}
