#!/usr/bin/env python3
"""
Makes a selection of the best non-redundant bins (based on checkm-based quality) using the checkm2 and Bin_grouper.py outputs.

Outputs a newline delimited list of non redundant bins that meet quality requirements
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

    Returns an interator that can give the lines of the input file when used in a loop.
    """
    for line in open(file_path, "r"):
        yield line
        
    
def checkm_parser(quality_report):
    """
    Reads the checkm2 quality report output, and outputs a dictionary containing the completion, contamination
    and size in bp of each bin. 
    """
    out_dict = {}
    for line in gen_line_reader(quality_report):
        if line.startswith("Name\t"):
            continue
        if len(line.split("\t")) == 14:
            bin_name = line.split("\t")[0]
            compl = float(line.split("\t")[1])
            cont = float(line.split("\t")[2])
            size = float(line.split("\t")[8])
            out_dict[bin_name] = (compl, cont, size)
    return out_dict

def grouped_bin_parser(grouped_bin_txt):
    """
    Parses the Bin_grouper.py output to find which bins are considered overlapping.
    
    Returns a list of lists. Each nested list represents a list of overlapping bins. Non-overlapping
    bins are represented as a nested list containing a single entry. 
    """
    out_list = []
    for line in gen_line_reader(grouped_bin_txt):
        line = line.strip()
        if "," in line:
            out_list.append(line.split(","))
        else:
            out_list.append([line])
    return out_list
    
def grouped_bin_picker(grouped_bin_list, checkm_dict, min_size, min_compl, max_cont, cont_weight):
    """
    Selects the best bin from among overlapping bins to return a non-redundant list. 
    """
    out_list = []
    #Iterate over each group of bins preserving only the best bin (if it meets quality demands)
    for bin_group in grouped_bin_list:
        #First remove bins that do not meet quality standards
        trimmed_list = []
        for bin_name in bin_group:
            bin_dict_name = bin_name.rpartition(".")[0] #Checkm2 does not store extensions, so remove them here
            if bin_dict_name not in checkm_dict:
                print('Skipping {}, as it was not found in the checkm2 output'.format(bin_dict_name))
                continue
            if checkm_dict[bin_dict_name][0] < float(min_compl):
                continue
            if checkm_dict[bin_dict_name][1] > float(max_cont):
                continue
            if checkm_dict[bin_dict_name][2] < 1000*float(min_size):
                continue
            trimmed_list.append((bin_name, checkm_dict[bin_dict_name][0], checkm_dict[bin_dict_name][1])) #Store the name, completion and contamination of bins of sufficient quality
        #If no bins meet quality requirements, move to the next bin group
        if len(trimmed_list) < 1: 
            continue
        #If there are bins that meet quality requirements, find the highest quality bin and add it to the output list
        highest_quality = -1
        for index, bin_tup in enumerate(trimmed_list):
            #convert percentages to fractions for simpler calculation
            compl = bin_tup[1]/100
            cont = bin_tup[2]/100
            quality = compl*(1-(cont_weight*cont))
            if quality > highest_quality:
                highest_index = index
        out_list.append(trimmed_list[highest_index][0])
    return out_list

def output_write(out_path, bin_list):
    """
    Writes the output text file, where each non-redundant bin group is a separate line
    """
    outfile = open(out_path, "w")
    for binn in bin_list:
        outfile.write(binn + "\n")
        
####################################################################
#MAIN
####################################################################    
if __name__ == "__main__":
    #Parse arguments
    parser = argparse.ArgumentParser(description='Finds which bins are suitable for downstream processing, using the checkm2 and Bin_grouper.py outputs')
    parser.add_argument('-1', help='Bin_grouper.py output file', required=True, dest="Bin_grouper_file")
    parser.add_argument('-2', help='Checkm2 "quality report" output file', required=True, dest="checkm_file")
    parser.add_argument('-o', help='Path/name of the output text file, containing all the bins suitable for downstream processing', required=True, dest="out_file")
    parser.add_argument('--min_size', help='Minimum size (in kilobases) of the bins designated for downstream processing. (default= 0)', default=0, dest="min_size")
    parser.add_argument('--min_compl', help='Minimum completion (in percentages 0-100, with decimals allowed) of the bins designated for downstream processing (default= 50)', default=50, dest="min_compl")
    parser.add_argument('--max_cont', help='Maximum contamination (in percentages 0-100, with decimals allowed) of the bins designated for downstream processing. (default= 10)', default=10, dest="max_cont")
    parser.add_argument('--cont_weight', help='How contamination is weighed when calculating quality. Quality is calculated through the formula "Completion*(1-(weight*contamination))", and the highest quality bin is selected for overlapping bins. (default= 2)', default=2, dest="cont_weight")
    in_args = vars(parser.parse_args())
    
    #Parse Bin_grouper.py output
    grouped_bins = grouped_bin_parser(in_args["Bin_grouper_file"])
    #Parse checkm2 output
    checkm = checkm_parser(in_args["checkm_file"])
    #Check quality requirements and choose highest quality bin among overlapping bins
    out_list = grouped_bin_picker(grouped_bins, checkm, in_args['min_size'], in_args['min_compl'], in_args['max_cont'], in_args['cont_weight'])
    #Write non-redunant bins of sufficient quality to the output
    output_write(in_args["out_file"], out_list)