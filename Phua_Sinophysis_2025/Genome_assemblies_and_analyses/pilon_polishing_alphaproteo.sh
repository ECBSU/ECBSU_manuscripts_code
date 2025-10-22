
#-------------Softwares--------------#
BAM_READCOUNT='/apps/unit/HusnikU/bam-readcount/build/bin/bam-readcount'
BOWTIE2='/apps/unit/HusnikU/bowtie2-2.4.4-linux-x86_64'
SAMTOOLS='/apps/unit/HusnikU/samtools-1.15.1'

# for Pilon
ml bioinfo-ugrp-modules
ml DebianMed
ml pilon

source /home/a/akito-shima/conda_init.sh
conda activate /home/a/akito-shima/miniconda3/envs/core
#------------------------------------#


# Define file and directory paths
RUN_DIR='/flash/HusnikU/Phua_2/20250710_mapsym2/pilon_polish'
prefix='sym2'

cd $RUN_DIR || exit

reference_fasta='/flash/HusnikU/Phua_2/20250710_mapsym2/pilon_polish/PROKKA_06122024.fna'
read_f="/bucket/.deigo/HusnikU/Sequencing_data/06_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R1_001.fastq.gz"
read_r="/bucket/.deigo/HusnikU/Sequencing_data/06_NovaSeq_210610_A00457_0167_AHNTGGDRXX_Phua/Data/Intensities/BaseCalls/1-2_HusnikU_ID199/Sinophysis_S24_R2_001.fastq.gz"

# Pilon iteration
i=1 # iteration number

while : ; do
    echo
    echo "Iteration $i"
    echo

    mkdir -p "pilon$i"

    # Run bowtie2 to map the read to the reference
    echo 'bowtie2 began.'
    $BOWTIE2/bowtie2-build -f -q --threads 3 $reference_fasta "$RUN_DIR"/pilon$i/"$prefix"_Pilon$i
    $BOWTIE2/bowtie2 -q  --reorder --threads 3 --time --met-stderr --met 10 \
      -x "$RUN_DIR"/pilon$i/"$prefix"_Pilon$i -1 $read_f -2 $read_r > $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sam
    echo 'bowtie2 ended.'


    # Convert sam file to bam file and sort
    echo "samtools began."
    $SAMTOOLS/samtools view -b -@ 2 $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sam -o $RUN_DIR/pilon$i/"$prefix"_Pilon$i.bam
    $SAMTOOLS/samtools sort -@ 2 $RUN_DIR/pilon$i/"$prefix"_Pilon$i.bam -o $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sorted.bam
    $SAMTOOLS/samtools index -b -@ 2 $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sorted.bam
    echo "samtools ended."

    rm -f $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sam
    rm -f $RUN_DIR/pilon$i/"$prefix"_Pilon$i.bam

    # Pilon polising
    echo "Pilon began."
    pilon --genome $reference_fasta --frags $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sorted.bam --fix all \
        --outdir "$RUN_DIR/pilon$i" --changes --verbose

    echo "Pilon ended."

    # Create depth graph
    $BAM_READCOUNT --max-warnings 1 --reference-fasta $reference_fasta $RUN_DIR/pilon$i/"$prefix"_Pilon$i.sorted.bam > $RUN_DIR/pilon$i/"$prefix"_Pilon$i.bam.txt
    /flash/HusnikU/Akito/Jobs/codes/read_count_figure_generator.py -i $RUN_DIR/pilon$i/"$prefix"_Pilon$i.bam.txt -o $RUN_DIR/pilon$i

    # Break the loop when pilon did not make any changes
    if [ ! -s $RUN_DIR/pilon$i/pilon.changes ] ; then
      break
    fi

    # increment iteration number
    reference_fasta="$RUN_DIR/pilon$i/pilon.fasta"
    ((i++))

    done

echo "Pilon iteration ended with $i times."

### Slurm to be run with sbatch Pilon_template.slurm