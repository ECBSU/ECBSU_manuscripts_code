#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-0
#SBATCH --mem=15G
#SBATCH -c 32
#SBATCH -n 1
#SBATCH --job-name=deeploc
#SBATCH --output=deeploc.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yong.phua@oist.jp

source /home/y/yong-phua/conda_ini.sh 
conda activate deeploc
module load ruse

ruse deeploc2 -f /bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/clean_transcriptome/sino_transcriptome_SL1234/trinotate/top_prot_sort.fas -o /flash/HusnikU/Phua_2/sino_transcriptome_loc -m Accurate