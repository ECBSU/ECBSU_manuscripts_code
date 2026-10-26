#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_binning1_%a.out
#SBATCH -t 4-0
#SBATCH --mem=128G
#SBATCH -c 32


#Creates the necessary alignment files, runs metabat,concoct, and semibin, and combines the results using dastools

#Load modules
ml bioinfo-ugrp-modules
ml samtools
ml bowtie2
ml metabat
ml DB/diamondDB/ncbi

readarray -t a < $1
outdir=$2
conda_ex=$3

#READ ALIGNMENT AND BAM FILE GENERATION
############################################
#Run bowtie for alignment
echo "-----------------------------------------------"
echo "Running Bowtie2"
echo "-----------------------------------------------"
bowtie2-build ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta  ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta_index
bowtie2 -x ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta_index -1 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq -2 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq -S ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.sam -p 8

#Sort and compress sam file into bam file
echo "-----------------------------------------------"
echo "Running samtools"
echo "-----------------------------------------------"
samtools sort -@ 32 -O BAM -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.sam
samtools index ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bai

#remove sam file and bowtie indices to save space
rm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.sam
rm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/*.bt2


#RUN METABAT
#############################################
#Create folder for metabat output (per sample)
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabat
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Metabat
#Create metabat coverage input, and run metabat
jgi_summarize_bam_contig_depths --outputDepth ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Metabat/${a[${SLURM_ARRAY_TASK_ID}]}_depth.txt ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam
echo "-----------------------------------------------"
echo "Running Metabat2"
echo "-----------------------------------------------"
metabat2 -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta -a ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Metabat/${a[${SLURM_ARRAY_TASK_ID}]}_depth.txt -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabat/Metabat -t 32


#RUN CONCOCT
#############################################
#Activate concoct conda env
source ${conda_ex}
conda activate $4
concoct -v
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct
#Run concoct and its associated python scripts
echo "-----------------------------------------------"
echo "Running Concoct and its scripts"
echo "-----------------------------------------------"
cut_up_fasta.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta -c 10000 -o 0 --merge_last -b ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_10k.bed > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_contigs_10k.fa
concoct_coverage_table.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_10k.bed ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_coverage_table.tsv
concoct --composition_file ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_contigs_10k.fa --coverage_file ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_coverage_table.tsv -b ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_concoct -t 32
merge_cutup_clustering.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_gt1000.csv > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_merged.csv
extract_fasta_bins.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Concoct/${a[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_merged.csv --output_path ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct

