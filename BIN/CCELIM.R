#' LIM
#'
#' A top-level entrance point for running the model. Primarily designed as an example due to the lack of flexability when calling this script. Can be used to automate the running of the model.
#' 
#' @param name A list of the data sets to analyze. For each plot, the data saved in the files specified by l will be loaded and plotted.
#' @param iter The prefered output directory for the generated images. Include the final '/' on linux/mac and '\' on windows.
#' @param out.length The number of desired solutions to be saved.
#' @param burn.length The number of steps to take before running the model for real (i.e. saving solutions).
#' @param jmp The length of step to take between iterations of the model (should aim for an acceptance ratio of ~0.234)
#' @param cycle The Data set to be used for the running of the model.
#' @export
#' @examples LIM()
#' 
LIM = function(name = 'temp', iter = 1e6, out.length=1e4, burn.length = 1e5, jmp=1.3, cycle=1) {

    model = ReadModel('./input/EndToEnd2Layer_Model.xls','./input/EndToEnd2Layer_Data.xls', cycle, 'Model', 126, 25, 16, 89)
    SaveModel(model, name)
    res = RunModel(model, iter=iter, out.length=out.length, burn.length=burn.length, jmp=jmp)
    SaveSolution(res, name)

    SaveSpread(model, res, name)
    Analysis(as.vector(name))
}


