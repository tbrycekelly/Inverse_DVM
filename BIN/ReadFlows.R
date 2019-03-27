#' ReadFlows
#'
#' This script is designed to run and generate the analyses based on saved data. 
#' @param model
#' @param solution
#' @param Flow.Worksheet Location of the flow worksheet.
#' @param flow.count The number of flows to look for in the worksheet.
#' @import Matrix lattice ggplot2 RColorBrewer diagram digest
#' @importFrom XLConnect loadWorkbook saveWorkbook createSheet writeWorksheet
#' @export
#' @examples ReadFlows()
#' 
ReadFlows = function(model, solution, Flow.Worksheet="/Users/TKelly/Dropbox/Documents/End2End2LayerCompartments.xlsx", flow.count=30) {
    ## Prepare derived data
    typ = "character"
    for (i in 1:flow.count) typ = c(typ, "numeric")
    WB2 = loadWorkbook(Flow.Worksheet)
    WB2_data = readWorksheet(WB2, sheet="126", 2, 1,flow.count+3, flow.count+4, colTypes=typ )

    boxes = WB2_data[,1]
    flow = matrix(0.0, nrow=flow.count, ncol=flow.count)
    for(ii in 1:(flow.count) ) { ## 1:27
        for (j in 1:(flow.count)) {  ## 1:27
            if (!is.na(WB2_data[j,ii+1])) {
                flow[j,ii] = solution$avg[WB2_data[j,ii+1]]
            }
        }
    }
    rownames(flow) = boxes
    colnames(flow) = boxes
    
    return(flow)
}