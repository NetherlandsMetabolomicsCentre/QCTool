package nl.nmc.exporters

import nl.nmc.Project
import org.apache.poi.ss.usermodel.Cell
import org.apache.poi.ss.util.CellReference
import org.grails.plugins.excelimport.AbstractExcelImporter

/**
 * Created with IntelliJ IDEA.
 * User: ishtiaq
 * Date: 4/4/13
 * Time: 6:35 PM
 * To change this template use File | Settings | File Templates.
 */
class SampleListExporter extends AbstractExcelImporter {
    def excelExportService

    SampleListExporter() {
        this.createEmpty()
    }

    SampleListExporter(String fileName) {
        super.read(fileName)
    }

    def void writeNewRow(Map rowMap) {
        //First create the row at bottom of sheet
        sheet.createRow(sheet.getLastRowNum() + 1)
        def rowIdx = sheet.getLastRowNum() + 1

        // clear cellMap of last insert
        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.cellMap = [:]

        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap.each {
            s_CONFIG_SAMPLE_LIST_COLUMN_MAP.cellMap << [(it.key + "" + rowIdx + 1): it.value]
        }
        excelExportService.setValues(
                rowMap,
                workbook,
                s_CONFIG_SAMPLE_LIST_COLUMN_MAP,
                s_configurationMap
        )
    }

    def void writeRow(rowIdx, Map rowMap) {
        // clear cellMap of last insert
        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.cellMap = [:]

        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap.each {
            s_CONFIG_SAMPLE_LIST_COLUMN_MAP.cellMap << [(it.key + "" + rowIdx + 1): it.value]
        }
        excelExportService.setValues(
                rowMap,
                workbook,
                s_CONFIG_SAMPLE_LIST_COLUMN_MAP,
                s_configurationMap
        )
    }

    def void writeHeaderRow() {
        def headerRow = sheet.createRow(0)
        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap.each {
            excelExportService.setCellValueByColName(it.value, headerRow, it.key, evaluator, s_configurationMap)
        }
    }

    def boolean hasHeaderRow() {
        sheet = workbook.getSheet(s_CONFIG_SAMPLE_LIST_COLUMN_MAP.sheet)
        def headerRow = sheet.getRow(0)
        return headerRow && headerRow?.lastCellNum == s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap.size
    }

    @Override
    def createEmpty() {
        workbook = new org.apache.poi.xssf.usermodel.XSSFWorkbook()
        evaluator = workbook.creationHelper.createFormulaEvaluator()
        sheet = workbook.createSheet(s_CONFIG_SAMPLE_LIST_COLUMN_MAP.sheet)
        return this
    }

    void setSamples(sampleList) {
        excelExportService.setColumns(
                sampleList,
                workbook,
                s_CONFIG_SAMPLE_LIST_COLUMN_MAP,
                s_configurationMap
        )
    }

    def export(Project project) {
        //!hasHeaderRow() && writeHeaderRow()
        sheet = workbook.getSheet(s_CONFIG_SAMPLE_LIST_COLUMN_MAP.sheet)
        def columnMap = buildColumnMapFromHeaderRow(sheet.getRow(0))
        s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap = columnMap
        def list = []
        project.samples.eachWithIndex() { sample, rowNum ->
            def rowMap = [:]
            s_CONFIG_SAMPLE_LIST_COLUMN_MAP.columnMap.each { String cellName, String propertyName ->
                def value = sample[propertyName]
                if (!value) {

                } else if (value instanceof Boolean)
                    rowMap << [(propertyName): value ? 1 : 0]
                else
                    rowMap << [(propertyName): value]
            }
            list.add(rowMap)
        }
        setSamples(list)
    }

    def export(Project project, OutputStream out) {
        this.export(project)
        save(out)
    }

    def save(OutputStream out) {
        workbook.write(out);
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
                if (!cell || cell.getCellType() == Cell.CELL_TYPE_BLANK) {
                    // Can't be this cell - it's empty
                    return
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
            ],
            cellMap: [:]
    ]
}
