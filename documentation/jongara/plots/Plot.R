
library( pspline )


results <- read.csv( "/tmp/results.csv" )
plot( results$x, results$y, type = "o" )

x1 <- results$x[1]
y1 <- results$y[1]

#points( x1, y1, pch = 19, col = "green", cex = 1.5)


#results.spl <- sm.spline(results$x, results$y)
#results.spl <- smooth.Pspline(results$x, results$y, method = 3)
#lines(results.spl, col = "blue")
#lines(sm.spline(results$x, results$y, df=10), lty=1, col = "red")


