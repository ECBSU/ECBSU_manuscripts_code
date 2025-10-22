#!/bin/bash
#SBATCH -p compute
#SBATCH -t 2-0
#SBATCH --mem=64G
#SBATCH -c 32
#SBATCH -n 1
#SBATCH --job-name=diamondblastp
#SBATCH --output=diamondblastp_plasmid_pfam.out

ml hmmer/3.1b2
input_file="/flash/HusnikU/Phua_2/20250710_cyanohypothetical/plasmid_PROKKA_04042024.faa"
output_file="plasmid_PROKKA_04042024"
/apps/unit/HusnikU/diamond blastp -p 32 -f 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle --db /bucket/.deigo/HusnikU/Databases/nr_2024_diamond.dmnd --sensitive -q $input_file -o $output_file.diablastp
hmmscan --pfamtblout $output_file.pfamtbl --cpu 32 /flash/HusnikU/Phua_2/20250710_cyanohypothetical/Pfam-A.hmm $input_file
