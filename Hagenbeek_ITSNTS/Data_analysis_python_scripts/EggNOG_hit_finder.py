#!/usr/bin/env python3
"""
Reads all eggnog .annotations output files in the provided directory and lists the number of hits per sample.
"""
###################
# Import statements
###################  
import sys
import os
import argparse

###################
# File handling functions
###################  

def gen_line_reader(file_path):
    """
    Generator function that allows reading a text file line
    by line, without reading the full file into memory
    """
    for line in open(file_path, "r"):
        yield line

def EggNOG_parser(file_path):
    """
    Reads an eggnog .annotations output file and counts the number of hits found. 
    """
    len_counter = 0
    for line in gen_line_reader(file_path):
        if line.strip():
            if not line.startswith("#"):
                len_counter += 1
    return len_counter

if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads all fasta files in an input directory, and outputs a text file containing their sizes. IMPORTANT: Only intended for Megahit assemblies, as it is designed for their naming convention, parsing the length values from the header lines')
    parser.add_argument('-i', help='Path to the directory containing the fasta files', required=True, dest="in")
    parser.add_argument('-o', help='Path/name of the output text file', default = False, dest="out")
    in_args = vars(parser.parse_args())
    
    out_dict = {}
    #Iterate over all directories and subdirectories in the given directory
    for subdir, dirs, files in os.walk(in_args["in"]): 
            #Iterate over all contained files, only considering the eggnog output in the Metagenome_KEGGstimate folder
            for file in files: 
                if file.endswith(".emapper.annotations"):
                    if "Metagenome_KEGGstimate" in subdir:
                        sample = file.partition(".emapper.annotations")[0]
                        print(sample)
                        #Find the size in bp of the whokaryote-filtered assembly
                        out_dict[sample] = EggNOG_parser(os.path.join(subdir,file))
    
    #Output sizes to a tab-delimited text file
    with open(in_args["out"], "w") as out:
        for sample in out_dict:
            out.write(sample + "\t" + str(out_dict[sample]) + "\n")
            
    