#!/usr/bin/env python3
"""
Parses per mag PFAM counts from eggNOG-mapper outputs, normalizes PFAM counts based on origin MAG read counts, 
and then calculates Bray-Curtis dissimilarities across samples
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

def eggnog_parser(eggnog_path):
    """
    Parses an eggnog.annotations output file. Returns a dictionary of PFAMs with their corresponding hit counts
    """
    out_dict = {}
    pfams = []
    for line in gen_line_reader(eggnog_path):
        if line.startswith("#"):
            continue
        PFAM = line.split("\t")[20]
        if PFAM == "-":
            continue
        if "," in PFAM:
            PFAM = PFAM.split(",")
        else:
            PFAM = [PFAM]
        for i in PFAM:
            pfams.append(i)
            if i in out_dict:
                out_dict[i] += 1
            else:
                out_dict[i] = 1
    return out_dict, set(pfams)

def coverm_parser(file_path):
    """
    Reads a coverM output file and outputs a dictionary of MAGs as keys and their relative abundances as values
    """
    out_dict = {}
    for line in gen_line_reader(file_path):
        if line.strip():
            if line.startswith("Genome	"):
                continue
            MAG = line.split()[0].strip()
            RA = float(line.split()[1].strip())
            out_dict[MAG] = RA
    return out_dict

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

    #Parse the eggnog outputs and compile a dictionary of ec code hits, skipping entries not in the filter sample list (if given)
    sample_dict = {}
    all_pfams = []
    for subdir, dirs, files in os.walk(in_dir): #iterate over all directories and subdirectories
            for file in files: #iterate over all files
                if file.endswith(".emapper.annotations") and "Best_bins_KEGGstimate" in subdir:
                    sample = subdir.rpartition("/")[0].rpartition("/")[2]
                    if sampl_list:
                        if sample not in sampl_list:
                            continue
                    if sample not in sample_dict:
                        sample_dict[sample] = {}
                    MAG = file.partition(".emapper.annotations")[0]
                    if MAG == "total":
                        continue
                    print("Reading {}".format(file))
                    sample_dict[sample][MAG], PFAMs = eggnog_parser(os.path.join(subdir,file))
                    for i in PFAMs:
                        all_pfams.append(i)
                        
    #Add the missing values, and convert dictionary into an ordered list
    all_pfams = set(all_pfams)
    print("Total variables: {}". format(len(all_pfams)))
    if in_args["out"]:
        out = in_args["out"]
        print("Adding missing values")
        
        for sample in sample_dict:
            for MAG in sample_dict[sample]:
                new_list = []
                for i in all_pfams:
                    if i not in sample_dict[sample][MAG]:
                        new_list.append(0)
                    else:
                        new_list.append(sample_dict[sample][MAG][i])
                sample_dict[sample][MAG] = new_list                
        #Find MAG abundances
        print("Reading MAG abundances")
        RA_dict = {}
        #Iterate over all directories and subdirectories in the given directory
        for subdir, dirs, files in os.walk(in_args["in_dir"]): 
                #Iterate over all contained files, only considering the coverm output
                for file in files: 
                    if file =="Best_bins_coverm_output":
                        sample = subdir.rpartition("/")[2]
                        if sample not in sampl_list:
                            continue
                        RA_dict[sample] = coverm_parser(os.path.join(subdir,file))
                        
        #Group all MAG counts per sample, and normalize by the MAG's relative abundance
        print("Grouping MAGs per sample, and normalizing by MAG abundances")
        total_KEGG_COG_abundance = {}
        for sample in RA_dict:
            for MAG in RA_dict[sample]:
                if MAG == "unmapped":
                    continue
                RA = RA_dict[sample][MAG]
                MAG = MAG + ".fa" #One instance of .fa is removed by coverm
                if sample not in total_KEGG_COG_abundance:
                    total_KEGG_COG_abundance[sample] = [RA * i for i in sample_dict[sample][MAG]] #Multiply the ortholog count by the relative of the contained MAG
                else:
                    RA_multiplied_list = [RA * i for i in sample_dict[sample][MAG]]
                    old_list = total_KEGG_COG_abundance[sample][:]
                    #If there is already another MAG logged in the list, sum their relative abundance orth counts
                    total_KEGG_COG_abundance[sample] = [x + y for x, y in zip(RA_multiplied_list,old_list)]
        
        
        #Calculate Bray-Curtis dissimilarities       
        print("Calculating dissimilarities")
        dissim_dict = {}
        for sample1 in total_KEGG_COG_abundance:
            print(sample1)
            dissim_dict[sample1] = {}
            for sample2 in total_KEGG_COG_abundance:
                dissim_dict[sample1][sample2] = distance.braycurtis(total_KEGG_COG_abundance[sample1],total_KEGG_COG_abundance[sample2])
        #Output dissimilarities to a tsv file
        output_tsv(out, dissim_dict)