#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_binning2_%a.out
#SBATCH -t 4-0
#SBATCH --mem=128G
#SBATCH -c 64




readarray -t a < $1
outdir=$2
conda_ex=$3


#RUN SEMIBIN
#############################################
#Activate semibin conda env
source ${conda_ex}
conda activate $4
#Run semibin
echo "-----------------------------------------------"
echo "Running Semibin"
echo "-----------------------------------------------"
SemiBin2 -v
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Semibin
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Semibin
SemiBin2 single_easy_bin -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta -b ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam --environment global -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Semibin
#Semibin was run in the intermediate file folder since it generates a bunch of files. Move the bins to the appropriate folder 
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Semibin/output_bins/*.gz ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Semibin
#Unzip the bin fasta files
gunzip ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Semibin/*.gz
#Remove the now empty output bin folder
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Semibin/output_bins/

#RUN ROSELLA
#############################################
#Activate rosella conda env
conda deactivate 
conda activate $5
#Run Rosella
echo "-----------------------------------------------"
echo "Running Rosella"
echo "-----------------------------------------------"
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella
rosella recover -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella -b ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}.bam
#Rosella generates non-bin fasta files, with naming similar to the bins.
#To avoid these fastas from interfering downstream, they'll be moved to a separate folder 
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella/unbinned_sequences
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella/*unbinned.fna ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella/unbinned_sequences
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Rosella/rosella_*.fna ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella/

#RUN DASTOOL
#############################################
#Activate Dastool conda environment 
conda deactivate
conda activate $6
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Dastool
#Generate contig2bin inputs .tsv files for dastool for the tools that don't generate their own
for i in ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabat/*.fa; do grep "^>" $i | sed 's/>.*/&\t'${i##*/}' /' | sed 's/>//' >> ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/metabat_bins.tsv; done
for i in ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct/*.fa; do grep "^>" $i | sed 's/>.*/&\t'${i##*/}' /' | sed 's/>//' >> ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/concoct_bins.tsv; done
for i in ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella/rosella_*.fna; do grep "^>" $i | sed 's/>.*/&\t'${i##*/}' /' | sed 's/>//' >> ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/rosella_bins.tsv; done

#Semibin generates its own contig2bin .tsv files, but it contains headers, which DASTools doesnt accept.
#Remove the header files 
tail -n +2 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Semibin/contig_bins.tsv > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/semibin_bins.tsv

cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/
#Run DASTool
echo "-----------------------------------------------"
echo "Running DASTool"
echo "-----------------------------------------------"
DAS_Tool -i metabat_bins.tsv,concoct_bins.tsv,rosella_bins.tsv,semibin_bins.tsv -c ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_megahit_scaffolds.fasta -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/${a[${SLURM_ARRAY_TASK_ID}]} --write_bin_evals --write_bins -t 64
#Move refined bins to the DASTool bin folder
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/Dastool/${a[${SLURM_ARRAY_TASK_ID}]}_DASTool_bins/* ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Dastool/

#Remove intermediate binning files
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Intermediate_files/