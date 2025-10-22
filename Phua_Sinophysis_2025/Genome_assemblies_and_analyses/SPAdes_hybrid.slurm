#!/bin/bash
#SBATCH -p compute
#SBATCH -t 4-0
#SBATCH --mem=200G
#SBATCH -c 64
#SBATCH -n 1
#SBATCH --job-name=SPAdes_meta
#SBATCH --output=spades_meta.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yong.phua@oist.jp

/apps/unit/HusnikU/SPAdes-3.15.5-Linux/bin/spades.py -o	/flash/HusnikU/Phua_2/sino_sym2/SPAdes	--meta	--pe1-1	/bucket/.deigo/HusnikU/Sequencing_data/06_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R1_001.fastq.gz	--pe1-2	/bucket/.deigo/HusnikU/Sequencing_data/06_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R2_001.fastq.gz	--nanopore	/bucket/HusnikU/Sequencing_data/18_MiniION_20220530_Phua/20220530_MinION/ID405/20220530_1647_X5_FAR25643_f093256c/fastq_pass/ID405_MiniION.fastq.gz --threads	64	--memory	200