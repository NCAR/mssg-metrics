df <- read.csv("./db2-read-count-out-1.txt", header=FALSE)
counts <- df[df$V1 >= 1,]
png("read-count-dist.png")
hist(counts, xlim=c(0, 10), breaks=c(-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 200000), main="Distribution of File Read Counts Greater than Zero\n for All Files in HPSS as of 08June2015", xlab="read count", ylim=c(0., 1.))
dev.off()

df <- read.csv("./db2-read-count-prev-5-years-1-out.txt")
counts <- df[df$X0 >= 1,]
png("read-count-prev-5-years.png")
hist(counts, xlim=c(0, 10), breaks=c(-0.5, 0.5, 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5, 10.5, 200000), main="Distribution of File Read Counts Greater than Zero\n for Files Written between 08Jun2010 and 08Jun2015", xlab="read count", ylim=c(0., 1.))
dev.off()

