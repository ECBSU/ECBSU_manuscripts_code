#!/bin/bash
#SBATCH -p compute
#SBATCH -t 3-0
#SBATCH --mem=300G
#SBATCH -c 96
#SBATCH -n 1
#SBATCH --job-name=trinity
#SBATCH --output=trinity.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yong.phua@oist.jp

module load Trinity
module load ruse
ruse Trinity --seqType fq --samples_file /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/samples.tsv --CPU 96 --max_memory 400G --full_cleanup

module load singularity
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta --seqType fq --samples_file /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/samples.tsv --trinity_mode --thread_count 96 --output_dir /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/abun --est_method salmon --prep_reference
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta --seqType fq --samples_file /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/samples.tsv --trinity_mode --thread_count 96 --output_dir /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/abun --est_method salmon 
module unload singularity

module load BUSCO
busco -m transcriptome -i /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta -c 96 -o busco -l alveolata_odb10
module unload BUSCO

/apps/unit/HusnikU/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta
/apps/unit/HusnikU/ncbi-blast-2.11.0+/bin/blastp -query /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta.transdecoder_dir/longest_orfs.pep -db /flash/HusnikU/databases/swissprot/uniprot_sprot  -max_target_seqs 1 -outfmt 6 -evalue 1e-5 -num_threads 96 > blastp.outfmt6
/apps/unit/HusnikU/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t /flash/HusnikU/Phua_2/sino_transcriptome_SL1234/trinity_out_dir.Trinity.fasta --retain_blastp_hits blastp.outfmt6

