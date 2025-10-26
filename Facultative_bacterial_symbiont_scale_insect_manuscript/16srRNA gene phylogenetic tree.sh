# phylogenetic trees


# phyloflash

conda activate pf # If Conda environment not already activated
phyloFlash.pl -dbhome /path/to/138.1 -lib TEST -CPUs 16 \
 -read1 ${CONDA_PREFIX}/lib/phyloFlash/test_files/test_F.fq.gz \
 -read2 ${CONDA_PREFIX}/lib/phyloFlash/test_files/test_R.fq.gz \
 -almosteverything
 -trusted contigs.fasta

# Mafft

mafft --reorder --adjustdirection --anysymbol --auto input.fasta 

#trimal

trimal -in <inputfile> -out <outputfile> -automated1

#iqtree

path_to_iqtree -s 16S_mafft_trimal.fasta -m TEST -bb 1000 -alrt 1000
