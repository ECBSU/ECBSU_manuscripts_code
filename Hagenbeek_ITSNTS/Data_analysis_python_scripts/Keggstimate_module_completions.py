#!/usr/bin/env python3
"""
Parses all KEGG completion calculation output files in the input directory, 
parses KEGG module completions, and calculates Bray-Curtis dissimilarities based on completions.
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
        
def filter_parse(filter_list_path):
    """
    """
    out_list = []
    for line in gen_line_reader(filter_list_path):
        if line.strip():
            out_list.append(line.strip())
    return out_list

def keggstimate_completion_parser(eggnog_path):
    """
    Parses an KEGG_completion.tsv output file. Returns a list of completion values
    
    Since keggstimate always outputs all modules in the same order, do not need to store module information
    """
    out_list = []
    for line in gen_line_reader(eggnog_path):
        if line.startswith("#"):
            continue
        else:
            out_list.append((line.split("\t")[0],float(line.split("\t")[2])))
    return out_list


def output_tsv(outname, out_dict):
    """
    """
    with open(outname, "w") as out:
        out.write("#")
        for sample in out_dict:
            out.write(sample + "\t")
        out.write("\n")
        for sample1 in out_dict:
            for sample2 in out_dict:
                out.write(str(out_dict[sample1][sample2]) + "\t")
            out.write("\n")
    
if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads all the KEGG_completion.tsv keggstimate outputs in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file')
    parser.add_argument('-i', help='Path to input directory', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of output tsv file', required=True, dest="out")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    output = in_args["out"]
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
        
    sample_dict = {}
    #For the given directory, read the KEGGstimate completion outputs and parse out the modules and their completion
    for subdir, dirs, files in os.walk(in_dir): #iterate over all directories and subdirectories
            for file in files: #iterate over all files
                if file.endswith("KEGG_completion.tsv") and "Metagenome_KEGGstimate" in subdir:
                    sample = file.partition(".emapper.annotations")[0]
                    if sampl_list:
                        if sample not in sampl_list:
                            continue
                    completion_values = keggstimate_completion_parser(os.path.join(subdir,file))
                    sample_dict[sample] = completion_values
            
    with open(output, "w") as out:
        header = True
        for sample in sample_dict:
            if header:
                out.write("Sample\t")
                for tup in sample_dict[sample]:
                    out.write(str(tup[0]) + "\t")
                out.write("\n")
                header = False
            out.write(sample + "\t")
            for tup in sample_dict[sample]:
                out.write(str(tup[1]) + "\t")
            out.write("\n")
                