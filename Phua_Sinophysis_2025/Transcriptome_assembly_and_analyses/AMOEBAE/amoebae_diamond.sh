#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-4
#SBATCH --mem=16G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=diamond
#SBATCH --output=results/diamond_%A_%a.log  
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp
#SBATCH --array=0-33

workdir=/flash/HusnikU/Phua_2/amoebae/results

mkdir -p $workdir/megan
cp diamond.sh $workdir/megan

cd $workdir/megan

# Get the input file for this array index
#data is from remiplastid amoeba output folder fwd_srchs_1_rev_srch_1_interp_with_ali_col_nonredun_fasta_files/
input_files=($workdir/fwd_srchs_1_rev_srch_1_interp_with_ali_col_nonredun_fasta_files/*.fa)
query=${input_files[$SLURM_ARRAY_TASK_ID - 1]}  
prot=$(basename "$query" _matches.fa)

# Run diamond blastp and meganizer
/apps/unit/HusnikU/diamond blastp -p 16 -f 100 --db /bucket/HusnikU/Databases/nr_2024_diamond.dmnd --sensitive -q $query -o $prot.daa
/apps/unit/HusnikU/megan/tools/daa-meganizer -i $prot.daa -mdb /bucket/.deigo/HusnikU/Databases/megandb/megan-map-Feb2022.db -t 16
/apps/unit/HusnikU/megan/tools/blast2lca -i $prot.daa -o ${prot}_taxa.txt -f DAA -mdb /bucket/.deigo/HusnikU/Databases/megandb/megan-map-Feb2022.db
