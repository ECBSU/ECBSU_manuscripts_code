#!/bin/bash
#SBATCH -p compute
#SBATCH -t 1:00:00
#SBATCH --mem=10G
#SBATCH -c 8
#SBATCH -n 1
#SBATCH --job-name=transcriptome
#SBATCH --output=fastp.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

in_dir=/bucket/.deigo/HusnikU/Sequencing_data/Phua_external/legendrea_transcriptome_daniel
out_dir=/flash/HusnikU/Phua_2/ledg_transcript

ml fastqc/0.11.9

for x in 1 2 3 ;
    do /apps/unit/HusnikU/fastp/0.21/fastp -i $in_dir/LOY${x}_1.fastq.gz -I $in_dir/LOY${x}_2.fastq.gz -o $out_dir/LOY${x}_1_trimed.fastq.gz -O $out_dir/LOY${x}_2_trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta -j LOY${x}.json -h LOY${x}.html ;
    fastqc $out_dir/LOY${x}_1_trimed.fastq.gz $out_dir/LOY${x}_2_trimed.fastq.gz -t 2 ;
    fastqc -v
done
