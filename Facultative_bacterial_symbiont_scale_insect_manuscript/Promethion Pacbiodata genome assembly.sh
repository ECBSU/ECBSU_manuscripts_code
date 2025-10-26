# long read data

# Nanopack suite

# Nano QC

nanoQC -o NIVS_nanoqc_output NIVS.fastq.gz

# Nano stat

NanoStat --fastq NIVS.fastq.gz --outdir NIVS_nanostat_output \ 
--name NIVS_nanostat_output --prefix NIVS_nanostat_output --threads 64 --tsv 

# Nano plot

NanoPlot -t 64 --fastq SRR26067558.fastq.gz -o COCA_nanoplot_output -p COCA_nanoplot \ 
--plots dot --legacy hex -f eps --dpi 600 --huge --tsv_stats

# FastpLong

fastplong -i NIVS.fastq.gz -o NIVS_fastplong.fastq.gz --thread 64 --failed_out failed_NIVS.fastq.gz \ 
--dont_overwrite --json --html --trim_poly_x --low_complexity_filter 

# Filtlong

filtlong --min_length 500 --min_mean_q 10 NIVS_fastplong.fastq.gz | gzip > NIVS_fastplong_filtlong.fastq.gz

# Flye assembler

# Flye Promethion data

flye --nano-hq NIVS_fastplong_filtlong.fastq.gz --out-dir NIVS_flye_assembly --threads 96 --iterations 2 --meta --scaffold 

# Flye Pacbio data

flye --pacbio-hifi COCA_fastplong_filtlong.fastq.gz --out-dir COCA_flye_assembly --threads 96 --iterations 2 --meta --scaffold 

# Megablast

/apps/unit/HusnikU/ncbi-blast-2.11.0+/bin/blastn -task megablast \ 
-query /flash/HusnikU/Pradeep/Scale_insect/Promethion/COCA/COCA_flye_assembly/assembly.fasta \ 
-db /apps/unit/BioinfoUgrp/DB/blastDB/ncbi/2022-07-nt/nt \ 
-outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' \ 
-culling_limit 5 -num_threads 128  -evalue 1e-25 \ 
-max_target_seqs 5 > /flash/HusnikU/Pradeep/Scale_insect/Promethion/COCA/COCA_flye_assembly/COCA_scaffolds_vs_nt.blast

# Blobtools

./blobtools create -i Orthezia_urticae/Orthezia_urticae_spades.fasta -y spades \ 
-t Orthezia_urticae/Orthezia_urticae_scaffolds_vs_nt.blast -o Orthezia_urticae/Orthezia_urticae_blobtools  

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r superkingdom 

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r phylum 

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r order 

./blobtools view -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r all


# Custom perlscript

perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' ids_of_seqs_to_extract.txt all_sequences.fasta > extracted_sequences.fasta

# Medaka

medaka_consensus -i NIVS_fastplong_filtlong.fastq.gz \ 
-d Pantoea_NIVS_extracted_sequences.fasta -o Pantoea_NIVS_medaka -m r941_min_sup_g507 -t 96

# Nextpolish2

minimap2 -ax map-hifi -t 96 Arsenophonus_COCA_extracted_sequences.fasta COCA_fastplong_filtlong.fastq.gz | samtools sort -@ 8 -o COCA_fastplong_filtlong.bam
samtools index COCA_fastplong_filtlong.bam

conda activate /bucket/HusnikU/Conda-envs/nextpolish2

yak count -b37 -k 31 -t96 -o COCA_fastplong_filtlong.yak <(zcat COCA_fastplong_filtlong.fastq.gz)

nextPolish2 -t 96 COCA_fastplong_filtlong.bam Arsenophonus_COCA_extracted_sequences.fasta COCA_fastplong_filtlong.yak > Arsenophonus_COCA_nextpolish.fasta

# Pilon

/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2-build Bombella_like_PHMI_nextpolish.fasta PHMI_index/PHMI_bowtie 
/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2-inspect PHMI_index/PHMI_bowtie
/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2 -x PHMI_index/PHMI_bowtie -1 PHSP2_S18_L001_R1_001.fastq.gz -2 PHSP2_S18_L001_R2_001.fastq.gz -S PHMI_mapped.sam --reorder --mm -p 96
/apps/unit/HusnikU/samtools-1.2/samtools view -Sb PHMI_mapped.sam -o PHMI_mapped.bam
/apps/unit/HusnikU/samtools-1.2/samtools sort PHMI_mapped.bam PHMI_sorted.mapped
/apps/unit/HusnikU/samtools-1.2/samtools index PHMI_sorted.mapped.bam
/apps/unit/HusnikU/pilon --genome Bombella_like_PHMI_nextpolish.fasta --bam PHMI_sorted.mapped.bam  --output Bombella_like_PHMI_nextpolish_pilon
