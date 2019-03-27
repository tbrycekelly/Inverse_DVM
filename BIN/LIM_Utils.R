#' Norm
#'
#' This function calculates X * X.
#' @param A B E F G H
#' @keywords xsample, mirror, MCMC, Monte Carlo, Markov Chain
#' @examples norm()
#' 
norm <- function(x) return(sqrt(x%*%x))

#' SSR
#'
#' This function calculates the difference of the sum of the squared residuals.
#' @param q1 The prior solution
#' @param q2 The proposed solution
#' @param a The matrix
#' @param b The goal solution
#' @keywords xsample, mirror, MCMC, Monte Carlo, Markov Chain
#' @examples SSR()
#' 
SSR <- function(q1, q2, a, b) return(sum({a%*%q2-b}^2)-sum({a%*%q1-b}^2))
