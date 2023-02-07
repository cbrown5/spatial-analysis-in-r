# A short script courtesy of Bill Venables that automates
# the search for theta in a neg bin model. 

m1 <- gam(richness ~ s(latitude, k = 5), family = poisson, dat_std)
c(deviance = deviance(m1), res_df = m1$df.residual)

m1 <- update(m1, family = negbin(theta = 2))       ### not quite enough
c(deviance = deviance(m1), res_df = m1$df.residual)

m1 <- update(m1, family = negbin(theta = 1))       ### a bit too much
c(deviance = deviance(m1), res_df = m1$df.residual)

fun <- function(theta) {
  m1 <- update(m1, family = negbin(theta = theta))
  m1$df.residual - deviance(m1)
}

(opt <- uniroot(fun, interval = c(1,2)))  ### can take a few seconds!

m1 <- update(m1, family = negbin(theta = 1.548))
c(deviance = deviance(m1), res_df = m1$df.residual)
