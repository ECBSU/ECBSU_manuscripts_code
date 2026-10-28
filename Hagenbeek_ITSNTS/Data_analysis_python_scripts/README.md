# Python analysis scripts
## General workflow outline
The workflow proceeded in multiple steps:
 1) The raw shotgun sequencing data was processed using the bioinformatics pipeline, generating eggNOG-mapper annotations and LCA taxonomic assignments
    - https://github.com/ECBSU/ECBSU_manuscripts_code/tree/main/Hagenbeek_ITSNTS/Slurm_scripts
 2) Based on annotation metrics, samples that met quality criteria (at least 2500 eggNOG-mapper annotations) were determined. These filenames were stored in a newline-delimited file. 
    - EggNOG_hit_finder.py
    - Hit_count_to_filter_tsv.py
 3) Based on these filtered samples, a script would read all generated eggNOG-mapper outputs and LCA software outputs, and calculate Bray-Curtis dissimilarities. These dissimilarities were then saved as a matrix in a tab-delimited file. 
    - EggNOG_COG_counts_Bray_curtis_to_tsv_normalized.py
    - EggNOG_EC_code_Bray_curtis_to_tsv_normalized.py
    - EggNOG_orthologs_Bray_curtis_to_tsv_normalized.py
    - EggNOG_PFAM_Bray_curtis_to_tsv_normalized.py
    - Keggstimate_module_completions_Bray_curtis_to_tsv.py
    - Kraken2_Bray_curtis_to_tsv_microbiome.py
    - Metabuli_Bray_curtis_to_tsv_microbiome.py
    - phyloFlash_Bray_curtis_to_tsv_microbiome.py
 4)  Bray-Curtis dissimilarities were visualized as either violin plots or PCoA cluster plots.
     - Distance_matrices_to_multiple_violin_plot.py
     - Distance_matrix_to_PCoA.py

## Long-read approach
The workflow proceeded largely as above, though with a modified bioinformatics pipeline:
 1) The raw long reads were processed with the appropriate bioinformatics pipeline, generating eggNOG-mapper annotations and Kraken2 taxonomic assignments
    - https://github.com/ECBSU/ECBSU_manuscripts_code/tree/main/Hagenbeek_ITSNTS/Slurm_scripts/
 2) A script would read all generated eggNOG-mapper outputs and LCA software outputs, and calculate Bray-Curtis dissimilarities. These dissimilarities were then saved as a matrix in a tab-delimited file. 
    - EggNOG_COG_counts_Bray_curtis_to_tsv_normalized.py
    - EggNOG_EC_code_Bray_curtis_to_tsv_normalized.py
    - EggNOG_orthologs_Bray_curtis_to_tsv_normalized.py
    - EggNOG_PFAM_Bray_curtis_to_tsv_normalized.py
    - Keggstimate_module_completions_Bray_curtis_to_tsv.py
    - Kraken2_Bray_curtis_to_tsv_microbiome.py
    - Metabuli_Bray_curtis_to_tsv_microbiome.py
    - phyloFlash_Bray_curtis_to_tsv_microbiome.py
 4)  Bray-Curtis dissimilarities were visualized as either violin plots or PCoA cluster plots.
     - Distance_matrices_to_multiple_violin_plot.py
     - Distance_matrix_to_PCoA.py

## Genome-resolved approach
The general workflow bioinformatics pipeline also generated MAGs, and their functional and taxonomic annotations. The following scripts then built on this data:
 1)  It was assessed for which samples sufficient reads mapped to the generated MAGs. These were stored in a newline-delimited file.
     - CoverM_to_filter_tsv.py
 3) Based on these filtered samples, a script would read all generated eggNOG-mapper outputs, GTDB-Tk software outputs, and CoverM outputs. It would then calculate Bray-Curtis dissimilarities based on the annotations and taxonomies, normalized by the read coverage of the corresponding MAG. These dissimilarities were then saved as a matrix in a tab-delimited file. 
    - MAG_EggNOG_COG_Bray_curtis_to_tsv_coverM_normalized.py
    - MAG_EggNOG_EC_code_Bray_curtis_to_tsv_coverM_normalized.py
    - MAG_EggNOG_KEGG_orthologs_Bray_curtis_to_tsv_coverM_normalized.py
    - MAG_EggNOG_PFAM_Bray_curtis_to_tsv_coverM_normalized.py
    - MAG_KEGGstimate_module_Bray_curtis_to_tsv_coverM_normalized.py
    - MAG_GTDBTK_coverM_Bray_curtis_to_tsv_.py
 4)  Bray-Curtis dissimilarities were visualized as either violin plots or PCoA cluster plots.
     - Distance_matrices_to_multiple_violin_plot.py
     - Distance_matrix_to_PCoA.py
 5)  For the in-depth rodent analysis, a heatmap was generated based on the cumulative MAG read mapping.
     - Distance_matrices_to_multiple_violin_plot.py
     - Distance_matrix_to_PCoA.py
