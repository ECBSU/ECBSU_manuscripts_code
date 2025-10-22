#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1:00:00
#SBATCH --mem=30G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=Sino_host_transcriptome
#SBATCH --output=Sino_host_transcriptome
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

/apps/unit/HusnikU/fastp/0.21/fastp -i /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SinoL_S1_L001_R1_001.fastq.gz -I /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SinoL_S1_L001_R2_001.fastq.gz -o /flash/HusnikU/Phua_2/SinoL_S1_L001_R1_001_Trimed.fastq.gz -O /flash/HusnikU/Phua_2/SinoL_S1_L001_R2_001_Trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta
/apps/unit/HusnikU/fastp/0.21/fastp -i /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL2_S26_L001_R1_001.fastq.gz -I /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL2_S26_L001_R2_001.fastq.gz -o /flash/HusnikU/Phua_2/SL2_S26_L001_R1_001_Trimed.fastq.gz -O /flash/HusnikU/Phua_2/SL2_S26_L001_R2_001_Trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta
/apps/unit/HusnikU/fastp/0.21/fastp -i /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL3_S2_L001_R1_001.fastq.gz -I /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL3_S2_L001_R2_001.fastq.gz -o /flash/HusnikU/Phua_2/SL3_S2_L001_R1_001_Trimed.fastq.gz -O /flash/HusnikU/Phua_2/SL3_S2_L001_R2_001_Trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta
/apps/unit/HusnikU/fastp/0.21/fastp -i /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL4_S3_L001_R1_001.fastq.gz -I /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL4_S3_L001_R2_001.fastq.gz -o /flash/HusnikU/Phua_2/SL4_S3_L001_R1_001_Trimed.fastq.gz -O /flash/HusnikU/Phua_2/SL4_S3_L001_R2_001_Trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta
/apps/unit/HusnikU/fastp/0.21/fastp -i /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL5_S4_L001_R1_001.fastq.gz -I /bucket/HusnikU/Sequencing_data/11_NovaSeq_211022_A00457_0203_AHFK33DRXY_Filip_Phua_IInes/Data/Intensities/BaseCalls/2-2_HusnikU_ID244/SL5_S4_L001_R2_001.fastq.gz -o /flash/HusnikU/Phua_2/SL5_S4_L001_R1_001_trimmed.fastq.gz -O /flash/HusnikU/Phua_2/SL5_S4_L001_R2_001_Trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta