#!/usr/bin/env python3
"""
Reads over all bins in the provided folder, and groups them based on overlap (in fraction of basepairs). Outputs a .txt
file where each line represents a group of overlapping bins, given as a comma-delimited list.

IMPORTANT:
As this script utilizes the contig names to define overlap, it only works for bins generated from the same assembly. 
"""

###################
#Import statement
###################  
import sys
import os
import argparse

###################
#Functions
###################  
def gen_line_reader(file_path):
    """
    Simple generator function for reading text files. Prevents excessive memory usage when reading big files.

    Returns an iterator that can give the lines of the input file when used in a loop.
    """
    for line in open(file_path, "r"):
        yield line
        
    
def bin_parser(bin_path, contig_lengths):
    """
    Parses a fasta file, returning a list of contig names/headers found. 
    
    To simultaneously store the lengths of contigs, a dictionary is also used. If a contig header is not yet present
    in the dictionary, saves the header and the corresponding contig length.
    """
    out_list = []
    #Iterate over each line, taking headers and appending them to the output list.
    #Additionally counts the lengths of the non-header lines, and adds them to the length dictionary,
    #BUT only if the contig is not yet present. If present, it skips reading the non-header lines. 
    read = False
    for line in gen_line_reader(bin_path):
        if line.startswith(">"):
            if read:
                contig_lengths[contig] = count
                read = False
            contig = line.partition(">")[2].strip()
            out_list.append(contig)
            if contig not in contig_lengths:
                read = True
                count = 0
        elif read:
            count+= len(line.strip())
    if read:
        contig_lengths[contig] = count        
    return out_list, contig_lengths

def bin_contig_grabber(input_dir, bin_extension, contig_lengths):
    """
    Iterates over all the fasta files in the input_dir, reading the contig headers and listing them in a dictionary.
    The keys of the dictionary are the bin/fasta names, and the values are lists of contig headers.
    
    Additionally fills the dictionary of contig lengths so contig similarity can be normalized by contig lengths downstream
    """
    out_dict = {}
    #Iterate over each file in the given directory, only considering the file with appropriate extensions.
    #Add the files, and their corresponding headers to a dictionary
    for root, dirs, files in os.walk(input_dir): 
        for file in files: 
            if file.endswith(bin_extension):
                out_dict[file],contig_lengths = bin_parser(os.path.join(root, file), contig_lengths)
    return out_dict

def overlap_calc(list1, list2, contig_lengths):
    """
    Takes two lists (of contig headers), and calculates the overlap between the two lists. To make biological sense, this overlap
    is normalized based on the lengths (in basepairs) of the corresponding contigs. 
    
    Returns the (normalized) overlap as a fraction (0-1)
    """
    #First determine sizes of the bins (weigh contigs based on their size in bp)
    size1 = 0
    for contig in list1:
        size1 += contig_lengths[contig]
    size2 = 0
    for contig in list2:
        size2 += contig_lengths[contig]
    #Determine size of overlap
    intersection_size = 0
    intersection = set(list1) & set(list2)
    for contig in intersection:
        intersection_size += contig_lengths[contig]
    #Consider overlap based on the smallest bin
    if size1 < size2:
        overlap = intersection_size/size1
    else:
        overlap = intersection_size/size2
    return overlap
    
def bin_grouper(in_dict, min_overlap, contig_lengths):
    """
    Takes a dictionary of bin names (with their corresponding contigs in a list as the key) and groups these bins based on the 
    specified fraction of overlap in contigs. The contig overlap calculation is based on the lengths of the contigs, taken from the contig_lengths 
    dictionary. 
    
    If a bin has sufficient overlap with multiple groups, it is placed in the group with the highest fraction of overlap. 
    
    Returns a list of lists, where each sub_list is a list of bins that had sufficient overlap.
    """
    out_list = []
    for ungrouped_bin in in_dict:
        no_overlap = True
        for sub_list in out_list:
            best_overlap = 0
            for grouped_bin in sub_list:
                overlap = 100 * overlap_calc(in_dict[ungrouped_bin], in_dict[grouped_bin], contig_lengths)
                if best_overlap < overlap:
                    best_overlap = overlap
            if float(best_overlap) >= float(min_overlap):
                out_list[out_list.index(sub_list)].append(ungrouped_bin)
                no_overlap = False
        if no_overlap:
            out_list.append([ungrouped_bin])
    return out_list
        
def output_write(out_path, group_list):
    """
    Writes the output text file, where each bin group is a separate, comma-delimited, line
    """
    outfile = open(out_path, "w")
    for group in group_list:
        for i, item in enumerate(group):
            outfile.write(item)
            if i < len(group) - 1:
                outfile.write(",")
        outfile.write("\n")
        
####################################################################
#MAIN
####################################################################    
if __name__ == "__main__":
    #Argument parser
    parser = argparse.ArgumentParser(description='Reads all bins in the provided directory, and groups them based on sequence overlap. Sequence overlap is calculated based on identical contig names and thus ONLY WORKS IF THE BINS WERE GENERATED FROM THE SAME ASSEMBLY')
    parser.add_argument('-i', help='Path to input directory containing the bin fasta files to be processed', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name of the output text file', required=True, dest="out_file")
    parser.add_argument('-x', help='Extension of the fasta files to be processed. (default=.fa)', default=".fa", dest="extension")
    parser.add_argument('-m', help='Percentage of sequences that need to be identical to be considered overlapping bins. The overlap is calculated based on the smaller bin. (default=50)', default=50, dest="min_overlap")
    in_args = vars(parser.parse_args())
    
    #Initialize a persistent dictionary for storing the lengths of each found contig
    contig_lengths = {}
    #Read each bin, creating a dictionary containing each bin, and a list of their contained contigs. 
    #Simultaneously, find the lengths of each contig so contig overlap can be normalized based on contig lengths.
    contig_dict = bin_contig_grabber(in_args['in_dir'], in_args['extension'], contig_lengths)
    #Find overlap in bins, and group them based on the minimum specified overlap. 
    list_of_groups = bin_grouper(contig_dict, in_args['min_overlap'], contig_lengths)
    #Write the output file. Each group will be a separate line, each line will be a comma-delimited list of the overlapping bins. 
    output_write(in_args['out_file'], list_of_groups)