#!/usr/bin/env python3
"""
Parses all specified eggnog.annotations output files in the input directory, 
parses COG counts, and calculates Bray-Curtis dissimilarities based on COG counts.
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
    Parses an eggnog.annotations output file. Returns a dictionary of COGs with their corresponding hit counts
    """
    out_dict = {}
    hits = 0 
    all_cogs = []
    for line in gen_line_reader(eggnog_path):
        if line.startswith("#"):
            continue
        COG = line.split("\t")[6]
        if COG == "-" or COG == "S": #Ignore (S = Function unknown)
            continue
        #Terms are either single letters (T), or combinations of letters (KT). Convert both into a list. This means that KT is counted as a hit for both K and T, rather than a single hit for KT. 
        COG = list(COG)
        for term in COG:
            hits += 1
            all_cogs.append(term)
            if term in out_dict:
                out_dict[term] += 1
            else:
                out_dict[term] = 1
    #Normalize the values by dividing by the total number of hits
    for key in out_dict:
        out_dict[key] = out_dict[key] / hits
    return out_dict, set(all_cogs)

def Bray_Curtis_dissimilarity_calc(dict1, dict2):
    """
    Calculate Bray-Curtis dissimilarity values between two dictionaries
    """
    unique_entries = []
    count_list1 = []
    count_list2 = []
    lowest_list = []
    #Find the number of unique taxa in the dictionaries
    for key in dict1:
        if key not in unique_entries:
            unique_entries.append(key)
    for key in dict2:
        if key not in unique_entries:
            unique_entries.append(key)
    #Iterate over each unique taxon, finding their relative abundance        
    for key in unique_entries:
        if key in dict1:
            count1 = int(dict1[key]*1000) #*1000 is to turn the percentages into whole values suitable for the calculation
        else:
            count1 = 0
        if key in dict2:
            count2 = int(dict2[key]*1000)
        else:
            count2 = 0
        count_list1.append(count1)
        count_list2.append(count2)
        #Find the overlap (which equals the lower relative abundance)
        if count1 > count2:
            lowest_list.append(count2)
        else:
            lowest_list.append(count1)
    #if statement to prevent dividing by 0. Somewhat misleading, but arguably there is no distance between matrices consisting of all 0s
    if sum(count_list1) + sum(count_list2) == 0:
        BC_diss = 0
    #Calculate Bray-Curtis distance by multiplying overlap by 2, and dividing by the sum of relative abundances
    else:
        BC_diss = 1 - ((2 * sum(lowest_list)) / (sum(count_list1) + sum(count_list2)))
    return BC_diss

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
    parser.add_argument('-o', help='Path/name of output tsv file. Optional argument, and when not provided, only outputs the number of considered variables without dissimilarity calculation', required=False, dest="out")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
    
    #Parse the eggnog outputs and compile a dictionary of COG category hits, skipping entries not in the filter sample list (if given)
    sample_dict = {}
    all_COG = []
    for subdir, dirs, files in os.walk(in_dir): #iterate over all directories and subdirectories
            for file in files: #iterate over all files
                if file.endswith(".emapper.annotations") and "Metagenome_KEGGstimate" in subdir:
                    sample = file.partition(".emapper.annotations")[0]
                    if sampl_list:
                        if sample not in sampl_list:
                            continue
                    print("Reading {}".format(file))
                    sample_dict[sample], cogs = eggnog_parser_normalized(os.path.join(subdir,file))
                    for i in cogs:
                        all_COG.append(i)
    
    #Add the missing values, and convert dictionary into an ordered list
    all_COG = set(all_COG)
    print("Total variables: {}". format(len(all_COG)))
    if in_args["out"]:
        out = in_args["out"]
        print("Adding missing values")
        
        for sample in sample_dict:
            new_list = []
            for i in all_COG:
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