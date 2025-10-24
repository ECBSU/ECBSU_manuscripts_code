#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=symportal_env
#SBATCH --time=2-0
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --output=symportal_env_%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

#need to conda activate symportal_env before running
#need to have data on flash, not bucket

module purge

~/SymPortal_framework-master/main.py --load /flash/HusnikU/Vera/Symbiodiniaceae/raw_seq/env --name env --num_proc 40 --data_sheet /flash/HusnikU/Vera/Symbiodiniaceae/meta_env.xlsx
