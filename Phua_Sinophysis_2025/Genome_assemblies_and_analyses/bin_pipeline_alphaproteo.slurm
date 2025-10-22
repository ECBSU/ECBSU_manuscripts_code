#!/bin/bash

#SBATCH -p compute
#SBATCH --output=bin_pipe%a.out
#SBATCH -t 1-0
#SBATCH --mem=48G
#SBATCH -c 16
#SBATCH --array=0-0 #CHANGE THIS TO MATCH THE NUMBER OF ASSEMBLIES/SAMPLES 0-0=1 0-2=3 0-6=7 ETC. 

#Creates the necessary alignment files, runs metabat,concoct, and semibin, and combines the results using dastools

#Load modules
ml samtools
ml bowtie2
ml metabat

#INPUT VARIABLES !!CHANGE AS NEEDED!!
#############################################
#Insert directories containing only the assemblies and reads for binning. 
#Names of the reads and assemblies should match so they are ordered similarly in the array
assembly_dir=/flash/HusnikU/Phua_2/sino_sym2/SPAdes/bin/assembly
rawreads_dir=/flash/HusnikU/Phua_2/sino_sym2/SPAdes/bin/reads
#Output directory
out_dir=/flash/HusnikU/Phua_2/sino_sym2/SPAdes/bin/bins

#Creates array of assemblies to iterate over
cd ${assembly_dir}
assemblies=(*.fasta) #!!CHANGE TO EXTENSION OF YOUR ASSEMBLIES!!
#create and move to out_dir
mkdir $out_dir
cd ${out_dir}
#creates arrays of forward and reverse reads. 
reads1=(${rawreads_dir}/*R1_001.fastq.gz) #forward reads
reads2=(${rawreads_dir}/*R2_001.fastq.gz) #reverse reads

echo "-----------------------------------------------"
echo "Running pipeline on:"
echo ${assemblies[${SLURM_ARRAY_TASK_ID}]}
echo ${reads1[${SLURM_ARRAY_TASK_ID}]}
echo ${reads2[${SLURM_ARRAY_TASK_ID}]}
echo "-----------------------------------------------"

#READ ALIGNMENT AND BAM FILE GENERATION
############################################
#Run bowtie for alignment
echo "-----------------------------------------------"
echo "Running Bowtie2"
echo "-----------------------------------------------"
bowtie2-build $assembly_dir/${assemblies[${SLURM_ARRAY_TASK_ID}]}  ./${assemblies[${SLURM_ARRAY_TASK_ID}]}
bowtie2 -x ./${assemblies[${SLURM_ARRAY_TASK_ID}]} -1 ${reads1[${SLURM_ARRAY_TASK_ID}]} -2 ${reads2[${SLURM_ARRAY_TASK_ID}]} -S ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}.sam

#Sort and compress sam file into bam file
echo "-----------------------------------------------"
echo "Running samtools"
echo "-----------------------------------------------"
samtools sort -@16 -O BAM -o ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bam ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.sam
samtools index ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bam ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bai

#remove sam file and bowtie indices to save space
rm ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.sam
rm ./${assemblies[${SLURM_ARRAY_TASK_ID}]}*.bt2


#RUN METABAT
#############################################
#Create folder for metabat output (per sample)
mkdir ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_metabat
#Create metabat coverage input, and run metabat
jgi_summarize_bam_contig_depths --outputDepth ${assemblies[${SLURM_ARRAY_TASK_ID}]}_depth.txt ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bam
echo "-----------------------------------------------"
echo "Running Metabat2"
echo "-----------------------------------------------"
metabat2 -i ${assembly_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]} -a ${assemblies[${SLURM_ARRAY_TASK_ID}]}_depth.txt -o ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_metabat/metabatbin -t 16

#RUN CONCOCT
#############################################
#Activate concoct conda env
source /home/y/yong-phua/conda_ini.sh
conda activate /apps/unit/HusnikU/Conda-envs/concoct
#Run concoct and its associated python scripts
echo "-----------------------------------------------"
echo "Running Concoct and its scripts"
echo "-----------------------------------------------"
cut_up_fasta.py $assembly_dir/${assemblies[${SLURM_ARRAY_TASK_ID}]} -c 10000 -o 0 --merge_last -b ${assemblies[${SLURM_ARRAY_TASK_ID}]}_10k.bed > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_contigs_10k.fa
concoct_coverage_table.py ${assemblies[${SLURM_ARRAY_TASK_ID}]}_10k.bed ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bam > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_coverage_table.tsv
concoct --composition_file ${assemblies[${SLURM_ARRAY_TASK_ID}]}_contigs_10k.fa --coverage_file ${assemblies[${SLURM_ARRAY_TASK_ID}]}_coverage_table.tsv -b ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct -t 16
merge_cutup_clustering.py ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_gt1000.csv > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_merged.csv
mkdir ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_bins
extract_fasta_bins.py $assembly_dir/${assemblies[${SLURM_ARRAY_TASK_ID}]} ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_merged.csv --output_path ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_bins
#Remove unnecessary files
rm ${assemblies[${SLURM_ARRAY_TASK_ID}]}_contigs_10k.fa
rm ${assemblies[${SLURM_ARRAY_TASK_ID}]}_10k.bed
rm ${assemblies[${SLURM_ARRAY_TASK_ID}]}_coverage_table.tsv
rm ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_clustering_merged.csv

#RUN SEMIBIN
#############################################
#Activate semibin conda env
conda deactivate
conda activate /apps/unit/HusnikU/Conda-envs/semibin
#Run semibin
echo "-----------------------------------------------"
echo "Running Semibin"
echo "-----------------------------------------------"
SemiBin2 single_easy_bin -i $assembly_dir/${assemblies[${SLURM_ARRAY_TASK_ID}]} -b ./${assemblies[${SLURM_ARRAY_TASK_ID}]}.bam --environment global -o ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_semibin

#RUN DASTOOL
#############################################
#Activate Dastool conda environment 
conda deactivate
conda activate /apps/unit/HusnikU/Conda-envs/das-tool
#Generate contig2bin inputs for dastool
/bucket/HusnikU/Unit_Members/Arno/Scripts/Fasta_to_Contig2Bin.sh -i ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_metabat/ -e fa > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_metabat_contig2bin.tsv
/bucket/HusnikU/Unit_Members/Arno/Scripts/Fasta_to_Contig2Bin.sh -i ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_bins -e fa > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_contig2bin.tsv
#semibin bins are inconvenient, as they are zipped. However, it generates its own contig2bin file, which can be used once its header line is removed
tail -n +2 ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_semibin/contig_bins.tsv > ${assemblies[${SLURM_ARRAY_TASK_ID}]}_semibin_contig2bin.tsv
#Run DASTool
echo "-----------------------------------------------"
echo "Running DASTool"
echo "-----------------------------------------------"
DAS_Tool -i ${assemblies[${SLURM_ARRAY_TASK_ID}]}_semibin_contig2bin.tsv,${assemblies[${SLURM_ARRAY_TASK_ID}]}_metabat_contig2bin.tsv,${assemblies[${SLURM_ARRAY_TASK_ID}]}_concoct_contig2bin.tsv -c $assembly_dir/${assemblies[${SLURM_ARRAY_TASK_ID}]} -o ${out_dir}/${assemblies[${SLURM_ARRAY_TASK_ID}]}_dastool_output --write_bin_evals --write_bins -t 16
