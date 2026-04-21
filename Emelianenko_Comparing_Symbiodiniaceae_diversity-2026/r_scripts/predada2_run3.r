library("dada2")
packageVersion("dada2")
library("ShortRead")
packageVersion("ShortRead")
library(Biostrings)
packageVersion("Biostrings")

path <- "/flash/HusnikU/Vera/Symbiodiniaceae/raw_seq/run3"

list.files(path) # this is optional, to see if the path is ok. When run as .r script, it will print the output in predada2-%j_out.txt.

# create matching lists of forward and reverse reads
fnFs <- sort(list.files(path, pattern = "_R1_001.fastq.gz", full.names = TRUE))
fnRs <- sort(list.files(path, pattern = "_R2_001.fastq.gz", full.names = TRUE))

# identify primers
FWD <- "GTGAATTGCAGAACTCCGTG"  
REV <- "CCTCCGCTTACTTATATGCTT"  


allOrients <- function(primer) {
    # Create all orientations of the input sequence
    require(Biostrings)
    dna <- DNAString(primer)  # The Biostrings works w/ DNAString objects rather than character vectors
    orients <- c(Forward = dna, Complement = Biostrings::complement(dna), Reverse = Biostrings::reverse(dna),
        RevComp = Biostrings::reverseComplement(dna))
    return(sapply(orients, toString))  # Convert back to character vector
}
FWD.orients <- allOrients(FWD)
REV.orients <- allOrients(REV)
FWD.orients

# the output should be
# Forward Complement Reverse RevComp
# "GTGAATTGCAGAACTCCGTG" "CACTTAACGTCTTGAGGCAC" "GTGCCTCAAGACGTTAAGTG" "CACGGAGTTCTGCAATTCAC"

#Prefilter the sequences to remove Ns

#create file lists with the filtN subdirectory

fnFs.filtN <- file.path(path, "filtN", basename(fnFs)) # Put N-filtered files in filtN/ subdirectory

fnRs.filtN <- file.path(path, "filtN", basename(fnRs))

# Perform filtering to remove Ns (maximum Ns allowed is 0)
filterAndTrim(fnFs, fnFs.filtN, fnRs, fnRs.filtN, maxN = 0, multithread = TRUE)

primerHits <- function(primer, fn) {
    # Counts number of reads in which the primer is found
    nhits <- vcountPattern(primer, sread(readFastq(fn)), fixed = FALSE)
    return(sum(nhits > 0))
}
rbind(FWD.ForwardReads = sapply(FWD.orients, primerHits, fn = fnFs.filtN[[1]]), FWD.ReverseReads = sapply(FWD.orients,
    primerHits, fn = fnRs.filtN[[1]]), REV.ForwardReads = sapply(REV.orients, primerHits,
    fn = fnFs.filtN[[1]]), REV.ReverseReads = sapply(REV.orients, primerHits, fn = fnRs.filtN[[1]]))

# Filenames inside concat/filtN/ will be the same as original filenames, so it is important to keep the directories ordered
# Next step is to run cutadapt on our N-filtered reads

save.image(file = "predada2_run3_workspace.RData")
# save workspace image to have access to all of the objects such as filename lists and primer seqs
