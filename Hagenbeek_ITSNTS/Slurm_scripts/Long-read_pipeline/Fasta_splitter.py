#!/usr/bin/env python3
"""
Splits a fasta file into the specified number of files (based on file number or approximate file size)
"""
###################
# Import statements
###################  
import sys
import os
import argparse
import shutil

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

def number_based_splitter(in_file, out_prefix, number):
    """
    """
    #Find number of contigs to split across each file. In case of fractions, round up.  
    contig_count = 0
    for line in gen_line_reader(in_file):
        if line.startswith(">"):
            contig_count += 1
    #Python by default rounds down (for example in the "//" used below). By dividing a negative number, and then turning it positive, rounding down can be turned into rounding up. 
    #For example, -6 / 5 = -1.2. Which "rounded" down will be -2. Which multiplied by -1 will be 2. 
    Rounded_contig_per_file = -(-contig_count // number) 
    
    #Open the desired number of files, and populate them with the desired number of contigs
    file_index = 0
    contig_copied = float("inf")
    #Iterate over each contig, copying them to the output file. If the desired number of contigs is copied, close the output file and open the next one 
    for line in gen_line_reader(in_file):
        if line.startswith(">"):
            if contig_copied > Rounded_contig_per_file:
                contig_copied = 0
                file_index += 1
                out = open("{}{}.fasta".format(out_prefix,file_index), "w")
            contig_copied += 1
        out.write(line)
        
def size_based_splitter(in_file, out_prefix, kbsize):
    """
    """
    file_index = 0
    bp = float("inf")
    #Iterate over each contig, copying them to the output file. If the desired number of contigs is copied, close the output file and open the next one 
    for line in gen_line_reader(in_file):
        if line.startswith(">"):
            if bp / 1000 > kbsize:
                bp = 0
                file_index += 1
                out = open("{}{}.fasta".format(out_prefix,file_index), "w")
            out.write(line)
        else:
            bp += len(line.strip())
            out.write(line)

if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Splits a fasta file into the specified number of files')
    parser.add_argument('-i', help='Path/name of the input fasta file', required=True, dest="in")
    parser.add_argument('-o', help='Prefix of the output fasta files', required=True, dest="out")
    parser.add_argument('-n', help='Desired number of output files. Script will attempt to equally split contigs across the specified number of files', required=False, dest="number")
    parser.add_argument('-s', help='Desired file size of output files in kiloBASES. Script will attempt to equally split contigs across the files of this approximate size (subject to contig size)', required=False, dest="size")
    in_args = vars(parser.parse_args())
    #Raise error if incorrect split criteria are given
    if not in_args["number"] and not in_args["size"]:
        print("Error, require either -n or -s needs to be specified.")
        exit
    if  in_args["number"] and  in_args["size"]:
        print("Error, cannot specify both -n and -s.")
        exit
    
    #If a number of output files is specified, first find the number of contigs
    if in_args["number"]:
        number_based_splitter(in_args["in"], in_args["out"], int(in_args["number"]))
    
    #If a size in kb is specified, simply copy over contigs until the desired kb range is reached, then close the output and open the next one
    if in_args["size"]:
        size_based_splitter(in_args["in"], in_args["out"], int(in_args["size"]))
        
        