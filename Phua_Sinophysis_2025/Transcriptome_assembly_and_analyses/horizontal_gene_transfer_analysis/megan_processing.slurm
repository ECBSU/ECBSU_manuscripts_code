#!/bin/bash
#SBATCH -p compute
#SBATCH -t 2-0
#SBATCH --mem=50G
#SBATCH -c 64
#SBATCH -n 1
#SBATCH --job-name=Megan_blast
#SBATCH --output=megan.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

/apps/unit/HusnikU/diamond blastp -p 64 -f 100 --db /flash/HusnikU/databases/NR_data_diamond/data.dmnd --sensitive -q /bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/transptome/clean_transcriptome/Trinity/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta.transdecoder.pep -o transcripts_pep.daa
