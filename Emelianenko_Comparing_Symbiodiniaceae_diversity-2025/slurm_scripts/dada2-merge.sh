#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=dada2-merge
#SBATCH --time=2-0
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --output=dada2-merge-%j_out.txt
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

module load R/4.2.1
Rscript dada2-merge.r
