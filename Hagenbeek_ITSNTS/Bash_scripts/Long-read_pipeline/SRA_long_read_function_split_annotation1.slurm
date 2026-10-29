#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_long_read_function_split1_%a.out
#SBATCH -t 0-6
#SBATCH --mem=8G
#SBATCH -c 8


ml bioinfo-ugrp-modules
ml DebianMed
ml kraken2

readarray -t a < <(cut -d';' -f1 $1)
outdir=$2

#Create a new fasta from the long read fastq
#sed -n '1~4s/^@/>/p;2~4p' ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fastq > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fasta

#Split the fasta into multiple smaller ones for parallel processing. Here files are split into approx. 500 Mbp files
python /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/Fasta_splitter.py -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fasta -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed_split -s 500000

#Count how many files were generated, to adjust the array size
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/
array_size=$(find . -maxdepth 1 -name "${a[${SLURM_ARRAY_TASK_ID}]}_trimmed_split*" -printf '.' | wc -m)
#Submit nested array sbatch commands to process the smaller fastas in parallel
jobstring=$(sbatch --array=0-${array_size} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/SRA_long_read_function_split_annotation2.slurm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/ $3 $4 $5 $6 $7)
jobid=${jobstring##* }

#Submit job for merging the split annotation files
sbatch --dependency=afterany:${jobid} /bucket/HusnikU/Unit_Members/Arno/Chain_scripts/Main_analysis_SRA_long_read/SRA_long_read_function_split_annotation3.slurm $1 $2 $8 $9 ${10} ${11} ${SLURM_ARRAY_TASK_ID}

