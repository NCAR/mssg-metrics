

weeks     <- c(1, 4, 8, 12, 52, 260)
filesRead <- c(5934064, 1565505, 1082212, 948398, 4924518, 2767200)

cumFilesRead    <- vector("integer")
cumFilesRead[1] <- filesRead[1]
for (i in 2:length(filesRead)) {
	cumFilesRead[i] <- cumFilesRead[i - 1] + filesRead[i]
}

cumPercRead <- cumFilesRead/cumFilesRead[length(cumFilesRead)]

par(mfrow = c(1, 2))
plot(weeks, cumPercRead, xlim=c(1, 52), ylim=c(0., 1.), type="l")
plot(weeks, cumPercRead, xlim=c(1, 52), ylim=c(0., 1.), log="x", type="l")
