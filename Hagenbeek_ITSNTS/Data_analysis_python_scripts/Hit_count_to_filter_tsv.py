#!/usr/bin/env python3
"""
Reads a tab-delimited text file for hit counts sizes, and filters for the desired minimum counts, 
outputting  matching samples as a newline-delimited text file.
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

def count_parser(file_path):
    """
    Parsing function that reads the tsv file, outputing a dictionary with sample names (column 1)
    as keys and metagenome size (column 2) as values
    """
    out_dict = {}
    for line in gen_line_reader(file_path):
        out_dict[line.split()[0]] = float(line.split()[1].strip())
    return out_dict

if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads a tab-delimited text file for metagenome sizes (sample_name\tmetagenome_size\n), and filters for desired minimum size, outputting samples matching the minimum size as a newline-delimited text file.')
    parser.add_argument('-i', help='Path/name of the count input file', required=True, dest="in")
    parser.add_argument('-o', help='Path/name of the output text file', required=True, dest="out")
    parser.add_argument('-m', help='Minimum count number to filter for', required=True, dest="min")
    in_args = vars(parser.parse_args())
    
    #Parse count values and make a count dictionary
    count_dict = count_parser(in_args["in"])
    
    #Output count dictionary in a newline delimited text file.
    with open(in_args["out"], "w") as out:
        for sample in count_dict:
            if count_dict[sample] >= float(in_args["min"]) * 1000:
                out.write(sample + "\n")
        
            
    