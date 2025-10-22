#!/bin/bash
#SBATCH -p compute
#SBATCH -t 3-0
#SBATCH --mem=200G
#SBATCH -c 96
#SBATCH -n 1
#SBATCH --job-name=trinity
#SBATCH --output=trinity.log
#SBATCH --mail-type=ALL
#SBATCH --mail-user=yong.phua@oist.jp

work_dir=/flash/HusnikU/Phua_2/vasyl_transcriptome
sample=$work_dir/samples.tsv
abundance_dir=/flash/HusnikU/Phua_2/vasyl_transcriptome/abun
cd $work_dir

#denovo assembly
out_transcript=$work_dir/trinity_out_dir.Trinity.fasta

module load singularity
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg Trinity --seqType fq --samples_file $sample --CPU 96 --max_memory 300G --full_cleanup
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts $out_transcript --seqType fq --samples_file $sample  --trinity_mode --thread_count 96 --output_dir $abundance_dir --est_method salmon --prep_reference
singularity exec -e /apps/unit/HusnikU/trinityrnaseq.v2.15.0.simg /usr/local/bin/util/align_and_estimate_abundance.pl --transcripts $out_transcript --seqType fq --samples_file $sample  --trinity_mode --thread_count 96 --output_dir $abundance_dir --est_method salmon 
module unload singularity

#busco qc
module load BUSCO
busco -m transcriptome -i $out_transcript -c 96 -o busco -l /flash/HusnikU/Phua_2/busco/busco_downloads/lineages/alveolata_odb10 --offline
module unload BUSCO

#protien prediction
/apps/unit/HusnikU/TransDecoder-TransDecoder-v5.5.0/TransDecoder.LongOrfs -t $out_transcript
/apps/unit/HusnikU/TransDecoder-TransDecoder-v5.5.0/TransDecoder.Predict -t $out_transcript
