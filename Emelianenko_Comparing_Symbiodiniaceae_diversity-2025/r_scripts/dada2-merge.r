library("dada2")
packageVersion("dada2")
library("ShortRead")
packageVersion("ShortRead")
library(Biostrings)
packageVersion("Biostrings")
library("ggplot2")
packageVersion("ggplot2")

### Join each run into a single sequence table
run1 <- readRDS("run1.rds")
run2 <- readRDS("run2.rds")
run3 <- readRDS("run3.rds")
complete_seqtab <- mergeSequenceTables(run1, run2, run3)
saveRDS(complete_seqtab, "complete_seqtab_run1-2-3.rds")

seqtab.nochim <- removeBimeraDenovo(complete_seqtab, method = "consensus", multithread=TRUE, verbose=TRUE)
saveRDS(seqtab.nochim, "seqtab.nochim_run1-2-3.rds")

print("Calculating sum(seqtab.nochim)/sum(complete_seqtab)")
sum(seqtab.nochim)/sum(complete_seqtab)

write.table(seqtab.nochim , 'seqtab_nochim_run1-2-3.txt', sep="\t", quote=F)

# explore distribution of sequence length after chimera removal
table(nchar(getSequences(seqtab.nochim)))
pdf('Distribution_of_sequence_lengths_seqtab_nochim_run1-2-3.pdf')
hist(nchar(getSequences(seqtab.nochim)), main="Distribution of sequence lengths no chimeras")
dev.off()

# giving our seq headers more manageable names (ASV_1, ASV_2...)
asv_seqs <- colnames(seqtab.nochim)
asv_headers <- vector(dim(seqtab.nochim)[2], mode="character")

for (i in 1:dim(seqtab.nochim)[2]) {
  asv_headers[i] <- paste(">ASV", i, sep="_")
}

# making and writing out a fasta of our final ASV seqs:
asv_fasta <- c(rbind(asv_headers, asv_seqs))

write(asv_fasta, 'ASVs_run1-2-3.fasta')

# count table:
asv_tab <- t(seqtab.nochim)
row.names(asv_tab) <- sub(">", "", asv_headers)
write.table(asv_tab, 'ASVs_counts_run1-2-3.txt', sep="\t", quote=F)

save.image(file = "dada2-ASV_workspace.RData")
