#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=symportal_all
#SBATCH --time=2-0
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --output=symportal_all_%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

#need to conda activate symportal_env before running
#need to have data where the programs can write
#in this case on flash, not bucket
#need to copy (create) metadata file

module purge

~/SymPortal_framework-master/main.py --load /flash/HusnikU/Vera/Symbiodiniaceae/concat --name all --num_proc 40 --data_sheet /flash/HusnikU/Vera/Symbiodiniaceae/meta.xlsx
