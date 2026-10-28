#!/usr/bin/env python3
"""
Reads all the _.phyloFlash.NTUabundance.csv outputs from phyloFlash in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file
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

def phyloFlash_parse(dir_path, level, sampl_list):
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
            if file.endswith("_phyloflash.phyloFlash.NTUabundance.csv"):
                #Find sample name, and initiate dictionary entry
                sample = file.partition("_phyloflash.phyloFlash.NTUabundance.csv")[0]
                if sampl_list:
                    if sample not in sampl_list:
                        continue
                abu_dict[sample] = {}
                #First iterate over the list, counting the total bacterial reads for normalization
                tot_bact_reads = []
                for line in gen_line_reader(os.path.join(subdir,file)):
                    if line.startswith("Bacteria"):
                        tax = line.split(",")[0].split(";")
                        if level == "phylum":
                            if "(" in tax[1]:
                                continue
                        elif level == "class":
                            if "(" in tax[2]:
                                continue
                        elif level == "order":
                            if "(" in tax[3]:
                                continue
                        tot_bact_reads.append(int(line.split(",")[1]))
                print(file)
                tot_bact_reads = sum(tot_bact_reads)
                print(tot_bact_reads)
                #Then go over the list again, outputting normalized abundance values of bacterial taxa
                for line in gen_line_reader(os.path.join(subdir,file)):
                    if line.startswith("Bacteria"):
                        assigned_reads = int(line.split(",")[1].strip())
                        tax = line.split(",")[0].split(";")
                        if level == "phylum":
                            name = tax[1]
                        elif level == "class":
                            name = tax[2]
                        elif level == "order":
                            name = tax[3]
                        if name.startswith("("): #Bracketed taxa mean that this taxon wasnt clear at this level
                            continue
                        if name in abu_dict[sample]:
                            abu_dict[sample][name] += assigned_reads / tot_bact_reads
                        else:
                            abu_dict[sample][name] = assigned_reads / tot_bact_reads
                        name_list.append(name)
    
    #Convert the "name"-based dictionary into an ordered list, and add missing "name"s as 0s
    name_list = set(name_list)
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
    parser = argparse.ArgumentParser(description='Reads all the _.phyloFlash.NTUabundance.csv outputs from phyloFlash in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file')
    parser.add_argument('-i', help='Path to input directory', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of output tsv file', required=True, dest="out")
    parser.add_argument('-l', help='Taxonomic level to calculate for. Uses level name without capital letter, e.g. phylum, class etc. Does not go below order level, as this is the default limit in phyloFlash. ', required=True, dest="level")
    parser.add_argument('-m', help='Minimum percentage to consider. Taxonomies with relative abundance percentages below this value will be discarded. (default= 0)', default=0, dest="min")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    level = in_args["level"]
    if level != "phylum" and level != "class" and level != "order":
        print("Error, invalid taxonomic level. Please use phylum, class, or order")
        sys.exit()
    minimum = float(in_args["min"])
    out = in_args["out"]
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
               
    
    #Parse the phyloFlash outputs
    abundance_dict = phyloFlash_parse(in_dir, level, sampl_list)
    #Calculate Bray-Curtis dissimilarities
    dissim_dict = {}
    for sample1 in abundance_dict:
        print(sample1)
        dissim_dict[sample1] = {}
        for sample2 in abundance_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(abundance_dict[sample1],abundance_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out, dissim_dict)
    