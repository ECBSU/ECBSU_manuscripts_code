#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_long_read_function_%a.out
#SBATCH -t 7-0
#SBATCH --mem=128G
#SBATCH -c 64


ml bioinfo-ugrp-modules
ml DebianMed
ml kraken2

readarray -t a < <(cut -d';' -f1 $1)
outdir=$2

#Create a new fasta from the long read fastq
sed -n '1~4s/^@/>/p;2~4p' ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fastq > ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fasta

#Run whokaryote to filter out contaminating eukaryote contigs
source $3
conda activate $4
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Whokaryote
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Whokaryote
whokaryote.py --contigs ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_trimmed.fasta --minsize 1000 --outdir . --f --threads 32
mv eukaryotes.fasta ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_eukaryotes.fasta
mv prokaryotes.fasta ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes.fasta
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Whokaryote

#Annotate the prokaryote contigs with KEGGstimate
conda activate $5
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate
emapper.py -m mmseqs --mmseqs_db $6 --data_dir $7 -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes.fasta --itype metagenome -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]} --cpu 32 --dbmem
python $8 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]}.emapper.annotations ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]}.emapper.annotations $9
python ${10} ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]}.emapper.annotations ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_KEGGstimate/${a[${SLURM_ARRAY_TASK_ID}]}.fasta.emapper.annotations_pathway_and_BRITE ${11}

#Annotate the prokaryote reads with Gapseq
#conda activate ${12}
#mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_gapseq
#cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_gapseq
#cp ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes.fasta .
#gapseq doall ${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes.fasta -K 64
#python /bucket/HusnikU/Unit_Members/Arno/Scripts/Gapseq_reactions_to_kterm.py -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_gapseq/${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes-all-Reactions.tbl -o ${a[${SLURM_ARRAY_TASK_ID}]}_whokaryote_prokaryotes-all-Reactions_KEGG_converted.txt -db ${11}
#python /bucket/HusnikU/Unit_Members/Arno/Scripts/Gapseq_transporter_parser.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metagenome_gapseq