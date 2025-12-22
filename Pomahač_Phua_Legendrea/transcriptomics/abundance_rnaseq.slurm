#!/bin/bash
#SBATCH -p compute
#SBATCH -t 8:00:00
#SBATCH --mem=16G
#SBATCH -c 32
#SBATCH -n 1
#SBATCH --job-name=transcriptome
#SBATCH --output=abundance.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yongheng.phua@oist.jp

module load singularity
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts transcripts.fasta --seqType fq --samples_file samples.tsv --gene_trans_map /bucket/HusnikU/Unit_Members/Phua_internship_files/Daniel/ledg_transcript/SPAdes/gene_trans_map.txt --thread_count 32 --output_dir /flash/HusnikU/Phua_2/ledg_transcript --est_method RSEM --aln_method bowtie --prep_reference 
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts transcripts.fasta --seqType fq --samples_file samples.tsv --gene_trans_map /bucket/HusnikU/Unit_Members/Phua_internship_files/Daniel/ledg_transcript/SPAdes/gene_trans_map.txt --thread_count 32 --output_dir /flash/HusnikU/Phua_2/ledg_transcript --est_method RSEM --aln_method bowtie
