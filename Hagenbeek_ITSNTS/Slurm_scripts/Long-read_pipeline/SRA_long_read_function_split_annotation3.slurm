#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_long_read_function_split3_%a.out
#SBATCH -t 2-0
#SBATCH --mem=32G
#SBATCH -c 16

ml bioinfo-ugrp-modules
ml DebianMed
ml kraken2

readarray -t a < <(cut -d';' -f1 $1)
outdir=$2

cd ${outdir}/${a[${7}]}/Metagenome_KEGGstimate/
#Remove unused files
rm *.gff
rm *.hits
rm *.genepred.fasta
rm *.seed_orthologs
#Concatenate all split files into a single merged annotation
cat *.annotations > ${a[${7}]}_merged_annotations

python $3 ${outdir}/${a[${7}]}/Metagenome_KEGGstimate/${a[${7}]}_merged_annotations ${outdir}/${a[${7}]}/Metagenome_KEGGstimate/${a[${7}]%.*}.emapper.annotations $4
python $5 ${outdir}/${a[${7}]}/Metagenome_KEGGstimate/${a[${7}]}_merged_annotations ${outdir}/${a[${7}]}/Metagenome_KEGGstimate/${a[${7}]%.*}.fasta.emapper.annotations_pathway_and_BRITE $6
