#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-8
#SBATCH --mem=16G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=amoebae
#SBATCH --output=20241024_amoebae_TIC_analyse.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

source /home/y/yong-phua/conda_ini.sh
conda activate /hpcshare/appsunit/HusnikU/mamba/snakemake

cd /flash/HusnikU/Phua_2/amoebae

snakemake -j 100 --use-conda

#results may fail to plot
echo 'retrying plot results'
python3 amoebae plot results/fwd_srchs_1_rev_srch_1_interp_with_ali_col_nonredun.csv --complex_info config/coulson_plot_organization.csv --row_order config/output_plot_row_order.txt --out_pdf results/plot.pdf

