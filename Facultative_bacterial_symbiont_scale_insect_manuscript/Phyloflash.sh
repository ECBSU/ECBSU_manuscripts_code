# Phyloflash

conda activate pf # If Conda environment not already activated
phyloFlash.pl -dbhome /path/to/138.1 -lib TEST -CPUs 16 \
 -read1 ${CONDA_PREFIX}/lib/phyloFlash/test_files/test_R1.fastq.gz \
 -read2 ${CONDA_PREFIX}/lib/phyloFlash/test_files/test_R2.fastq.gz \
 -almosteverything
