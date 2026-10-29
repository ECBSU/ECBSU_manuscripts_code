#!/bin/bash

#SBATCH -p compute
#SBATCH --output=/flash/HusnikU/Arno/Slurm_outputs/main_analysis_non_redundant_bin_stats_%a.out
#SBATCH -t 4-0
#SBATCH --mem=256G #Pplacer takes a lot of memory
#SBATCH -c 128

readarray -t a < $1
outdir=$2
conda_ex=$3

#Move the bins to a single folder, renaming the bins after the origin software if required
###########################
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Semibin/*.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabat/*.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/

cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct/
for i in *.fa; do mv ${i} CONCOCT_${i%.*}.fa; done
cd ${outdir}
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct/*.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/

cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella/
for i in *.fna; do mv ${i} ${i%.*}.fa; done
cd ${outdir}
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella/*.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/

#Rename the Dastool outputs, so they dont replace the originals
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Dastool/
for i in *.fa; do mv ${i} Dastool_${i}; done
cd ${outdir}
mv ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Dastool/*.fa ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/

#Remove the now empty directories
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Semibin/
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Concoct/
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Metabat/
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Rosella/
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Dastool/

#Run checkm2
source $conda_ex
conda activate $4

$5 predict --threads 128 --input ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins --output-directory ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Checkm2 --database_path $6 -x fa --force

#Copy non-redunant bins for downstream processing
#Stats hard-coded here:
#Minimum size = 300Kb
#Minimum completion = 50%
#Max contamination = 10%

python $7 -i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/bin_groups.txt -m 20
python $8 -1 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/bin_groups.txt -2 ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Checkm2/quality_report.tsv -o ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/non_redundant_bins.txt --min_size 300 --min_compl 50 --max_cont 10
readarray -t nonredundant < ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/non_redundant_bins.txt
mkdir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins
cd ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/All_bins/
for i in ${nonredundant[@]}; do 
cp $i ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/ ; 
done

#Identify the non-redunant bins
conda activate $9 
gtdbtk classify_wf --genome_dir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/Best_bins/ --out_dir ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/gtdbtk --skip_ani_screen --extension fa --cpus 128
rm -r ${outdir}/${a[${SLURM_ARRAY_TASK_ID}]}/gtdbtk/align