#!/bin/bash

# Specify the path to pal2nal.pl script
PAL2NAL="/Users/jinyeongchoi/Desktop/Bioinformatics/pal2nal.v14/pal2nal.pl"

# Iterate over protein files in the current directory
for protein_file in *_mafft.faa; do
    # Extract file name without extension and "_mafft"
    protein_filename_noext="${protein_file%_mafft.faa}"

    # Corresponding nucleotide file
    nucleotide_file="${protein_filename_noext}.ffn"

    # Check if the nucleotide file exists
    if [ -e "$nucleotide_file" ]; then
        # Run pal2nal command for each pair of protein and nucleotide files
        "$PAL2NAL" "$protein_file" "$nucleotide_file" -output paml > "${protein_filename_noext}_pal2nal.fa"
    else
        echo "Nucleotide file not found for $protein_filename_noext. Skipping."
    fi
done
