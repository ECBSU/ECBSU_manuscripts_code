#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_megahit_phyloflash_%a.out
#SBATCH -t 4-0
#SBATCH --mem=500G
#SBATCH -c 128


ml bioinfo-ugrp-modules
ml DebianMed

#Read which files to analyze
readarray -t a < $1

outdir=$2
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/

#Assemble the trimmed fastq files
ml megahit
megahit -o ${a[${SLURM_ARRAY_TASK_ID}]}_megahit -1 ${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq -2 ${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq -t 128 -m 480
mv ${a[${SLURM_ARRAY_TASK_ID}]}_megahit/final.contigs.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta
rm -r ${a[${SLURM_ARRAY_TASK_ID}]}_megahit/


#Run phyloflash with megahit contigs
source $3
conda activate $4
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/phyloflash
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/phyloflash
$5 -dbhome /bucket/HusnikU/Databases/138.1/ -lib ${a[${SLURM_ARRAY_TASK_ID}]}_phyloflash -read1 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq -read2 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq -CPUs 128 -trusted ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta 
rm *.sam
rm *.fq
rm *.tblout
rm *.tar.gz
rm *.subsample.fasta
