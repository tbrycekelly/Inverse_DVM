#' Mirror
#' This function is taken, nearly unaltered, from the limSolve package which can be found on CRAN.
#' @param q1
#' @param g
#' @param h
#' @param k
#' @param jmp
#' @keywords xsample, mirror, MCMC, Monte Carlo, Markov Chain
#' @examples mirror()
#' 
mirror <- function(q1,g,h,k=length(q),jmp)     {
    q2 <- rnorm(k,q1,jmp)
    residual <- g%*%q2-h
    q10 <- q1
    while (any(residual<0))	 {							#mirror
        epsilon <- q2-q10								#vector from q1 to q2: our considered light-ray that will be mirrored at the boundaries of the space
        w <- which(residual<0)							#which mirrors are hit?
        alfa <- {{h-g%*%q10}/g%*%epsilon}[w]	        #alfa: at which point does the light-ray hit the mirrors? g*(q1+alfa*epsilon)-h=0
        whichminalfa <- which.min(alfa)
        j <- w[whichminalfa]							#which smallest element of alfa: which mirror is hit first?
        d <- -residual[j]/sum(g[j,]^2)				    #add to q2 a vector d*Z[j,] which is oriented perpendicular to the plane Z[j,]%*%x+p; the result is in the plane.
        q2 <- q2+2*d*g[j,]								#mirrored point
        residual <- g%*%q2-h
        q10 <- q10+alfa[whichminalfa]*epsilon           #point of reflection
    
    }
    
    return(q2)
}