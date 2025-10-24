#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=predada2
#SBATCH --time=2-0
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --output=predada2-%j_out.txt
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

ml load R/4.2.1
Rscript predada2_run1.r
Rscript predada2_run2.r
Rscript predada2_run3.r
