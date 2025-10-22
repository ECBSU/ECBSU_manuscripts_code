#!/bin/bash

#SBATCH -p compute
#SBATCH -t 0-3
#SBATCH --mem=48G
#SBATCH -c 16
ml bioinfo-ugrp-modules
source /home/y/yong-phua/conda_ini.sh
conda activate blobtools

/hpcshare/appsunit/HusnikU/ncbi-blast-2.11.0+/bin/blastx -query  /bucket/.deigo/HusnikU/Unit_Members/Phua/Sino_prj/Sino_genome/Sinophysis_pooled_cells_spades/scaffolds.fasta -db /flash/HusnikU/Phua_2/sino/sino_genome_nano/result_2025-06-02.fasta -outfmt 6 -evalue 1e-5 -num_threads 16 -max_target_seqs 1 > blastx_hits.out

awk '{print $1}' /flash/HusnikU/Phua_2/sino/sino_genome_nano/blastx_hits.out | grep -Ff - /bucket/.deigo/HusnikU/Unit_Members/Phua/Sino_prj/CyanoGenome/blobDB.table.txt > blastx_taxa.tsv
grep Cyanob '/flash/HusnikU/Phua_2/sino/sino_genome_nano/blastx_taxa.tsv' > '/flash/HusnikU/Phua_2/sino/sino_genome_nano/blastx_cyanob.tsv'

# Files compared with bamfilter list, 2 entries not included were sent for taxa confirmtion using blastx
Blastx (server) with cyanobacteria taxa limitation > /flash/HusnikU/Phua_2/sino/sino_genome_nano/3ZN81ASH013-Alignment.txt
