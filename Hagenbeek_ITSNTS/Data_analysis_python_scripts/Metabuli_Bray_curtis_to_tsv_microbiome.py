#!/usr/bin/env python3
"""
Reads all the _report.tsv Metabuli outputs in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file
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

def metabuli_parse(dir_path, level, sampl_list):
    """
    Parser function. Searches all files in the given directory for Metabuli _report.tsv output files.
    Parses the RELATIVE BACTERIAL abundances from the provided taxonomic level from the files and outputs as the 
    dictionary {[sample_name][taxon_name] = taxon assigned reads / total bacterial reads}
    
    Sampl_list is a list of sample names to be considered. If a sample is not in the list, the sample will be omitted.
    Alternatively, sampl_list can be given as a boolean "False", in which case all samples will be considered.
    """
    abu_dict = {}
    name_list = []
    #Iterate over all directories and subdirectories in the given directory
    for subdir, dirs, files in os.walk(dir_path): 
        #Iterate over all files, only considering the Metabuli outputs
        for file in files: 
            if file.endswith("_report.tsv") and "quality_report.tsv" not in file:
                #Find sample name, and initiate dictionary entry
                sample = file.partition("_report.tsv")[0]
                if sampl_list:
                    if sample not in sampl_list:
                        continue
                abu_dict[sample] = {}
                within_bacteria = False #Variable to be activated if within bacterial entries
                #Iterate over each line of the report file, parsing the assigned reads, taxonomic level and taxon name
                for line in gen_line_reader(os.path.join(subdir,file)):
                    splt = line.split("\t")
                    assigned_reads = int(splt[1])
                    lvl = splt[3].strip()
                    name = splt[5].strip()
                    #To prevent inclusion of non-bacterial reads, only start storing if within the bacterial superkingdom
                    if name == "d__Bacteria":
                        within_bacteria = True
                        total_bact_reads = assigned_reads #Store total bacterial reads for normalization
                        continue
                    if within_bacteria:
                        #if we reach another superkingdom we have left bacterial assignments, and will break the loop
                        if lvl == "superkingdom":
                            break
                        #If we are within bacterial assignments, and the line contains the specified taxonomic level, add the normalized read counts to the dictionary
                        if level == lvl:
                            name_list.append(name.partition("__")[2])
                            abu_dict[sample][name.partition("__")[2]] = assigned_reads / total_bact_reads
    
    #Convert the "name"-based dictionary into an ordered list, and add missing "name"s as 0s
    name_list = set(name_list)
    print("Total variables: {}". format(len(name_list)))
    for sample in abu_dict:
        new_list = []
        for name in name_list:
            if name in abu_dict[sample]:
                new_list.append(abu_dict[sample][name])
            else:
                new_list.append(0)
        abu_dict[sample] = new_list
    return abu_dict               

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
    parser = argparse.ArgumentParser(description='Reads all the _report.tsv Metabuli outputs in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file')
    parser.add_argument('-i', help='Path to input directory', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of output tsv file. Optional argument, and when not provided, only outputs the number of considered variables without dissimilarity calculation', required=False, dest="out")
    parser.add_argument('-l', help='Taxonomic level to calculate for. Uses level name without capital letter, e.g. phylum, class etc. ', required=True, dest="level")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    level = in_args["level"]
    out = in_args["out"]
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False

    #Parse the Metabuli outputs
    abundance_dict = metabuli_parse(in_dir, level, sampl_list)    
    if in_args["out"]:
        out = in_args["out"]
        #Calculate Bray-Curtis dissimilarities
        dissim_dict = {}
        for sample1 in abundance_dict:
            print(sample1)
            dissim_dict[sample1] = {}
            for sample2 in abundance_dict:
                dissim_dict[sample1][sample2] = distance.braycurtis(abundance_dict[sample1],abundance_dict[sample2])
        #Output dissimilarities to a tsv file
        output_tsv(out, dissim_dict)
    