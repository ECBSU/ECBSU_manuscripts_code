#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_long_read_function_split2_%a.out
#SBATCH -t 4-0
#SBATCH --mem=128G
#SBATCH -c 64


ml bioinfo-ugrp-modules
ml DebianMed
ml kraken2

cd ${1}
a=(*_trimmed_split*.fasta)
pwd
${a[${SLURM_ARRAY_TASK_ID}]}
#Run whokaryote to filter out contaminating eukaryote contigs
source $2
conda activate $3
mkdir Whokaryote_${a[${SLURM_ARRAY_TASK_ID}]%.*}
cd Whokaryote_${a[${SLURM_ARRAY_TASK_ID}]%.*}
pwd
whokaryote.py --contigs ${1}/${a[${SLURM_ARRAY_TASK_ID}]} --minsize 1000 --outdir . --f --threads 64
#mv eukaryotes.fasta ${1}/${a[${SLURM_ARRAY_TASK_ID}]%.*}_whokaryote_eukaryotes.fa
mv prokaryotes.fasta ${1}/${a[${SLURM_ARRAY_TASK_ID}]%.*}_whokaryote_prokaryotes.fa
cd ${1}
rm -r Whokaryote_${a[${SLURM_ARRAY_TASK_ID}]%.*}

#Annotate the prokaryote contigs with KEGGstimate
conda activate $4
mkdir ${1}/Metagenome_KEGGstimate
emapper.py -m mmseqs --mmseqs_db $5 --data_dir $6 -i ${1}/${a[${SLURM_ARRAY_TASK_ID}]%.*}_whokaryote_prokaryotes.fa --itype metagenome -o ${1}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]%.*}_whokaryote_prokaryotes.fa --cpu 64 --dbmem

#Remove the split fasta files
rm ${1}/${a[${SLURM_ARRAY_TASK_ID}]]%.*}_whokaryote_prokaryotes.fa