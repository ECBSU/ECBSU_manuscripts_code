# Scripts
 This directory contains the scripts and pipelines used within the analyses.

 ## Contents
  - **EggNOG_KEGG_KO_extracter.py:** Python script converting EggNOG output into a tsv file compatible with KEGG reconstruct
  - **MAG_generation_step1_binning:** Slurm pipeline for bin creation
  - **MAG_generation_step2_bin_identification:** Slurm pipeline for MEGAN and SSU-based identification of the bins
  - **MAG_generation_step3_bin_id_consolidation:** Python file to make a report file summarizing the identification results per bin
  - **SRA_download_and_assemby:** Slurm pipeline to download and assemble all relevant SRA entries
