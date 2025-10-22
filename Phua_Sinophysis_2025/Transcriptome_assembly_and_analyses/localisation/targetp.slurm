#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-0
#SBATCH --mem=32G
#SBATCH -c 32
#SBATCH -n 1
#SBATCH --job-name=targetp_all
#SBATCH --output=targetp_all.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

/hpcshare/appsunit/HusnikU/targetp-2.0/bin/targetp -fasta /bucket/.deigo/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/transptome/clean_transcriptome/Trinity/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta.transdecoder.pep -org pl