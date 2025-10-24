#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=concat
#SBATCH --time=2-0
#SBATCH --mem=10G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --output=concat-%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

module purge

path="/flash/HusnikU/Vera/Symbiodiniaceae/raw_seq"

for file in ${path}/run2/*R1_001.fastq.gz; do
  sample_id_run2=$(basename ${file%_L001_R1_001.fastq.gz}) #for example  S1-8a4-ITS2_S162
  sample_id_run1=${sample_id_run2//-/_} # change all dashes to underscores

  cat ${path}/run2/${sample_id_run2}_L001_R1_001.fastq.gz ${path}/run1/${sample_id_run1}_R1_001.fastq.gz > ${path}/run1_2/${sample_id_run1}_run1_2_R1_001.fastq.gz #Read1

  cat ${path}/run2/${sample_id_run2}_L001_R2_001.fastq.gz ${path}/run1/${sample_id_run1}_R2_001.fastq.gz > ${path}/run1_2/${sample_id_run1}_run1_2_R2_001.fastq.gz # Read 2
done
