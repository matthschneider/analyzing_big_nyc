library(datadr)
library(parallel)

options(defaultLocalDiskControl = localDiskControl(makeCluster(2)))

irisD <- iris
irisD$Sepal <- as.numeric(irisD$Sepal.Length > median(irisD$Sepal.Length))
rrIris <- divide(irisD, by=rrDiv(40))


b_mr <- NULL

mapLogit <- expression({
  v <- do.call(rbind, map.values)
  y <- v$Sepal
  x <- as.matrix(cbind(v$Sepal.Width, v$Petal.Length, v$Petal.Width))
  t <- c(1:length(y))
  if (is.null(b_mr)) {
    mu <- (y+.5)/2
    xb <- log(mu/(1-mu))
  } else {
    xb <- b_mr[1]+b_mr[2]*x[1]+b_mr[3]*x[2]+b_mr[4]*x[3]
    mu <- 1/(1+exp(-xb))
  }
  #browser()
  w <- (mu*(1-mu))
  z <- xb + (y - mu) * (1/w)
  ones <- seq(1, 1, length.out = length(y))
  X <- matrix(c(ones, x, z), ncol=3)
  wss <- t(X) %*% (w*X)
  #browser()
  collect("key", wss)
})

reduceLogit <- expression(
  pre = {
    old <- 0
  }, reduce = {
    new <- do.call(rbind, reduce.values)
    new <- as.matrix(new)
    old <- old + new
    M <- old
    XtWX <- M[1:nrow(M)-1,1:ncol(M)-1]
    XtWY <- M[1:nrow(M)-1,ncol(M)]
    b <- solve(XtWX, XtWY)
  }, post = {
    collect(reduce.key, b)
  }
)

#testLogit <- mrExec(rrIris, map = mapLogit, reduce = reduceLogit, params = c(b_mr = b_mr))

b_mr <- NULL

for (i in 1:5){
  b_old = b_mr

  testLogit <- mrExec(rrIris, map = mapLogit, reduce = reduceLogit, params = c(b_mr = b_mr))
  
  a <- unlist(testLogit[1])
  b_mr <- c(as.numeric(a[2]), as.numeric(a[3]), use.names=F)

  if (!is.null(b_old) && 
  any(abs(b_mr-b_old) > 1e-6 * abs(b_old))) break
}
