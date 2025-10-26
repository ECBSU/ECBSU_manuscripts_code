# Illumina short gun data

# FastQC

fastqc test_R1.fastq.gz test_R2.fastq.gz

# fastP

fastp -i test_R1.fastq.gz -I test_R2.fastq.gz -o Test_R1.fastq.gz -O Test_R2.fastq.gz

# Spades 150

/apps/unit/HusnikU/SPAdes-3.15.3-Linux/bin/spades.py      
-1 /flash/HusnikU/Pradeep/Scale_insect/Spades_3.15.3_assembly/STFO_S19_L008_R1_001.fastq.gz \        
-2 /flash/HusnikU/Pradeep/Scale_insect/Spades_3.15.3_assembly/STFO_S19_L008_R2_001.fastq.gz \        
-o /flash/HusnikU/Pradeep/Scale_insect/Spades_3.15.3_assembly/STFO_Spades \  
-k 27,53,71,87,99,111,119,127 -t 96 -m 400 --careful \

# Spades 250

/home/ecbsu/programs/SPAdes-3.15.4-long-K/bin/spades.py      
-1 /data1/Scaleinsect_Set3/ICSE/ICSE_S7_R1_001_trimmed.fastq.gz \    
-2 /data1/Scaleinsect_Set3/ICSE/ICSE_S7_R2_001_trimmed.fastq.gz \    
-o /data1/Scaleinsect_Set3/ICSE/ICSE_Spades_245 \ 
-k 21,49,77,105,133,161,189,217,245 -t 96 -m 400 --careful \

# megablast

/apps/unit/HusnikU/ncbi-blast-2.11.0+/bin/blastn 
-task megablast -query /flash/HusnikU/Pradeep/Scale_insect/Spades_3.15.3_megablast/PSJA_scaffolds.fasta \ 
-db /bucket/HusnikU/Databases/nt/nt -outfmt '6 qseqid staxids bitscore std sscinames sskingdoms stitle' \ 
-culling_limit 5 -num_threads 96 \ 
 -evalue 1e-25 -max_target_seqs 5 > /flash/HusnikU/Pradeep/Scale_insect/Spades_3.15.3_megablast/PSJA_scaffolds_vs_nt.blast \

# Blobtools

./blobtools create -i Orthezia_urticae/Orthezia_urticae_spades.fasta -y spades \ 
-t Orthezia_urticae/Orthezia_urticae_scaffolds_vs_nt.blast -o Orthezia_urticae/Orthezia_urticae_blobtools  

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r superkingdom 

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r phylum 

./blobtools plot -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r order 

./blobtools view -i Orthezia_urticae/Orthezia_urticae_blobtools.blobDB.json -r all


# Custom perl script


perl -ne 'if(/^>(\S+)/){$c=$i{$1}}$c?print:chomp;$i{$_}=1 if @ARGV' ids_of_seqs_to_extract.txt all_sequences.fasta > extracted_sequences.fasta



# pilon

/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2-build Bombella_like_PHMI_nextpolish.fasta PHMI_index/PHMI_bowtie 
/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2-inspect PHMI_index/PHMI_bowtie
/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64/bowtie2 -x PHMI_index/PHMI_bowtie -1 PHSP2_S18_L001_R1_001.fastq.gz -2 PHSP2_S18_L001_R2_001.fastq.gz -S PHMI_mapped.sam --reorder --mm -p 96
/apps/unit/HusnikU/samtools-1.2/samtools view -Sb PHMI_mapped.sam -o PHMI_mapped.bam
/apps/unit/HusnikU/samtools-1.2/samtools sort PHMI_mapped.bam PHMI_sorted.mapped
/apps/unit/HusnikU/samtools-1.2/samtools index PHMI_sorted.mapped.bam
/apps/unit/HusnikU/pilon --genome Bombella_like_PHMI_nextpolish.fasta --bam PHMI_sorted.mapped.bam  --output Bombella_like_PHMI_nextpolish_pilon

