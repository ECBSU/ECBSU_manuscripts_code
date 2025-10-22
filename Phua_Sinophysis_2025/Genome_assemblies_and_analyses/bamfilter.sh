conda activate blobtools
/Users/yonghengphua/Documents/programmes/blobtools/blobtools  bamfilter -i missing3_percid90.txt -b /Volumes/bucket/HusnikU/Unit_Members/Phua_internship_files/Sino_prj/CyanoGenome/Sinophysis_pooled_cells_spades/sorted.mapped.bam  -n -U -f fq -o missing3_percid90
cat *.fq > subset_mapped.fastq
cat subset_mapped.fastq | paste - - - - - - - - | tee >(cut -f 1-4 | tr "\t" "\n" > subset_mapped.F.fastq) | cut -f 5-8 | tr "\t" "\n" > subset_mapped.R.fastq