#!/usr/bin/env python3
"""

"""
###################
# Import statements
###################  

import sys
import os
import argparse
import collections
import pandas as pd

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

def keggstimate_completion_parser(keggstimate_path, mod_list):
    """
    Parses an KEGG_completion.tsv output file. Returns a list of completion values
    
    If mod_list is not False, only includes modules in the list
    """
    out_dict = {}
    for line in gen_line_reader(keggstimate_path):
        if line.startswith("#"):
            continue
        else:
            if mod_list:
                if line.split("\t")[0] not in mod_list:
                    continue
            out_dict[line.split("\t")[0] + "_" +line.split("\t")[1]] = float(line.split("\t")[2])   
    return out_dict

def heatmap(dataframe, outname, height, width, color, outformat, cluster_samples, cluster_modules):
    import numpy as np
    import matplotlib.pyplot as plt
    import seaborn as sns
    import scipy
    
    df = dataframe
    ax = sns.clustermap(df, metric="euclidean", method="single", cmap= color, figsize=(float(width), float(height)), linewidths=0.5, linecolor='white', col_cluster = cluster_samples, row_cluster = cluster_modules)
    ax.fig.subplots_adjust(left=0.1)
    ax.fig.subplots_adjust(bottom=0.25)
    ax.ax_cbar.set_position((0.02, 0.6, 0.03, 0.2))
    plt.savefig(outname, format = outformat)     
    
def KEGG_module_cat_parser(KEGG_cat_file_path):
    """
    """
    out_dict = {}
    for line in gen_line_reader(KEGG_cat_file_path):
        if len(line) - len(line.lstrip()) == 1: #check number of leading spaces
            upper_cat = line.strip()
            if upper_cat not in out_dict:
                out_dict[upper_cat] = {}
        if len(line) - len(line.lstrip()) == 2: #check number of leading spaces
            lower_cat = line.strip()
            out_dict[upper_cat][lower_cat] = []
        if len(line) - len(line.lstrip()) == 3: #check number of leading spaces
            module_code = line.strip().split("\t")[0]
            module_name = line.strip().split("\t")[1]
            out_dict[upper_cat][lower_cat].append(module_code + "_" + module_name)
    return out_dict

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
    
if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads all the KEGG_completion.tsv keggstimate outputs in a given directory, calculates the Bray-Curtis distances between samples, and outputs them as a matrix in a .tsv file')
    parser.add_argument('-i', help='Path to input directory', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of output tsv file', required=True, dest="out")
    parser.add_argument('-m', help='Minimum completion. If at least one MAG has the minimum completion, the module is included. Default = 0.5', default = 0.5, dest="min")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    parser.add_argument('-k', help='Path/name KEGG module categories used for grouping the modules. Can be copied into a text file from https://www.genome.jp/kegg/module.html', required=False, dest="k")
    parser.add_argument('-mt', help='Module threshold, modules with completion values above this percentage will be considered complete', default = 80, dest="mt")
    in_args = vars(parser.parse_args())
    in_dir = in_args["in_dir"]
    out = in_args["out"]
    outformat = out.rpartition(".")[2]
    #Initialize filter lists if given
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
    
    KEGG_cat_dict = KEGG_module_cat_parser(in_args["k"])
    sample_dict = {}
    #Parse the eggnog outputs and compile a dictionary of K-term hits
    for subdir, dirs, files in os.walk(in_dir): #iterate over all directories and subdirectories
            for file in files: #iterate over all files
                if file.endswith("KEGG_completion.tsv") and "Best_bins_KEGGstimate" in subdir:
                    sample = subdir.rpartition("/")[0].rpartition("/")[2]
                    if sampl_list:
                        #Remove samples not in the filter list
                        if sample not in sampl_list:
                            continue
                    if sample not in sample_dict:
                        sample_dict[sample] = {}
                    MAG = file.partition(".emapper.annotations")[0]
                    sample_dict[sample][MAG] = keggstimate_completion_parser(os.path.join(subdir,file), False)
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
    

    
    #Find relative abundances of (nearly) complete modules 
    module_RA = {}
    for sample in RA_dict:
        if sample not in module_RA:
            module_RA[sample] = {}
        for MAG in RA_dict[sample]:
            if MAG == "unmapped":
                continue
            RA = RA_dict[sample][MAG]
            MAG = MAG + ".fa" #One instance of .fa is removed by coverm
            for module in sample_dict[sample][MAG]:   
                if module not in module_RA[sample]:
                    module_RA[sample][module] = 0
                #If a genome contains the module above the specified completion, add its relative abundance to the 
                #total relative abundance.
                if sample_dict[sample][MAG][module]*100 >= in_args["mt"]:
                    module_RA[sample][module] += RA
    
    #Remove modules below 5% read coverage in any sample
    retained_dict = {}
    retain_list = []
    for sample in module_RA:
        retained_dict[sample] = {}
        for module in module_RA[sample]:
            if module_RA[sample][module] >= 5:
                retain_list.append(module)
    retain_list = set(retain_list)            
    
    renamed_dict = {}
    for sample in sample_dict:
        renamed_dict[sample] = {}
        for MAG in sample_dict[sample]:
            renamed_dict[sample][MAG] = {}
            for module in sample_dict[sample][MAG]:
                if module in retain_list:
                    #Rename module based on group, so sorting by alphabet also sorts by category
                    for cat1 in KEGG_cat_dict:
                        for cat2 in KEGG_cat_dict[cat1]:
                            if module in KEGG_cat_dict[cat1][cat2]:
                                module_rename = "{}_{}_{}".format(cat1,cat2,module)           
                    renamed_dict[sample][MAG][module_rename] = sample_dict[sample][MAG][module]
                    
    
    ordered_dict = {}
    for sample in renamed_dict:
        ordered_dict[sample] = {}
        for MAG in renamed_dict[sample]:
            ordered_dict[sample][sample + "_" + MAG] = collections.OrderedDict(sorted(renamed_dict[sample][MAG].items()))
        ordered_dict[sample] = collections.OrderedDict(sorted(ordered_dict[sample].items()))
    
    for MAG in ordered_dict[sample]:
        for module in ordered_dict[sample][MAG]:
            print(module)
        break
    #for sample in ordered_dict:
        #df = pd.DataFrame(ordered_dict[sample])
        #heatmap(df, out.strip("." + outformat) + sample + "." + outformat, 50, 50, "magma", outformat, False, False)        
            
    
    