# GitHub Repo for "The Importance of Mesozooplankton Diel Vertical Migration for Sustaining a Mesopelagic Food Web"

This repository is an online supplemental for an article submitted to **Frontiers In Marine Science**, which contains additional documentation, source code and supplemental resourses. The goal of quality science is to permit the verification and inspection of published findings.

### Abstract
We used extensive ecological and biogeochemical measurements obtained from quasi-Lagrangian experiments during two California Current Ecosystem Long-Term Ecosystem Research cruises to analyze carbon fluxes between the epipelagic and mesopelagic zones using a linear inverse ecosystem model (LIEM). Measurement constraints on the model include 14C primary productivity, dilution-based microzooplankton grazing rates, gut pigment-based mesozooplankton grazing rates (on multiple zooplankton size classes), 234Th:238U disequilibrium and sediment trap measured carbon export, and metabolic requirements of micronekton, zooplankton, and bacteria. A likelihood approach (Markov Chain Monte Carlo) was used to estimate the resulting flow uncertainties from a sample of potential flux networks. Results highlight the importance of mesozooplankton active transport (i.e., diel vertical migration) for supplying the carbon demand of mesopelagic organisms and sequestering carbon dioxide from the atmosphere. In nine water parcels ranging from a coastal bloom to offshore oligotrophic conditions, mesozooplankton active transport accounted for 18% - 84% (median: 42%) of the total carbon supply to the mesopelagic, with gravitational settling of POC (12% - 55%; median: 37%) and subduction (2% - 32%; median: 14%) providing the majority of the remainder. Vertically migrating zooplankton contributed to downward carbon flux through respiration and excretion at depth and via consumption loses to predatory zooplankton and mesopelagic fish (e.g. myctophids and gonostomatids). Sensitivity analyses showed that the results of the LIEM were robust to changes in nekton metabolic demands, rates of bacterial production, and mesozooplankton gross growth efficiency. This analysis suggests that prior estimates of zooplankton active transport based on conservative estimates of standard (rather than active) metabolism should be revisited. 



​		A full text preprint can be found [here](Preprint.pdf) (BioRxiv).

---

# Directory

**[BIN](<https://github.com/tbrycekelly/Inverse_DVM/tree/master/BIN>)** - Contains R script files used for in the model. It contains a copy of *Xsample.R* and *Mirror.R* from the excellent R package **limSolve** ([Cran](<https://cran.r-project.org/web/packages/limSolve/index.html>)). 



**[Input](<https://github.com/tbrycekelly/Inverse_DVM/tree/master/Input>)** - Contains the matrices used in the model (i.e. the actual data). The matrices are partitioned into two excel files:

1. [Constraints.xls](https://github.com/tbrycekelly/Inverse_DVM/blob/master/Input/Constraints.xls) - A file containing the b, f, h and sdb vectors.
2. [Model.xls](https://github.com/tbrycekelly/Inverse_DVM/blob/master/Input/Model.xls) - A file containing the A, E & G matrices of the linear inverse model. This includes the mass balance equations, approximate equalities and inequality equations.



## Usage

The general workflow for solving an LIEM using limSolve consists of two steps: the setup of the model and the running of the model.

```R
model = ReadModel('Model.xls', 'Constraints.xls',
					num.flows = 141, num.exact = 24,
                    num.approx = 18, num.ineq = 138)
                    
result = RunModel(model, iter = 1e8, out.length = 1e5, burn.length = 1e8, jmp = 1.2)
```



Before the model can be run, there are several prerequisites. 

**Libraries**

* limSolve
* MASS
* XLConnect



**Dealing with Odds & Ends**

In order to allow the matrices to be adjusted when required on a cycle-by-cycle basis I included several flagged values that could be easily replaced (e.g. the entry "24.24" in matrix G was replaced by a respiration specific term that changed each cycle). 

```R
## Cycle specifics
jmp = 1.5
iter = 1e7
out.length = 10000
burn.length = 1e7
resp.f = 1.37

## Read in model
model = ReadModel("./input/Model.xls", "./input/Constraints.xls",
                  model.name="Subduction", constraint.name = 'Data001',
                  cycle, 141, 24, 18, 138)

## Odds & Ends (substitude values in G)
model$G[model$G == 24.24] = -resp.f
model$G[model$G == 27.27] = -resp.f

## Run model
res = RunModel(model, iter = iter, out.length = out.length,
               burn.length = burn.length, jmp = jmp)
```

---



# Contact Us

If you wish to learn more about inverse modeling or need help getting any of this code to work, please don't hesitate to reach out to us at tbk14@fsu.edu or mstukel@fsu.edu. While the code here is a special case, we have additional, generalized code for solving inverse problems elsewhere (e.g. [15N-inclusive LIEM](<https://github.com/tbrycekelly/N15-LIM>)).



You can also learn more about our research here ([Stukel Lab](<http://myweb.fsu.edu/mstukel/>)) or here ([TBK](http://about.tkelly.org)).

