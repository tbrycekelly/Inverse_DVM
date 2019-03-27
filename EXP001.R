suppressMessages(library(CCELIM))
options(echo=TRUE) # if you want see commands in output file
args <- commandArgs(trailingOnly = TRUE)


source('settings.r')
name = paste('EXP001-', args[1], sep='')
cycle = as.integer(args[1])
jmp = jmp[cycle]

model = ReadModel("./input/Model.xls", "./input/Constraints.xls", model.name="Subduction", constraint.name = 'Data001', cycle, 141, 24, 18, 138)
model$G[model$G == 24.24] = -resp.f[cycle]
model$G[model$G == 27.27] = -resp.f[cycle]

SaveModel(model, name)
res = RunModel(model, iter = iter, out.length = out.length, burn.length = burn.length, jmp = jmp)
SaveSolution(res, name)

notify(name)
