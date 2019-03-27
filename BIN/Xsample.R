#' MCMC.sample()
#'
#' @param A A matrix containing all the approximate equations.
#' @param B A vector containing all the measured values.
#' @param E A matrix containing all the exact equations.
#' @param F A vector containing the solutions to the exact equations.
#' @param G A matrix containing all the inequality relations.
#' @param H A vector containing the solutions to the inequality relations.
#' @param sdB The vector containing the uncertainty of the B vector in terms of SD. A minimum, relative uncertainty of 0.1 percent is applied to all values (i.e. B value of 10+/-0 will be changed to +/- 0.01).
#' @param iter The number of steps for the simulation to run for.
#' @param outputlength The total number of output solutions to save for analysis. A solution is saved very iter/outputlength steps.
#' @param burn.length The number of steps to take before starting to sample the solutions.
#' @param jmp A measurement of length taken between steps. Smaller values yield a higher percentage of excepted solutions but slower convergence. Aim for a value which yields an acceptance ratio of ~0.234
#' @param x0 An inital solution to start from. Useful for restarting a simulation from a particular point.
#' @param test 
#' @param verbose A boolean switch to turn on or off the progress counter.
#' @keywords xsample, mirror, MCMC, Monte Carlo, Markov Chain
#' @import MASS limSolve digest
#' @examples MCMC.Sample()

MCMC.Sample <- function(A=NULL, B=NULL, E=NULL, F=NULL, G=NULL, H=NULL,
                        sdB=NULL, iter=3000, outputlength=100,
                        burn.length=1000, jmp=1, x0=NULL, test=TRUE, verbose=TRUE)     {
    tol=sqrt(.Machine$double.eps)
    which <- function(x) .Internal(which(x)) ## Slight performance gain to specify the particular function to call.
    
    ## conversions vectors to matrices and checks
    if (is.data.frame(A)) A <- as.matrix(A)
    if (is.data.frame(E)) E <- as.matrix(E)
    if (is.data.frame(G)) G <- as.matrix(G)
    if (is.vector(A)) A <- t(A)
    if (is.vector(E)) E <- t(E)
    if (is.vector(G)) G <- t(G)
    
        lb <- length(B)
        lx <- ncol(A)
        ## system overdetermined?
        M <- rbind(cbind(A,B),cbind(E,F))
        overdetermined <- !qr(M)$rank<=lx
        if (overdetermined)
        {
            stop("The given linear problem is overdetermined. A standard deviation for the data vector B is incorporated in the MCMC as a model parameter.")
        } else {
            w = which(sdB < B*0.01)    ## Let's assume any measuremernt has a minimum uncertainty of 0.1% 
            sdB[w] = B[w]*0.01
            cat('Adjusted sdb values on ', length(w), ' of the approximate equations.\n')
            if (overdetermined) warning("The given linear problem is overdetermined. Giving fixed standard deviations for the data vector B can lead to dubious results. Maybe you want to set sdB=NULL and estimate the data error.")
            if (!length(sdB)%in%c(1,lb)) stop("sdB does not have the correct length")
            #if (any(sdB == 0)) stop("Cannot have a standard deviation of 0. Please correct sdb vector values.")
            A <- A/sdB
            B <- B/sdB					 # set sd = 1 in Ax = N(B,sd)
        }
    
    ## find a particular solution x0
    if (is.null(x0))
    {
        l <- limSolve::lsei(A=A,B=B,E=E,F=F,G=G,H=H,type=2)
        if (l$residualNorm>1e-6) stop("no particular solution found;incompatible constraints")
        else x0 <- l$X
    }
    
    lx <- length(x0)
    xv <- varranges(E,F,G,H,EqA=G)
    ii <- which (xv[,1]-xv[,2]==0)
    if (length(ii)>0)
    { # if they exist: add regular equalities !
        E	 <- rbind(E,G[ii,])
        F	 <- c(F,xv[ii,1])
        G	 <- G[-ii,]
        H	 <- H[-ii]
        if (length(H)==0)
            G <- H <- NULL
    }
    cat('Checking for hidden equalities.\n')
    xr <- xranges(E,F,G,H)
    ii <- which (xr[,1]-xr[,2]==0)
    if (length(ii)>0) 
    { # if they exist: add regular equalities !
        dia <- diag(nrow=nrow(xr))
        E	 <- rbind(E,dia[ii,])
        F	 <- c(F,xr[ii,1])
    }
    
    Z <- Null(t(E))
    Z[abs(Z)<tol] <- 0	 #x=x0+Zq ; EZ=0
    
    if (length(Z)==0)	 
    {
        warning("the problem has a single solution; this solution is returned as function value")
        return(x0)
    }
    k <- ncol(Z)
    
    g <- G%*%Z
    h <- H-G%*%x0																						 #gq-h>=0
    g[abs(g)<tol] <- 0
    h[abs(h)<tol] <- 0

    a <- A%*%Z
    b <- B-A%*%x0									#aq-b~=0
    v <- svd(a,nv=k)$v								#transformation q <- t(v)q for better convergence
    a <- a%*%v										#transformation a <- av
    if (!is.null(G)) g <- g%*%v						#transformation g <- gv
    Z <- Z%*%v										#transformation Z <- Zv
    #save(Z, 'Z.rdat')
    
    outputlength = min( outputlength, iter )
    ou = ceiling(iter/outputlength)
    cat('The step length between sampling the solution is: ', ou,'\n')
    q1 = rep(0,k)
    x = matrix(nrow=outputlength, ncol=lx, dimnames=list(NULL,colnames(A)))
    x[1,] = x0
    naccepted = 1
    name = digest(runif(1), algo='crc32')
    if(verbose==TRUE)
    {
        cat("\nStarting Burn-in - ", Sys.time(), '\n')
        pb = txtProgressBar(0, burn.length, style=3)
        for (i in 1:burn.length)	 
        {
            q2 <- mirror(q1,g,h,k,jmp)
            if ( exp(-0.5*{ SSR(q1, q2, a, b) }) > runif(1) ) 
            {
                q1 <- q2
                setTxtProgressBar(pb, i)
                if (i%%(burn.length/10) == 0) {
                    save(x, file=paste('./data/_temp_', name, '-burn.RData', sep='') )
                }
            }
        }
        save(x, file=paste('./data/_temp_', name, '.RData', sep='') )
        cat('\nStarting Random Walk - ', Sys.time(), '\n')
        pb = txtProgressBar(0, outputlength, style=3)
        for (i in 2:outputlength)
        {
            for (ii in 1:ou)
            {
                q2 <- mirror(q1,g,h,k,jmp)
                if ( exp(-0.5*{ SSR(q1, q2, a, b) }) > runif(1) )
                {
                    q1 <- q2
                    naccepted <- naccepted+1
                    if (ii%%(iter/10) == 0) {
                        save(x, file=paste('./data/_temp_', name, '-run.RData', sep='') )
                    }
                }
            }
            setTxtProgressBar(pb, i)
            x[i,] <- x0+Z%*%q1
        }
        close(pb)
    } else {        
        for (i in 1:burn.length)     {
            q2 <- mirror(q1,g,h,k,jmp)
            if ( exp(-0.5*{ SSR(q1, q2, a, b) }) > runif(1) ) {
                q1 <- q2
            }
        }
        for (i in 2:outputlength)	 {
            for (ii in 1:ou)	{
                q2 <- mirror(q1,g,h,k,jmp)
                if ( exp(-0.5*{ SSR(q1, q2, a, b) }) > runif(1) ) {
                    q1 <- q2
                    naccepted <- naccepted+1
                }
            }
            x[i,] <- x0+Z%*%q1
        }
    }
    xnames <- colnames(A)
    if (is.null(xnames)) xnames <- colnames(E)
    if (is.null(xnames)) xnames <- colnames(G)
    colnames (x) <- xnames
    
    xsample <- list(X=x,
                    acceptedratio=naccepted/iter,jmp=jmp, 
                    avg=apply(x, 2, mean),
                    sd=apply(x,2,sd),
                    iter=iter,
                    burnin=burn.length)
    return(xsample)
}