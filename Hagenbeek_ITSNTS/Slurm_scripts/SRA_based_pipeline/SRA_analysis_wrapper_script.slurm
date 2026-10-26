#!/bin/bash

##########################
#Input your variables here
#           ||
#           ||
#           ||
#           \/
##########################
#Put the path of a (newline-delimited) text file containing the SRA files you would like to analyze in the next line after the "="
SRA_entry_list=/bucket/HusnikU/Unit_Members/Arno/SRA_Main_analysis_SRA_test_input_list.txt
#Put the desired path of the output directory here after the "=" symbol . Most likely /flash/HusnikU/your_name/this_job
outdir=/flash/HusnikU/Arno/SRA_chain_pipe_test/
#Last index of the array
#This equals your number of SRA entries minus one (one sample = 0, three samples = 2 etc.)
filenumber=0

###########################
#Other variables
###########################
#Paths and executables required to run the scripts
conda_ex=/home/a/arno-hagenbeek/miniforge3/etc/profile.d/conda.sh
metabuli_path=/bucket/HusnikU/Conda-envs/Metabuli
phyloflash_conda_path=/bucket/HusnikU/Conda-envs/phyloflash
phyloflash_ex_path=/bucket/HusnikU/Conda-envs/phyloflash/bin/phyloFlash.pl
gapseq_path=/home/a/arno-hagenbeek/miniforge3/envs/gapseq
whokaryote_path=/bucket/HusnikU/Conda-envs/Whokaryote/
eggnog_path=/bucket/HusnikU/Conda-envs/eggnog
concoct_path=/apps/unit/HusnikU/Conda-envs/concoct
semibin_path=/apps/unit/HusnikU/Conda-envs/semibin
rosella_path=/bucket/HusnikU/Conda-envs/rosella/
dastool_path=/bucket/HusnikU/Conda-envs/das-tool
checkm2_path=/bucket/HusnikU/Conda-envs/checkm2
checkm2_ex_path=/apps/unit/HusnikU/checkm2/bin/checkm2
checkm2_database=/bucket/HusnikU/Databases/checkm2/CheckM2_database/uniref100.KO.1.dmnd
bin_group_script=/bucket/HusnikU/Unit_Members/Arno/Scripts/Bin_grouper.py
bin_sort_script=/bucket/HusnikU/Unit_Members/Arno/Scripts/Bin_group_sorter.py
gtdbtk_path=/bucket/HusnikU/Conda-envs/gtdb-tk/
coverm_path=/bucket/HusnikU/Conda-envs/coverm
featurecounts_ex=/home/a/arno-hagenbeek/subread-2.1.1-Linux-x86_64/bin/featureCounts
rpkm_script=/bucket/HusnikU/Unit_Members/Arno/Scripts/Featurecounts_rpkm_calculator.py

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
jobstring=$(sbatch --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_download_FASTP.slurm $SRA_entry_list $outdir)
jobid=${jobstring##* }

#Run the script for read LCA
jobstring=$(sbatch --dependency=afterany:${jobid} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_LCA.slurm $SRA_entry_list $outdir $conda_ex $metabuli_path)
jobid2=${jobstring##* }

#Run the script for megahit and phyloflash
jobstring=$(sbatch --dependency=afterany:${jobid2} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_megahit_phyloFlash.slurm $SRA_entry_list $outdir $conda_ex $phyloflash_conda_path $phyloflash_ex_path)
jobid3=${jobstring##* }

#Run the first part of the binning process
jobstring=$(sbatch --dependency=afterany:${jobid3} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_binning1.slurm $SRA_entry_list $outdir $conda_ex $concoct_path)
jobid4=${jobstring##* }

#Run the second part of the binning process
jobstring=$(sbatch --dependency=afterany:${jobid4} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_binning2.slurm $SRA_entry_list $outdir $conda_ex $semibin_path $rosella_path $dastool_path)
jobid5=${jobstring##* }

#Get the stats for the MAGs and pick the best bins to continue with
jobstring=$(sbatch --dependency=afterany:${jobid5} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_redundancy_remove_MAG_stats.slurm $SRA_entry_list $outdir $conda_ex $checkm2_path $checkm2_ex_path $checkm2_database $bin_group_script $bin_sort_script $gtdbtk_path)
jobid6=${jobstring##* }

#Run the script for annotating the prokaryote metagenome (needs the bam generated during binning)
jobstring=$(sbatch --dependency=afterany:${jobid6} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_metagenome_function_profile.slurm $SRA_entry_list $outdir $conda_ex $whokaryote_path $eggnog_path $EggNOG_mmseq_database $EggNOG_diamond_database $KEGGstand_module_checker_path $KEGG_module_database_path $KEGGstand_pathway_checker_path $KEGG_pathway_database_path $gapseq_path $featurecounts_ex $rpkm_script)
jobid7=${jobstring##* }

#Annotate the best non-redundant bins
sbatch --dependency=afterany:${jobid7} --array=0-${filenumber} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA/SRA_bin_function_profile.slurm $SRA_entry_list $outdir $conda_ex $eggnog_path $EggNOG_mmseq_database $EggNOG_diamond_database $KEGGstand_module_checker_path $KEGG_module_database_path $KEGGstand_pathway_checker_path $KEGG_pathway_database_path $gapseq_path $coverm_path
