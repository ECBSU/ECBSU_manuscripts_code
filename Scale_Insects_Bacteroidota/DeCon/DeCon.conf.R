# All files will be named as label+basename
label="DASP" # <str>

# NGS reads
fq1="/bucket/HusnikU/Unit_Members/Jinyeong/Fastp/DASP_S6_R1_001_trimmed.fastq.gz" # <path>
fq2="/bucket/HusnikU/Unit_Members/Jinyeong/Fastp/DASP_S6_R2_001_trimmed.fastq.gz" # <path>

# assembly
genome="/flash/HusnikU/Jinyeong/Spades_multiK127/DASP/scaffolds.fasta" # <path>

# target phylum
target="Arthropoda"

# diamond database (nr)
nr.dmnd="/apps/unit/BioinfoUgrp/DB/diamondDB/ncbi/2022-07/nr.dmnd" # <path>
# megan database
megan.db="/bucket/HusnikU/Databases/megandb/megan-map-Feb2022.db" # <path>
# BUSCO database
busco.db="/flash/HusnikU/Jinyeong/hemiptera_odb10"

# output directory
out_dir="/flash/HusnikU/Jinyeong/Spades_decon/DASP_multiK127" # <path>

# threads
threads=128 # <int>
