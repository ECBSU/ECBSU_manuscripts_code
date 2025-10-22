#!/bin/bash
#SBATCH -p compute
#SBATCH -t 5:00:00
#SBATCH --mem=24G
#SBATCH -c 16
#SBATCH -n 1
#SBATCH --job-name=transcriptome
#SBATCH --output=smartseq_pipe_qc_%A_%a.out
#SBATCH --array=0-4

# Input params
read_dir=/bucket/.deigo/HusnikU/Sequencing_data/44_NovaSeq_230911_A00457_0372_AHW7YHDRX2_Vasyl_Choi_Iines_Nina_Dewi/Data/Intensities/BaseCalls/ID687
out_dir=/flash/HusnikU/Phua_2/vasyl_transcriptome
sample_prefix=SN

# Collecting reads names
sample=($(ls $read_dir/*$sample_prefix*R1*))
read1="${sample[${SLURM_ARRAY_TASK_ID}]}"
read2="$read_dir/$(basename "$read1" | sed 's/_R1_/_R2_/')"
lib_name="$(basename $read1 | sed 's/_R1_001.fastq.gz$//')"
work_dir=$out_dir/$lib_name
mkdir -p $work_dir
cd $work_dir

echo "Processing: "$lib_name
echo "Read1: "$read1
echo "Read2: "$read2

# run fastqc, fastp
ml fastqc/0.11.9

/apps/unit/HusnikU/fastp/0.21/fastp -i $read1 -I $read2 -o $work_dir/${lib_name}_1_trimed.fastq.gz -O $work_dir/${lib_name}_2_trimed.fastq.gz --adapter_fasta=/flash/HusnikU/smartseq2_oligos.fasta -j $work_dir/${lib_name}.json -h $work_dir/${lib_name}.html
fastqc -v
fastqc $work_dir/${lib_name}_1_trimed.fastq.gz $work_dir/${lib_name}_2_trimed.fastq.gz -t 16

/apps/unit/HusnikU/bbmap/bbsplit.sh ref=/bucket/.deigo/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Cyano_blob/missing3_perid90/missing3_per90_uni/final_clean_closed/pilon/cyano.fa in=$work_dir/${lib_name}_1_trimed.fastq.gz in2=$work_dir/${lib_name}_2_trimed.fastq.gz basename=${lib_name}_out_%.fq outu1=${lib_name}_clean1.fq outu2=${lib_name}_clean2.fq

echo -e "${lib_name}\t${lib_name}\t${lib_name}_clean1.fq\t${lib_name}_clean2.fq" >> $out_dir/samples.tsv