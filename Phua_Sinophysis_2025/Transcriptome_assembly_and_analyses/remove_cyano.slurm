#!/bin/bash
#SBATCH -p compute
#SBATCH -t 0-5
#SBATCH --mem=50G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=clean
#SBATCH --output=clean.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yong.phua@oist.jp
cd /flash/HusnikU/Phua_2/clean_transcriptome/SinoL
/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/edit3/edit3_assembly.fasta in=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SinoL_S1_L001_R1_001_Trimed.fastq.gz in2=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SinoL_S1_L001_R2_001_Trimed.fastq.gz basename=out_%.fq outu1=clean1.fq outu2=clean2.fq
cd /flash/HusnikU/Phua_2/clean_transcriptome/SL2
/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/edit3/edit3_assembly.fasta in=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL2_S26_L001_R1_001_Trimed.fastq.gz in2=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL2_S26_L001_R2_001_Trimed.fastq.gz basename=out_%.fq outu1=clean1.fq outu2=clean2.fq
cd /flash/HusnikU/Phua_2/clean_transcriptome/SL3
/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/edit3/edit3_assembly.fasta in=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL3_S2_L001_R1_001_Trimed.fastq.gz in2=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL3_S2_L001_R2_001_Trimed.fastq.gz basename=out_%.fq outu1=clean1.fq outu2=clean2.fq
cd /flash/HusnikU/Phua_2/clean_transcriptome/SL4
/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/edit3/edit3_assembly.fasta in=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL4_S3_L001_R1_001_Trimed.fastq.gz in2=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL4_S3_L001_R2_001_Trimed.fastq.gz basename=out_%.fq outu1=clean1.fq outu2=clean2.fq
cd /flash/HusnikU/Phua_2/clean_transcriptome/SL5
/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/edit3/edit3_assembly.fasta in=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL5_S4_L001_R1_001_Trimed.fastq.gz in2=/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/Transcriptome_analysis/SL5_S4_L001_R2_001_Trimed.fastq.gz basename=out_%.fq outu1=clean1.fq outu2=clean2.fq