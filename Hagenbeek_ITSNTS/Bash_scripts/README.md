# Slurm scripts for microbiome analysis bioinformatics pipeline
## Description
This folder contains two pipelines, one executed on raw fastq files already present in-house (In_house_fastq_pipeline), and another one that automatically downloads and processes provided SRA entries (SRA_based_pipeline). 
## Requirements
Both pipelines were written in bash and designed to be run using a slurm-based planner. They could alternatively be used as simple bash scripts with limited adaptation. Both pipelines require the following tools to be installed, and to have their paths specified in the wrapper script:
### Dependencies
1. Conda executable
### Read processing and assembly
1. Fastp
2. Bowtie2
3. Samtools
4. Megahit
### Binning
1. CONCOCT
2. Metabat2
3. SemiBin2
4. Rosella
5. DASTool
### Taxonomic assignment
1. Kraken2
2. Metabuli
3. phyloFlash
4. GTDB-Tk
### Functional annotation
1. EggNOG-mapper
2. Custom scripts (Python scripts in this folder)
### MAG evaluation
1. Checkm2
2. CoverM
3. Custom scripts (Python scripts in this folder)

## Execution
The scripts are executed using a wrapper script. The samples to be processed are provided in a newline delimited text file (either file names or SRA accessions depending on the pipeline), written into line 11 of the wrapper script. The directory containing the files of these samples is specified in line 13, and the directory for the generated output is porivided in line 15. The number of files to be processed is the specified in line 18. 


NOTE: The pipelines currently still use several tools saved as modules on the OIST Deigo system. I still need to modify this, so the tools can be specified, and the pipelines executed in other systems. 
