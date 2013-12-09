package nl.nmc.mzquality

import groovy.json.JsonSlurper

    class ReportTagLib {

        static namespace = "report"

        def metaboliteTable = { attrs, body ->

            if (!attrs.qcData){
                out << "No valid QC data found"
             } else {

                def qcData = new JsonSlurper().parseText(attrs.qcData)

                // parse the data to define the structure of the header
                def columns = qcData.Tables.Column.size()
                def levels = qcData.Tables.Column[0]['Header'].size()
                def rows = qcData.Tables.Column[0]['Data'].size()

                // init levels of the header
                def headerStructure = [:]
                levels.times { headerLevel -> headerStructure[headerLevel] = [:] }

                // iterate over the levels in the header
                headerStructure.keySet().each { headerLevel ->
                    def levelHeaders = [:]
                    def levelHeaderIdx = 0
                    qcData.Tables.Column.each { column ->

                        def currentHeader = column['Header'][headerLevel]
                        //if (levelHeaderIdx == 0 || currentHeader.trim() != ''){
                        if (levelHeaderIdx == 0 || currentHeader != ''){

                            // a new header starts
                            levelHeaderIdx++

                            // init new header map
                            levelHeaders[levelHeaderIdx] = [:]
                            levelHeaders[levelHeaderIdx]['label'] = currentHeader
                            levelHeaders[levelHeaderIdx]['colspan'] = 1 // set width to 1 of the new header
                        } else {
                            levelHeaders[levelHeaderIdx]['colspan']++ // increase the width with one for this header
                        }
                    }

                    headerStructure[headerLevel] = levelHeaders
                }

                out << '<table class="table table-hover">'

                // inject the header
                headerStructure.each { level, header ->
                    out << '<tr>'
                    header.each { headerIdx, headerEntry ->
                        out << '<th nowrap style="font-size: 11px; border: thin solid #cdcdcd;" colspan="' + headerEntry.colspan + '">' + headerEntry.label + '</th>'
                    }
                    out << '</tr>'
                }

                // inject the actual idata
                rows.times { rowIdx ->
                    out << '<tr onClick="tableRowClicked(\''+ qcData.Tables.Column[0]['Data'][rowIdx] +'\')">'
                        columns.times { colIdx ->
                            // data is passed as a list sometimes, then we just concat all values :)
                            def cellValue = qcData.Tables.Column[colIdx]['Data'][rowIdx].collect { it }.join('')
                            out << '<td nowrap style="font-size: 9px;">' + cellValue + '</td>'
                        }
                    out << '</tr>'
                }

                out << '</table>'
            }
        }
}
