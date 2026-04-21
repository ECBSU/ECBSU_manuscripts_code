library("dada2")
packageVersion("dada2")
library("ShortRead")
packageVersion("ShortRead")
library(Biostrings)
packageVersion("Biostrings")
library("ggplot2")
packageVersion("ggplot2")

load("/flash/HusnikU/Vera/Symbiodiniaceae/predada2_run2_workspace.RData")

# path with files that have been filtered to not contain Ns and trimmed from primers
path.cut <- file.path(path, "cutadapt")
fnFs.cut <- file.path(path.cut, basename(fnFs))
fnRs.cut <- file.path(path.cut, basename(fnRs))

# create file lists for files with trimmed adaptors
cutFs <- sort(list.files(path.cut, pattern = "_R1_001.fastq.gz", full.names = TRUE))
cutRs <- sort(list.files(path.cut, pattern = "_R2_001.fastq.gz", full.names = TRUE))
head (cutFs)

# create file list for the files that will be quality-filtered
filtFs <- file.path(path.cut, "filtered", basename(cutFs))
filtRs <- file.path(path.cut, "filtered", basename(cutRs))
head(filtFs)

#Check primer presence in cutadapted reads (should be none)
rbind(FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.cut[[1]]), FWD.ReverseReads = sapply(FWD.orients,
    primerHits, fn = fnRs.cut[[1]]), REV.ForwardReads = sapply(REV.orients, primerHits,
    fn = fnFs.cut[[1]]), REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.cut[[1]]))

# Extract sample names - first two parts separated by an underscore:
get.sample.name <- function(fname) {
  parts <- strsplit(basename(fname), "_")[[1]]
  paste(parts[1:2], collapse = "_")
}
sample.names <- unname(sapply(cutFs, get.sample.name))
head(sample.names)


# Trim with filtering parameters: no Ns (maxN=0) (should already be satisfied), truncQ = 2 (truncate reads at the first instance of a quality score less than or equal to 2), rm.phix = TRUE (remove matches to phix genome, bacteriophage genome commonly used as sequencing control), maxEE=2,4 (expected error in forward and reverse reads; here we expect maximum 2 errors in forward and 4 errors in reverse reads), minLen 50 (minimal length of 50 basepairs).

out <- filterAndTrim(cutFs, filtFs, cutRs, filtRs, maxN = 0, maxEE = c(2, 4), truncQ = 2,
    minLen = 50, rm.phix = TRUE, compress = TRUE, multithread = TRUE)  # on windows, set multithread = FALSE
head(out)

# check how many reads were filtered out
filtered_out <- as.data.frame(out)
filtered_out[,3] <- filtered_out$reads.out*100/filtered_out$reads.in
write.table(filtered_out, 'filtered_out.txt', sep="\t", quote=F)

# learn error rates
errF <- learnErrors(filtFs, multithread = TRUE)
errR <- learnErrors(filtRs, multithread = TRUE)

# sample inference
dadaFs <- dada(filtFs, err = errF, multithread = TRUE)
dadaRs <- dada(filtRs, err = errR, multithread = TRUE)

# merge paired reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)
# explore the dataset
head(mergers[[1]])

# construct sequence table (ASV table)
seqtab <- makeSequenceTable(mergers)
dim(seqtab)
write.table(seqtab, 'seqtab_run2.txt', sep="\t", quote=F)

# inspect distribution of sequence lengths
table(nchar(getSequences(seqtab)))
pdf('Distribution_of_sequence_lengths_seqtab.pdf')
hist(nchar(getSequences(seqtab)), main="Distribution of sequence lengths")
dev.off()

# save the sequence table 
saveRDS(seqtab, "run2.rds")
