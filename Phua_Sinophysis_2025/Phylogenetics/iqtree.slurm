#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-5
#SBATCH --mem=2G
#SBATCH -c 1
#SBATCH -n 1
#SBATCH --job-name=iqtree
#SBATCH --output=iqtree.out

work_dir=/flash/HusnikU/Phua_2/20250409_nisea_16S

sample=/flash/HusnikU/Phua_2/20250409_nisea_16S/nis_16S.fasta.mafft.end_trim.fa

ml bioinfo-ugrp-modules
ml load Other/iqtree

iqtree2 -m MFP -st DNA -s $sample -b 1000 -T AUTO


