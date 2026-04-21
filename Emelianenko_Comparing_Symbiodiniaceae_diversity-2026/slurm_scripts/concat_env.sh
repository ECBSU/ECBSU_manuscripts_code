#!/bin/bash
#SBATCH --partition=compute
#SBATCH --job-name=concat_env
#SBATCH --time=2-0
#SBATCH --mem=10G
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --output=concat-env%j_out
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=vera.emelianenko@oist.jp

module purge

cat A1_1a1_ITS2_S179_run1_2_R1_001.fastq.gz A1_1a2_ITS2_S180_run1_2_R1_001.fastq.gz > ../../concat/A1_1_ITS2_S180_run1_2_R1_001.fastq.gz  
cat A1_1a1_ITS2_S179_run1_2_R2_001.fastq.gz A1_1a2_ITS2_S180_run1_2_R2_001.fastq.gz > ../../concat/A1_1_ITS2_S180_run1_2_R2_001.fastq.gz

cat A1_2a1_ITS2_S181_run1_2_R1_001.fastq.gz A1_2a2_ITS2_S182_run1_2_R1_001.fastq.gz > ../../concat/A1_2_ITS2_S182_run1_2_R1_001.fastq.gz
cat A1_2a1_ITS2_S181_run1_2_R2_001.fastq.gz A1_2a2_ITS2_S182_run1_2_R2_001.fastq.gz > ../../concat/A1_2_ITS2_S182_run1_2_R2_001.fastq.gz

cat A1_5a1_ITS2_S183_run1_2_R1_001.fastq.gz A1_5a2_ITS2_S184_run1_2_R1_001.fastq.gz > ../../concat/A1_5_ITS2_S184_run1_2_R1_001.fastq.gz
cat A1_5a1_ITS2_S183_run1_2_R2_001.fastq.gz A1_5a2_ITS2_S184_run1_2_R2_001.fastq.gz > ../../concat/A1_5_ITS2_S184_run1_2_R2_001.fastq.gz

cat A1_6a1_ITS2_S185_run1_2_R1_001.fastq.gz A1_6a2_ITS2_S186_run1_2_R1_001.fastq.gz > ../../concat/A1_6_ITS2_S186_run1_2_R1_001.fastq.gz
cat A1_6a1_ITS2_S185_run1_2_R2_001.fastq.gz A1_6a2_ITS2_S186_run1_2_R2_001.fastq.gz > ../../concat/A1_6_ITS2_S186_run1_2_R2_001.fastq.gz

cat A2_2a5_ITS2_S191_run1_2_R1_001.fastq.gz A2_2a6_ITS2_S192_run1_2_R1_001.fastq.gz > ../../concat/A2_2_ITS2_S192_run1_2_R1_001.fastq.gz
cat A2_2a5_ITS2_S191_run1_2_R2_001.fastq.gz A2_2a6_ITS2_S192_run1_2_R2_001.fastq.gz > ../../concat/A2_2_ITS2_S192_run1_2_R2_001.fastq.gz

cat A2_5a3_ITS2_S187_run1_2_R1_001.fastq.gz A2_5a4_ITS2_S188_run1_2_R1_001.fastq.gz > ../../concat/A2_5_ITS2_S188_run1_2_R1_001.fastq.gz
cat A2_5a3_ITS2_S187_run1_2_R2_001.fastq.gz A2_5a4_ITS2_S188_run1_2_R2_001.fastq.gz > ../../concat/A2_5_ITS2_S188_run1_2_R2_001.fastq.gz

cat A2_6a3_ITS2_S189_run1_2_R1_001.fastq.gz A2_6a4_ITS2_S190_run1_2_R1_001.fastq.gz > ../../concat/A2_6_ITS2_S190_run1_2_R1_001.fastq.gz
cat A2_6a3_ITS2_S189_run1_2_R2_001.fastq.gz A2_6a4_ITS2_S190_run1_2_R2_001.fastq.gz > ../../concat/A2_6_ITS2_S190_run1_2_R2_001.fastq.gz

cat A2_7a3_ITS2_S193_run1_2_R1_001.fastq.gz A2_7a4_ITS2_S194_run1_2_R1_001.fastq.gz > ../../concat/A2_7_ITS2_S194_run1_2_R1_001.fastq.gz
cat A2_7a3_ITS2_S193_run1_2_R2_001.fastq.gz A2_7a4_ITS2_S194_run1_2_R2_001.fastq.gz > ../../concat/A2_7_ITS2_S194_run1_2_R2_001.fastq.gz

cat S1_5a1_ITS2_S155_run1_2_R1_001.fastq.gz S1_5a2_ITS2_S156_run1_2_R1_001.fastq.gz > ../../concat/S1_5_ITS2_S156_run1_2_R1_001.fastq.gz
cat S1_5a1_ITS2_S155_run1_2_R2_001.fastq.gz S1_5a2_ITS2_S156_run1_2_R2_001.fastq.gz > ../../concat/S1_5_ITS2_S156_run1_2_R2_001.fastq.gz

cat S1_6a1_ITS2_S157_run1_2_R1_001.fastq.gz S1_6a2_ITS2_S158_run1_2_R1_001.fastq.gz > ../../concat/S1_6_ITS2_S158_run1_2_R1_001.fastq.gz
cat S1_6a1_ITS2_S157_run1_2_R2_001.fastq.gz S1_6a2_ITS2_S158_run1_2_R2_001.fastq.gz > ../../concat/S1_6_ITS2_S158_run1_2_R2_001.fastq.gz

cat S1_7a1_ITS2_S159_run1_2_R1_001.fastq.gz S1_7a2_ITS2_S160_run1_2_R1_001.fastq.gz > ../../concat/S1_7_ITS2_S160_run1_2_R1_001.fastq.gz
cat S1_7a1_ITS2_S159_run1_2_R2_001.fastq.gz S1_7a2_ITS2_S160_run1_2_R2_001.fastq.gz > ../../concat/S1_7_ITS2_S160_run1_2_R2_001.fastq.gz

cat S1_8a3_ITS2_S161_run1_2_R1_001.fastq.gz S1_8a4_ITS2_S162_run1_2_R1_001.fastq.gz > ../../concat/S1_8_ITS2_S162_run1_2_R1_001.fastq.gz
cat S1_8a3_ITS2_S161_run1_2_R2_001.fastq.gz S1_8a4_ITS2_S162_run1_2_R2_001.fastq.gz > ../../concat/S1_8_ITS2_S162_run1_2_R2_001.fastq.gz

cat S2_4a3_ITS2_S163_run1_2_R1_001.fastq.gz S2_4a4_ITS2_S164_run1_2_R1_001.fastq.gz > ../../concat/S2_4_ITS2_S164_run1_2_R1_001.fastq.gz
cat S2_4a3_ITS2_S163_run1_2_R2_001.fastq.gz S2_4a4_ITS2_S164_run1_2_R2_001.fastq.gz > ../../concat/S2_4_ITS2_S164_run1_2_R2_001.fastq.gz

cat S2_5a1_ITS2_S165_run1_2_R1_001.fastq.gz S2_5a2_ITS2_S166_run1_2_R1_001.fastq.gz > ../../concat/S2_5_ITS2_S166_run1_2_R1_001.fastq.gz
cat S2_5a1_ITS2_S165_run1_2_R2_001.fastq.gz S2_5a2_ITS2_S166_run1_2_R2_001.fastq.gz > ../../concat/S2_5_ITS2_S166_run1_2_R2_001.fastq.gz

cat S2_6a1_ITS2_S167_run1_2_R1_001.fastq.gz S2_6a2_ITS2_S168_run1_2_R1_001.fastq.gz > ../../concat/S2_6_ITS2_S168_run1_2_R1_001.fastq.gz
cat S2_6a1_ITS2_S167_run1_2_R2_001.fastq.gz S2_6a2_ITS2_S168_run1_2_R2_001.fastq.gz > ../../concat/S2_6_ITS2_S168_run1_2_R2_001.fastq.gz

cat S2_9a1_ITS2_S169_run1_2_R1_001.fastq.gz S2_9a2_ITS2_S170_run1_2_R1_001.fastq.gz > ../../concat/S2_9_ITS2_S170_run1_2_R1_001.fastq.gz
cat S2_9a1_ITS2_S169_run1_2_R2_001.fastq.gz S2_9a2_ITS2_S170_run1_2_R2_001.fastq.gz > ../../concat/S2_9_ITS2_S170_run1_2_R2_001.fastq.gz
