#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_bin_function_profile_%a.out
#SBATCH -t 4-0
#SBATCH --mem=254G #128 crashed
#SBATCH -c 64

#Read input variables to find the appropriate file names
readarray -t a < $1
outdir=$2

#Annotate the bins with KEGGstimate
source $3
conda activate $4
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/eggnog_temp_dir
for i in *.fa; do 
emapper.py -m mmseqs --mmseqs_db $5 --data_dir $6 -i $i --itype genome -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate/${i} --cpu 64 --dbmem --temp_dir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/eggnog_temp_dir --override;
python $7 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate/${i}.emapper.annotations ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate/${i}.emapper.annotations $8;
python $9 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate/${i}.emapper.annotations ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_KEGGstimate/${i}.emapper.annotations_pathway_and_BRITE ${10};
done

rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/eggnog_temp_dir

#Annotate the prokaryote reads with Gapseq
#conda activate ${11}
#mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_gapseq
#cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/
#for i in *.fa; do 
#cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_gapseq
#gapseq doall ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/$i -K 64;
#done
#for i in *-all-Reactions.tbl; do
#python /bucket/HusnikU/Unit_Members/Arno/Scripts/Gapseq_reactions_to_kterm.py -i $i -o ${i}_KEGG_converted.txt -db ${10};
#done
#python /bucket/HusnikU/Unit_Members/Arno/Scripts/Gapseq_transporter_parser.py ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bin_annotation

conda activate ${12} 
coverm genome --genome-fasta-directory ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/ --coupled ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins_coverm_output -x fa -t 64
rm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_1_trimmed.fastq 
rm ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/${a[${SLURM_ARRAY_TASK_ID}]}_2_trimmed.fastq