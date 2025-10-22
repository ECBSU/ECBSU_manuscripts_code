#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1-0
#SBATCH --mem=100G
#SBATCH -c 96
#SBATCH -n 1
#SBATCH --job-name=bowtie2
#SBATCH --output=bowite2
#SBATCH --mail-type=ALL
#SBATCH --mail-user=filip.husnik@oist.jp

#/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2-build scaffolds.fasta scaffolds.fasta
#/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2 -x scaffolds.fasta --reorder --mm -p 96 -1 /bucket/HusnikU/Sequencing_data/6_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R1_001.fastq.gz -2 /bucket/HusnikU/Sequencing_data/6_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R2_001.fastq.gz > mapped.sam

#/apps/unit/HusnikU/samtools-1.2/samtools view -Sb mapped.sam -o mapped.bam

/apps/unit/HusnikU/samtools-1.2/samtools sort mapped.bam sorted.mapped
