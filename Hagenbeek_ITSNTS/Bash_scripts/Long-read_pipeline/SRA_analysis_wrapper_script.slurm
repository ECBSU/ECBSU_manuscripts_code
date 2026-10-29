#!/bin/bash

##########################
#Input your variables here
#           ||
#           ||
#           ||
#           \/
##########################
#Put the path of a (newline-delimited) text file containing the SRA files you would like to analyze in the next line after the "="
SRA_entry_list=
#Put the desired path of the output directory here after the "=" symbol . Most likely /flash/HusnikU/your_name/this_job
outdir=/flash/HusnikU/Arno/SRA_long_read_test/
#Last index of the array
#This equals your number of SRA entries WITHOUT minus one (one sample = 1, three samples = 3 etc.)
#This is WITHOUT the minus one because 0 equals the header of the runinfo file
filenumber=0

###########################
#Other variables
###########################
#Paths and executables required to run the scripts
conda_ex=/home/a/arno-hagenbeek/miniforge3/etc/profile.d/conda.sh
fastplong_path=/bucket/HusnikU/Conda-envs/fastplong
metabuli_path=/bucket/HusnikU/Conda-envs/Metabuli
whokaryote_path=/bucket/HusnikU/Conda-envs/Whokaryote/
eggnog_path=/bucket/HusnikU/Conda-envs/eggnog

KEGGstand_module_checker_path=/bucket/HusnikU/Unit_Members/Arno/Scripts/KEGGstand_module_checker.py
KEGGstand_pathway_checker_path=/bucket/HusnikU/Unit_Members/Arno/Scripts/KEGGstand_pathway_checker.py
KEGG_module_database_path=/bucket/HusnikU/Unit_Members/Arno/Scripts/KEGG_module_db
KEGG_pathway_database_path=/bucket/HusnikU/Unit_Members/Arno/Scripts/KEGG_k_entries_db

EggNOG_mmseq_database=/bucket/HusnikU/Databases/EggNOG_mmseqs2_databases/Bacteria.mmseqs/Bacteria.mmseqs
EggNOG_diamond_database=/bucket/HusnikU/Databases/Eggnog_db/Eggnog_Diamond_db/
############################
mkdir $outdir
#Run the script for downloading the fastq and running fastp
#Use the "jobstring" construction to create a chain job, automatically running the next job after the previous finishes
jobstring=$(sbatch --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/SRA_download_FASTP.slurm $SRA_entry_list $outdir $conda_ex $fastplong_path)
jobid=${jobstring##* }

#Run the script for read LCA
jobstring=$(sbatch --dependency=afterany:${jobid} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/SRA_LCA.slurm $SRA_entry_list $outdir $conda_ex $metabuli_path)
jobid2=${jobstring##* }

#Run the script for functional annotation
jobstring=$(sbatch --dependency=afterany:${jobid} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/SRA_long_read_function.slurm $SRA_entry_list $outdir $conda_ex $whokaryote_path $eggnog_path $EggNOG_mmseq_database $EggNOG_diamond_database $KEGGstand_module_checker_path $KEGG_module_database_path $KEGGstand_pathway_checker_path $KEGG_pathway_database_path)
jobid3=${jobstring##* }

