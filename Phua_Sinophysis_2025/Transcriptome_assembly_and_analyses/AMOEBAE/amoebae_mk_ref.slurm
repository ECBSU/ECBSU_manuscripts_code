#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-8
#SBATCH --mem=16G
#SBATCH -c 24
#SBATCH -n 1
#SBATCH --job-name=amoebae
#SBATCH --output=20250310_amoebae_nifU_refseq.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

source /home/y/yong-phua/conda_ini.sh
conda activate /hpcshare/appsunit/HusnikU/mamba/snakemake

cd /flash/HusnikU/Phua_2/amoebae
snakemake get_ref_seqs -j 100 --use-conda