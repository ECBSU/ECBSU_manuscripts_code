#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-2
#SBATCH --mem=16G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=AvP
#SBATCH --output=AvP.log

module load bioinfo-ugrp-modules
module load DB/diamondDB/ncbi/2022-07
module load DB/blastDB/ncbi/2022-07-nr

cd /flash/HusnikU/Phua_2/Avp_all
outdir=/flash/HusnikU/Phua_2/Avp_all/out
mkdir $outdir

/apps/unit/HusnikU/diamond blastp -q all_reads_name.faa -d ${DIAMONDDB}/nr.dmnd \
    --evalue 1e-5 --max-target-seqs 500 \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore staxids \
    --out similarity.out

source /home/y/yong-phua/conda_ini.sh 
conda activate avp
/home/y/yong-phua/AvP/aux_scripts/calculate_ai.py -i similarity.out -x groups.yaml
/home/y/yong-phua/AvP/avp prepare -a similarity.out_ai.out -o $outdir -f all_reads_name.faa -b similarity.out -x groups.yaml -c config.yaml --cfg taxonomy.yaml
/home/y/yong-phua/AvP/avp detect -i $outdir/mafftgroups/ -o $outdir -g $outdir/groups.tsv -t $outdir/tmp/taxonomy_nexus.txt -c config.yaml
/home/y/yong-phua/AvP/avp classify -i $outdir/fasttree_nexus/ -t $outdir/fasttree_tree_results.txt -f classify.txt -c config.yaml -o $outdir
/home/y/yong-phua/AvP/avp evaluate -i $outdir/mafftgroups/ -t $outdir/fasttree_tree_results.txt -o $outdir -c config.yaml
conda deactivate
