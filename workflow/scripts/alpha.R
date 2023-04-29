richness <- function(x){
  sum(x>0)
}

shannon <- function(x){
  rabund <- x[x>0]/sum(x) 
  -sum(rabund * log(rabund))
}

simpson <- function(x){
  n <- sum(x)
  sum(x * (x-1) / (n * (n-1)))
  
}

rarefy <- function(x, sample){
  
  x <- x[x>0]
  sum(1-exp(lchoose(sum(x) - x, sample) - lchoose(sum(x), sample)))
  
}