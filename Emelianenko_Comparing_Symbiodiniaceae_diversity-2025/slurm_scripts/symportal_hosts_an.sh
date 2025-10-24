#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=symportal_host_analysis
#SBATCH --time=2-0
#SBATCH --mem=80G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --output=symportal_host_analysis_%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

#need to conda activate symportal_env before running
#need to change the number of the dataset after --analyse

module purge

~/SymPortal_framework-master/main.py --analyse 9 --name host_analysis --num_proc 20
