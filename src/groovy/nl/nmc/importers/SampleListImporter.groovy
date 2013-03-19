package nl.nmc.importers

import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.util.CellReference
import org.codehaus.groovy.grails.commons.ApplicationHolder
import org.grails.plugins.excelimport.AbstractExcelImporter
import org.grails.plugins.excelimport.DefaultImportCellCollector

/**
 * Created with IntelliJ IDEA.
 * User: ishtiaq
 * Date: 2/8/13
 * Time: 6:29 PM
 * To change this template use File | Settings | File Templates.
 */
class SampleListImporter extends AbstractExcelImporter {
    def static cellReporter = new DefaultImportCellCollector()
    def excelImportService

    public SampleListImporter() {
        super()
    }

    public SampleListImporter(fileName) {
        super(fileName)
        def ctx = ApplicationHolder.getApplication().getMainContext()
        excelImportService = ctx.getBean("excelImportService")
    }

    List<Map> getSampleList() {
        def sheet = workbook.getSheet(s_CONFIG_SAMPLE_LIST_COLUMN_MAP.sheet)
        def excelRow = sheet.getRow(0)
        def columnMap = buildColumnMapFromHeaderRow(excelRow)
        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap = columnMap
        excelImportService.columns(
                workbook,
                s_CONFIG_SAMPLE_LIST_COLUMN_MAP,
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
                        case ~/^Order/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'sampleOrder']     //0-based base-10 column and returns a ALPHA-26
                            break
                        case ~/^Name/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'name']
                            break
                        case ~/^Id/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'sampleID']
                            break
                        case ~/^Level/:   // will map to name
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'level']
                            break
                        case ~/^isOutlier/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'outlier']
                            break
                        case ~/^isSuspect/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'suspect']
                            break
                        case ~/(?i)^Comment/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'comment']
                            break
                        case ~/(?i)^batch/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'batch']
                            break
                        case ~/(?i)^Preparation/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'preparation']
                            break
                        case ~/(?i)^Injection/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'injection']
                            break
                        case ~/(?i)^isSample/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'sample']
                            break
                        case ~/(?i)^isQC/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'qc']
                            break
                        case ~/(?i)^isCal/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'cal']
                            break
                        case ~/(?i)^isBlank/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'blank']
                            break
                        case ~/(?i)^isWash/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'wash']
                            break
                        case ~/(?i)^isSST/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'sst']
                            break
                        case ~/(?i)^isProc/:
                            columnMap << [(CellReference.convertNumToColString(columnIndex)): 'proc']
                            break
                        default:
                            break
                    }
                }
            }


        }
        return columnMap
    }

    static Map s_CONFIG_SAMPLE_LIST_COLUMN_MAP = [
            sheet: 'Batch1',
            startRow: 1,
            columnMap: [
                    'A': 'Order',
                    'B': 'Name',
                    'C': 'Id',
                    'D': 'Level',
                    'E': 'isOutlier',
                    'F': 'isSuspect',
                    'G': 'Comment',
                    'H': 'batch',
                    'I': 'Preparation',
                    'J': 'Injection',
                    'K': 'isSample',
                    'L': 'isQC',
                    'M': 'isCal',
                    'N': 'isBlank',
                    'O': 'isWash',
                    'P': 'isSST',
                    'R': 'isProc',
            ]
    ]

    static Map s_configurationMap = [

            sampleID: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            level: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            comment: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),
            name: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.StringType, defaultValue: null]),

            sampleOrder: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            batch: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            preparation: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            injection: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),

            outlier: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            suspect: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            sample: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            qc: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            cal: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            blank: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            wash: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            sst: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),
            proc: ([expectedType: org.grails.plugins.excelimport.ExpectedPropertyType.IntType, defaultValue: 0]),

    ]
}
