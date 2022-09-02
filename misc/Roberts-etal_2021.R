#----------------------------------------------------------------------------------
# Reproducing and extending the analysis presented in Roberts et al. (2021):
#  Roberts DL, Rossman JS, Jarić I (2021) 
#  Dating first cases of COVID-19. PLoS Pathog 17(6): e1009620. 
#  https://doi.org/10.1371/journal.ppat.1009620
#
# -> Take-Home message: 
# The estimated dates of origin change a lot with changes in the data. 
# With corrected datasets, the estimated origin is much later. 
#----------------------------------------------------------------------------------

# Data: 
# dates at which there is at least one onset date

# Date used by Roberts et al. 
datesHuang <- c("2019-12-01", "2019-12-10", "2019-12-15", "2019-12-17", "2019-12-18", 
                "2019-12-19", "2019-12-20", "2019-12-21", "2019-12-22", "2019-12-23")

# WHO 2021 data, after Worobey correction
datesWHOWorobey <- c("2019-12-10", "2019-12-11", "2019-12-12", "2019-12-13", "2019-12-15", 
                     "2019-12-16", "2019-12-17", "2019-12-18", "2019-12-19", "2019-12-20")

# WHO 2021 data
datesWHOraw <- c("2019-12-08", "2019-12-11", "2019-12-12", "2019-12-13", "2019-12-15", 
                 "2019-12-16", "2019-12-17", "2019-12-18", "2019-12-19", "2019-12-20")

# Other way to write the Huang et al. dates, for checks
tt <- rev(c(1, 10, 15, 17, 18, 19, 20, 21, 22, 23))
# Needs to be ordered from most recent to latest date
k <- length(tt) # Number of dates

## -------------------------------------------------------------------

# Functions

OLE.CC <- function(sights, alpha){
  # sights: vector needs to be ordered first
  # alpha: significance level, 0.1 for one-sided
  
  # This is part of the OLE.func function 
  # taken from https://github.com/cran/sExtinct
  k <- length(sights) # Number of observations
  # Compute nu
  v <- (1/(k-1)) * sum(log((sights[1] - sights[k])/(sights[1] - sights[2:(k-1)])))
  e <- matrix(rep(1, k), ncol=1)
  # 1/c(alpha)
  SL <- (-log(1-alpha/2)/length(sights))^-v
  SU <- (-log(alpha/2)/length(sights))^-v
  # Compute lambda matrix
  myfun <- function(i,j,v){(gamma(2*v+i)*gamma(v+j))/(gamma(v+i)*gamma(j))}
  lambda <- outer(1:k, 1:k, myfun, v=v)
  lambda <- ifelse(lower.tri(lambda), lambda, t(lambda)) # lambda is symmetrical
  # Compute a
  a <- as.vector(solve(t(e)%*%solve(lambda)%*%e)) * solve(lambda)%*%e
  # Compute CI
  lowerCI <- max(sights) + ((max(sights)-min(sights))/(SL-1))
  upperCI <- max(sights) + ((max(sights)-min(sights))/(SU-1))
  # Estimated date
  extest <- sum(t(a)%*%sights)
  res <- data.frame(Estimate=extest, lowerCI=lowerCI, upperCI=upperCI)
  res
}

# Function for OLE on emergence dates
OLE.emergence <- function(sights, endDate = as.Date("2019-12-31"), alpha){
  # sights: dates of the sights, YYYY-MM-DD
  # endDate: final date from which dates are calculated
  # alpha: significance level (multiply by 2 for one-sided)
  
  estim <- OLE.CC(rev(sort(as.numeric(endDate - as.Date(sights)))), alpha)
  data.frame(Estimate = endDate - estim[1, 1], 
             lowerCI = endDate - estim[1, 2], 
             upperCI = endDate - estim[1, 3])
}

# Checks
if(FALSE){
  # No need to evaluate this, these checks are just kept in case one wants to see them
  OLE.CC(sort(tt), 0.1)
  OLE.CC(rev(sort(tt)), 0.1)
  OLE.CC(sort(tt-max(tt)), 0.1)
  OLE.CC(rev(sort(max(tt)-tt)), 0.1) # -> correct one
  endDate <- as.Date("2019-12-31") 
  estim <- OLE.CC(rev(sort(as.numeric(endDate - as.Date(datesHuang)))), 0.1)
  endDate - estim[1, 1]
  endDate - estim[1, 3]
}

## -------------------------------------------------------------------

# Compute emergence dates
# With Huang et al. data
# alpha=0.1 because one-sided (they only reported earliest date)
OLE.emergence(datesHuang, alpha = 0.1)
# >     Estimate    lowerCI    upperCI
# > 1 2019-11-17 2019-11-23 2019-10-04
# -> same dates as given in the paper

# Now with the other datasets
OLE.emergence(datesWHOWorobey, alpha = 0.1)
# >     Estimate    lowerCI    upperCI
# > 1 2019-12-08 2019-12-09 2019-12-03

OLE.emergence(datesWHOraw, alpha = 0.1)
# >     Estimate    lowerCI    upperCI
# > 1 2019-12-04 2019-12-07 2019-11-24
