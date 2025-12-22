#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-0
#SBATCH --mem=64G
#SBATCH -c 64
#SBATCH -n 1
#SBATCH --job-name=deeploc_array
#SBATCH --output=/flash/HusnikU/Phua_2/ledg/deeploc2_log/%A_%a.out
#SBATCH --array=0-205%5

files=(/flash/HusnikU/Phua_2/ledg/split_fas/transcripts.fasta.transdecoder.pep*)
echo "slurm: " ${files[${SLURM_ARRAY_TASK_ID}]}
filename=$(basename ${files[${SLURM_ARRAY_TASK_ID}]})
source /home/y/yong-phua/conda_ini.sh 
conda activate deeploc
deeploc2 -f ${files[${SLURM_ARRAY_TASK_ID}]} -o /flash/HusnikU/Phua_2/ledg/deeploc2_out/$filename/ -m Accurate
echo "done" ${files[${SLURM_ARRAY_TASK_ID}]}
awk 'FNR==1 && NR!=1 {next} {print}' deeploc2_out/*/*.csv > deeploc_out.csv