#!/bin/bash

# Exit script on error, undefined variable, or error in a pipeline
set -euo pipefail

# Create a timestamped log file and tee all output to it
log_file="pipeline_$(date +'%Y%m%d_%H%M%S').log"
exec > >(tee -a "$log_file") 2>&1

# Define the directory containing the subdirectories
parent_directory="/Users/jinyeongchoi/Desktop/Projects/Bacteroidota/dN:dS_Symbiont_vs._free-living_bactrium_2nd/yn00_FLJO/"

# Iterate through each subdirectory
for dir in "$parent_directory"/*; do
    if [ -d "$dir" ]; then
        echo "Processing directory: $dir"
        # Change directory to the current subdirectory
        cd "$dir" || { echo "Error: Unable to change directory to $dir"; continue; }
        
        # Step 1: Extract sequences
        echo "Running sequence extraction scripts..."
        python extractSequencesIntoEachFasta_faa.py
        python extractSequencesIntoEachFasta_ffn.py

        # Step 2: Align .faa files with MAFFT
        echo "Running MAFFT alignment..."
        for file in *.faa; do
            if [[ -f "$file" ]]; then
                echo "Processing $file..."
                mafft "$file" > "${file%.faa}_mafft.faa"
            else
                echo "No .faa files found in $dir! Skipping alignment step."
                continue
            fi
        done

        # Step 3: Run the PAL2NAL script
        echo "Running PAL2NAL..."
        if [[ -x "./run_pal2nal.sh" ]]; then
            ./run_pal2nal.sh
        else
            echo "Error: PAL2NAL script not found or not executable in $dir!"
            continue
        fi

        # Step 4: Concatenate PAL2NAL output
        echo "Concatenating PAL2NAL outputs..."
        if python catPal2nal.py; then
            echo "PAL2NAL concatenation completed successfully."
        else
            echo "Error: Failed to concatenate PAL2NAL outputs in $dir."
            continue
        fi

        # Step 5: Run yn00
        echo "Running yn00 for dN/dS calculation..."
        if [[ -f "all_pal2nal.fa" ]]; then
            ./yn00
        else
            echo "Error: Input file 'all_pal2nal.fa' for yn00 not found in $dir!"
            continue
        fi

        # Step 6: Summarize dN/dS values
        echo "Summarizing dN/dS values..."
        if python summarize_dNdS.py; then
            echo "dN/dS summarization completed successfully for $dir."
        else
            echo "Error: Failed to summarize dN/dS in $dir."
            continue
        fi

        echo "Completed processing for directory: $dir"
    else
        echo "Skipping non-directory: $dir"
    fi
done

echo "All directories processed!"
