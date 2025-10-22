#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-0
#SBATCH --mem=32G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=hmmer
#SBATCH --output=hmmer.out

ml hmmer/3.1b2
hmmscan  --tblout '/flash/HusnikU/Phua_2/20250710_cyanohypothetical/hypothetical_hmmer.tbl' --cpu 16 /bucket/HusnikU/Databases/HMMER_db/Bacteria.hmm '/flash/HusnikU/Phua_2/20250710_cyanohypothetical/PROKKA_04042024_hypothetical.faa'

