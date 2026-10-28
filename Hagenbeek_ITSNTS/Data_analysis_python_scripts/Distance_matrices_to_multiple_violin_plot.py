#!/usr/bin/env python3
"""
Generates violin plots from the provided distance matrices. 
"""
###################
# Import statements
###################  
import sys
import os
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
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

def dist_matrix_parse(in_file):
    """
    Reads the distance matrix, generating a dictionary.
    
    Input: tab delimited text file. First line should be denoted with "#" and contain the sample names.

    Output:
    Generates a dictionary of dictionaries containing the sample pairs and their corresponding distance.
    {sample1:{sample1:0,sample2:0.4,sample3:0.5},sample2:{}etc...}
    """
    out_dict = {}
    #Every line (except the first with the sample names) represents a sample in the matrix. Enumerate and substract 1 (for the header line) to index the sample being read
    for i, line in enumerate(gen_line_reader(in_file)):
        if line.startswith("#"):
            sample_list = line.partition("#")[2].strip().split()
        elif sample_list:
            #Every column corresponds to a sample in the matrix. Enumerate to find the index of the sample corresponding to the column
            for x, item in enumerate(line.split()):
                if sample_list[i-1] not in out_dict:
                    out_dict[sample_list[i-1]] = {}
                out_dict[sample_list[i-1]][sample_list[x]] = float(item)
    return out_dict

def descriptor_parse(infile):
    """
    Parses the descriptor tsv file that lists the categories of the samples
    """
    out_dict = {}
    for line in gen_line_reader(infile):
        name = line.split("\t")[0].strip()
        descriptor = line.split("\t")[1].strip()
        out_dict[name] = descriptor
    return out_dict                  

def violinplots(data_dict_list, name_list, out, out_format, width = 20, height = 20):
    """
    Generates violin plots corresponding to the distance matrices provided as dictionaries. 
    
    Input:
    --data_dict_list: list, a list of dictionaries, in which each dictionary corresponds to a distance matrix, with the format:
    {sample1:{sample1:0,sample2:0.4,sample3:0.5},sample2:{}etc...}
    --name_list: list, list of strings corresponding to the names given to the violin plots
    --out: Path/name of the output graphic file to be generated
    --out_format: Filetype of the graphic file to be generated
    
    """
    #Convert the distance matrices into a list of distance values
    #Also remove duplicate distance values (eg sample1-sample2 = sample2-sample1)
    out_list = []
    for i, dic in enumerate(data_dict_list):
        temp_list = []
        processed_samples = []
        for sample1 in dic:
            processed_samples.append(sample1) #Makes sure duplicates values are not included, nor are the sample1-sample1 0 values. 
            for sample2 in dic:
                if sample2 in processed_samples:
                    continue
                else:
                    temp_list.append(dic[sample1][sample2])
        #Convert the list into a panda series for downstream concatentation and append to out list
        series = pd.Series(temp_list, name= name_list[i])
        out_list.append(series)

    #Create plot
    df = pd.concat(out_list, axis=1)
    #sns.stripplot(df, alpha=0.01, jitter=0.05, size = 0.5)
    #sns.boxplot(df, fill = False, width = 0.2, showfliers=False)
    #sns.violinplot(df, fill = False, inner = None)
    fig, ax = plt.subplots(figsize=(float(width), float(height)))
    sns.violinplot(df, ax=ax)
    plt.ylabel("Bray-Curtis dissimilarity")
    plt.savefig(out, format = out_format)   
    

if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads up to six distance matrices and generates a violin plot from them')
    parser.add_argument('-i', help='Path to the tsv distance matrix (or matrices). The first line, denoted by #, should contain the names of the samples. For multiple matrices, give a comma-delimited list', required=True, dest="in")
    parser.add_argument('-o', help='Path/name of output graphic file of the plot. Extension used in the name will be recognized, with the script attempting to output in the corresponding format', required=True, dest="out")
    parser.add_argument('-n', help='Name(s) given to the violin plot(s). For multiple names, give a comma-delimited list', required=False, dest="name")
    parser.add_argument('-d', help='Path to the tsv descriptor file, used to find descriptors of individual samples. Only required if --descr is used', required=False, dest="descr_file")
    parser.add_argument('--descr', help='Descriptors to be considered in the violin plots. Only samples matching the given descriptor according to the file given in -d will be considered. Can be a comma-delimited list', required=False, dest="descr")
    parser.add_argument('--width', help='Width of the output plot. Default = 20', default = 10, dest="width")
    parser.add_argument('--height', help='Height of the output plot. Default = 20', default = 5, dest="height")
    in_args = vars(parser.parse_args())
    outformat = in_args["out"].rpartition(".")[2]
    
    #For each given distance matrix, make a dictionary, and add it to a list of dictionaries
    if "," in in_args["in"]:
        inp = in_args["in"].split(",")
    else:
        inp = [in_args["in"]]
    data_dict_list = []
    for i in inp:
        data_dict_list.append(dist_matrix_parse(i))
    
    #Check if descriptors need to be considered
    if in_args["descr"]:
        if in_args["descr_file"]:
            #Find samples corresponding to the provided descriptors
            descr_dict = descriptor_parse(in_args["descr_file"])
            if "," in in_args["descr"]:
                descr = in_args["descr"].split(",")
            else:
                descr = [in_args["descr"]]
            sample_list = []
            for i in descr_dict:
                if descr_dict[i] in descr:
                    sample_list.append(i)
            #Remove samples not corresponding to descriptors from the dictionary
            for i,matrix in enumerate(data_dict_list):
                temp_dict = {}
                for sample1 in matrix:
                    if sample1 in sample_list:
                        temp_dict[sample1] = {}
                        for sample2 in matrix:
                            if sample2 in sample_list:
                                temp_dict[sample1][sample2] = matrix[sample1][sample2]
                data_dict_list[i] = temp_dict
        else:
            print("Error, --descr was given, but no descriptor file was provided. Use -d to provide a file.")
            
    #Make list of names
    if in_args["name"]:
        if "," in in_args["name"]:
            name_list = in_args["name"].split(",")
        else:
            name_list = [in_args["name"]]
    else:
        name_list = []
        for i in range(len(inp)):
            name_list.append("plt" + str(i+1))
    #Generate violinplots    
    violinplots(data_dict_list, name_list,in_args["out"], outformat, in_args["width"], in_args["height"])
    