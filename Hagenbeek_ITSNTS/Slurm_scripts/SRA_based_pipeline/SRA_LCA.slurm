#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_LCA_%a.out
#SBATCH -t 4-0
#SBATCH --mem=128G
#SBATCH -c 64


ml bioinfo-ugrp-modules
ml DebianMed
ml kraken2

readarray -t a < $1
outdir=$2

#Run Kraken2
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Kraken2
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Kraken2
kraken2 --db /bucket/HusnikU/Databases/Kraken2_standard/ --threads 64 --output - --paired --report ./Report.tsv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq

#Run Metabuli
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabuli
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabuli
source $3
conda activate $4
metabuli classify ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq /bucket/HusnikU/Databases/Metabuli_prebuilt_GTDB/gtdb/ . ${a[${SLURM_ARRAY_TASK_ID}]} --seq-mode 2 --threads 64 --max-ram 120
rm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabuli/*_classifications.tsv