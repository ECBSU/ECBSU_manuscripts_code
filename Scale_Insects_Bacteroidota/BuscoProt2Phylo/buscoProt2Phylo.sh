#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=buscoProt2Phylo
#SBATCH --output=buscoProt2Phylo.o%j
#SBATCH --error=buscoProt2Phylo.e%j
#SBATCH --time=95:00:00
#SBATCH --mem=400G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=128
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jinyeong.choi@oist.jp

source ~/.bashrc
module load R/4.0.4
module load bioinfo-ugrp-modules
module load singularity/3.5.2
module load DebianMed/11.2
module load mafft/7.305

Rscript /home/j/jinyeong-choi/sbatch_buscoProt2Phylo/buscoProt2Phylo_pipeline.R /home/j/jinyeong-choi/sbatch_buscoProt2Phylo/buscoProt2Phylo_main.R /home/j/jinyeong-choi/sbatch_buscoProt2Phylo/buscoProt2Phylo_conf.R
