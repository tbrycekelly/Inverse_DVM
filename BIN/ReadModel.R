#' ReadModel()
#'
#' This script is the first stage of the inverse modeling workflow. Here the excel model is imported and the matricies and arrays are generated. The function returns a dataframe <model> that can then be passed on to the RunModel() function.
#' A model consists of a dataframe with the folloing fields: $flows <list of flow names>, $Aa <Approximate Matrix>, $ba <Solution of Aa>, $Ae <Exact Matrix>, $be <Solution of Ae>, $Gg <Inequalities Matrix>, $h <ineqality Solutions> ,$sdb <Uncertainty in the measurements (SD)>.
#' @param file The name with path to the excel spreadsheet containing the model.
#' @param file2 The name (including path) of the excel file containing the b vectors.
#' @param cycle The cycle number indicating the rows within the excel file2 with the appropriate data.
#' @param sheet.name The name of the sheet in excel.
#' @param num.flows The count of the model flows.
#' @param num.exact The count of the exact equations used in the model.
#' @param num.approx The count of the approximate equations used in the model.
#' @param num.ineq The count of the inequality relations used in the model.
#' @keywords MCMC, Inverse Modeling, Ecosystem, CCELIM
#' @importFrom XLConnect loadWorkbook saveWorkbook createSheet writeWorksheet readWorksheet
#' @export
#' @examples ReadModel(7, 4, 32)
#' 
ReadModel = function(file="./inst/extdata/Example.xls", file2='.inst/extdata/Example_data.xls', cycle=1, sheet.name=NULL, num.flows, num.exact=NULL, num.approx=NULL, num.ineq=NULL) {
    library(XLConnect)
    if(is.na(num.flows)) stop("Number of flows required")
    
    ## Setup environment
    WB = loadWorkbook(file)
    WB2 = loadWorkbook(file2)   # Contains the b vector(s)
    
    ## Read in the model
    start_cell = c(5,6)
    sheet = readWorksheet(WB, sheet=sheet.name, start_cell[1], start_cell[2] ,start_cell[1]+num.flows, start_cell[2]+sum(num.approx,num.exact,num.ineq)+1, colTypes="numeric" )
    flows = as.vector(readWorksheet(WB, sheet=sheet.name, start_cell[1], 1, start_cell[1]+num.flows, 1, colTypes="character" ))
    sheet = data.matrix(sheet)
    
    ## Read in the Data
    data.sheet = readWorksheet(WB2, sheet='Data', 5, cycle*2+2, 5+num.approx+num.exact+num.ineq, cycle*2+3,  colTypes='numeric')
    data.sheet = data.matrix(data.sheet)
    
    ## Setup A matricies
    if (num.exact > 0) {
        Ae = t(sheet[1:num.flows,1:num.exact])
        be = data.sheet[1:num.exact, 1]
    } else cat('\nWarning: Package is designed to use all three matrix equations, without them unexacted behaviour may arise.\n')
    if (num.approx > 0) {
        Aa = t(sheet[1:num.flows,(num.exact+1):(num.exact+num.approx)])
        ba = data.sheet[(num.exact+1):(num.exact+num.approx), 1]
        sdb = data.sheet[(num.exact+1):(num.exact+num.approx), 2]
    } else cat('\nWarning: Package is designed to use all three matrix equations, without them unexacted behaviour may arise.\n')
    
    ##G matrix includes diagonal (so h also needs values)
    if (num.ineq  > 0) {
        G = sheet[1:num.flows,(num.exact+num.approx+1):(num.approx+num.exact+num.ineq)]
        G = t(cbind(G, diag(num.flows)))
        h = data.sheet[(num.exact+num.approx+1):(num.approx+num.exact+num.ineq), 1]
        for (i in c(1:num.flows)) h[i+num.ineq] = 0
    } else cat('\nWarning: Package is designed to use all three matrix equations, without them unexacted behaviour may arise.\n')
    
    ## Package up model
    model=NULL
    model$flows = flows
    model$cycle = cycle ##TODO change naming scheme.
    model$Aa = Aa
    model$ba = ba
    model$Ae = Ae
    model$be = be
    model$G = G
    model$h = h
    model$sdb = sdb
    
    return(model)
}