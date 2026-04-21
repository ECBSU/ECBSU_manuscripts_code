#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=seqkit_stats
#SBATCH --time=2-0
#SBATCH --mem=10G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --output=seqkit_primer_start_check-%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

module purge # make sure no modules are loaded
module load bioinfo-ugrp-modules
module load DebianMed/12.0
module load seqkit/2.3.1+ds-1+b4

path="/flash/HusnikU/Vera/Symbiodiniaceae/concat"

seqkit stats --basename --tabular ${path}/*fastq.gz> concat_stats.txt
