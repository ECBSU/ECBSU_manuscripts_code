#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=cutadapt_r1
#SBATCH --time=2-0
#SBATCH --mem=100G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --output=cutadapt-r1%j_out.txt
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

module purge
module load bioinfo-ugrp-modules
module load DebianMed/12.0
module load cutadapt/4.2-1

path="/flash/HusnikU/Vera/Symbiodiniaceae/raw_seq/run1"

for file in ${path}/filtN/*R1_001.fastq.gz; do

  sample=$(basename ${file%_R1_001.fastq.gz}) #for example  C1_3_ITS2_S108_run1_2 or F2_5_S72_L001

  echo "On sample: $sample"

  cutadapt \
  -g GTGAATTGCAGAACTCCGTG \
  -a AAGCATATAAGTAAGCGGAGG \
  -G CCTCCGCTTACTTATATGCTT \
  -A CACGGAGTTCTGCAATTCAC \
  -n 2 \
  -e 0.2 \
  -j 40 \
  --discard-untrimmed \
  -o ${path}/cutadapt/${sample}_R1_001.fastq.gz \
  -p ${path}/cutadapt/${sample}_R2_001.fastq.gz \
  ${path}/filtN/${sample}_R1_001.fastq.gz \
  ${path}/filtN/${sample}_R2_001.fastq.gz \
  >> cutadapt_trimming_stats_run1.txt 2>&1  # write the output in the separate .txt file

# -g sequence of an adapter ligated to the 5' end of the first read
done
# -a sequence of an adapter ligated to the 3' end of the first read
# -G 5' adapter to be removed from R2
# -A 3' adapter to be removed from R2
# -n 2 Remove up to 2 adapters from each read
# -e 0.2 maximum allowed error rate for full-length adapter match
# -j number of CPU cores to use
# --discard-untrimmed  discard reads that do not contain an adapter
# -o FILE write trimmed reads to FILE
# -p FILE write R2 to file
# second to last line [FILE] read1 input
# last line [FILE] read2 input

echo "Finished processing run1"

