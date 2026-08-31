#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-0
#SBATCH --mem=300G
#SBATCH -c 3
#SBATCH -n 1
#SBATCH --job-name=iq2mc
#SBATCH --output=iq2mc.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=jinyeong.choi@oist.jp

source ~/.bashrc
conda activate iqtree3

iqtree3 -s catMSA.faa \
-m JTT+F+R6 \
-te iqtree_rooted_topology.treefile \
--dating mcmctree \
--prefix host \
--mcmc-iter 1000000,1000,10000 \
--mcmc-bds 1,1,0.005 \
--mcmc-clock IND \
-v
