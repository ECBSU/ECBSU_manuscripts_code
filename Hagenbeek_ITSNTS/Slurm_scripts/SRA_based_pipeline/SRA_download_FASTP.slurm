#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_fastp_%a.out
#SBATCH -t 4-0
#SBATCH --mem=64G
#SBATCH -c 32


ml bioinfo-ugrp-modules
ml DebianMed
ml sra-toolkit

#Read which SRA files to download and analyze
#NOTE, if the array is not read properly, open the file and replace "\r\n" with "\n" or use dos2unix
readarray -t a < $1

#Generate output dir
outdir=$2
cd $outdir
mkdir ./${a[${SLURM_ARRAY_TASK_ID}]}
cd ./${a[${SLURM_ARRAY_TASK_ID}]}

#Download the fastq files
fasterq-dump --split-files ${a[${SLURM_ARRAY_TASK_ID}]}

#Trim the fastq files
ml fastp
fastp -i ${a[${SLURM_ARRAY_TASK_ID}]}_1.fastq -I ${a[${SLURM_ARRAY_TASK_ID}]}_2.fastq -o ${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq -O ${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq -w 32 -z 9

#Delete the raw fastq 
rm ${a[${SLURM_ARRAY_TASK_ID}]}_1.fastq
rm ${a[${SLURM_ARRAY_TASK_ID}]}_2.fastq
rm fastp*