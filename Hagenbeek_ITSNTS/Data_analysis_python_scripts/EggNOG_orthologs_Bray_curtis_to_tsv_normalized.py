#!/usr/bin/env python3
"""
Parses all specified eggnog.annotations output files in the input directory, 
parses KEGG ortholog names, and calculates Bray-Curtis dissimilarities based on KEGG ortholog counts.
"""
###################
# Import statements
###################  

import sys
import os
import argparse
from scipy.spatial import distance

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

def eggnog_parser_normalized(eggnog_path):
    """
    Parses an eggnog.annotations output file. Returns a dictionary of EggNOG orthogroups with their corresponding hit counts
    """
    out_dict = {}
    hits = 0
    orths = []
    for line in gen_line_reader(eggnog_path):
        if line.startswith("#"):
            continue
        OG = line.split("\t")[4].split("|")[0]
        hits += 1
        orths.append(OG)
        if OG in out_dict:
            out_dict[OG] += 1
        else:
            out_dict[OG] = 1
    #Normalize the values by dividing by the total number of hits
    for key in out_dict:
        out_dict[key] = out_dict[key] / hits
    return out_dict, set(orths)

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
    parser = argparse.ArgumentParser(description='Reads all the .annotations eggnog outputs in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file')
    parser.add_argument('-i', help='Path to input directory', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of output tsv file', required=True, dest="out")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    out = in_args["out"]
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
    
    #Parse the eggnog outputs and compile a dictionary of EggNOG orthologs, skipping entries not in the filter sample list (if given)
    sample_dict = {}
    all_orths = []
    for subdir, dirs, files in os.walk(in_dir): #iterate over all directories and subdirectories
            for file in files: #iterate over all files
                if file.endswith(".emapper.annotations") and "Metagenome_KEGGstimate" in subdir:
                    sample = file.partition(".emapper.annotations")[0]
                    if sampl_list:
                        if sample not in sampl_list:
                            continue
                    print("Reading {}".format(file))
                    sample_dict[sample], orths = eggnog_parser_normalized(os.path.join(subdir,file))
                    for i in orths:
                        all_orths.append(i)
    
    #Add the missing values, and convert dictionary into an ordered list
    print("Adding missing values")
    set(all_orths)
    for sample in sample_dict:
        new_list = []
        for i in all_orths:
            if i not in sample_dict[sample]:
                new_list.append(0)
            else:
                new_list.append(sample_dict[sample][i])
        sample_dict[sample] = new_list                

    #Calculate Bray-Curtis dissimilarities       
    print("Calculating dissimilarities")
    dissim_dict = {}
    for sample1 in sample_dict:
        print(sample1)
        dissim_dict[sample1] = {}
        for sample2 in sample_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(sample_dict[sample1],sample_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out, dissim_dict)