#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=decon
#SBATCH --output=decon.o%j
#SBATCH --error=decon.e%j
#SBATCH --time=95:00:00
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=96
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=jinyeong.choi@oist.jp

#mkdir /flash/HusnikU/Jinyeong/Spades_decon
cd /flash/HusnikU/Jinyeong/Spades_decon

#module load R/4.0.4
module load bioinfo-ugrp-modules
module load singularity/3.5.2
module load DebianMed/11.2

export LD_PRELOAD=~/miniforge3/lib/libstdc++.so.6

export PATH="/apps/unit/BioinfoUgrp/Other/BUSCO/5.1.3/:$PATH"

source /home/j/jinyeong-choi/miniforge3/bin/activate

Rscript /flash/husniku/jinyeong/decon/DeCon_pipeline.R /flash/husniku/jinyeong/decon/DeCon_main.R /flash/husniku/jinyeong/decon/DeCon_main.py /flash/husniku/jinyeong/decon/DeCon.conf.R

