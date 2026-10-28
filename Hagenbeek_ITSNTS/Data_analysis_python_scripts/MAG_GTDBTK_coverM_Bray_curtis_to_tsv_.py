#!/usr/bin/env python3
"""
Parses taxonomic assignments of MAGs from the GTDB-Tk output, sums and normalizes taxa abundances of MAGs to get a per sample profile, 
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

def GTDBTK_parser(GTDBTK_bac_path, GTDBTK_arc_path):
    """
    """
    out_dict = {}
    for line in gen_line_reader(GTDBTK_bac_path):
        if line.startswith("user_genome	classification	closest_genome_reference"):
            continue
        splt = line.split("\t")
        if splt[0].startswith("ERR") or splt[0].startswith("SRR"):
            sample = splt[0].partition("_")[0]
            MAG = splt[0].partition("_")[2]
        else:
            sample_splt = splt[0].split("_")
            sample = "_".join(sample_splt[:3])
            MAG = "_".join(sample_splt[3:])
        if ";" not in splt[1]: #This skips unclassified bins
            continue
        taxonomy = splt[1].split(";")
        p = taxonomy[1]
        c = taxonomy[2]
        o = taxonomy[3]
        f = taxonomy[4]
        g = taxonomy[5]
        s = taxonomy[6]
        if sample not in out_dict:
            out_dict[sample] = {}
        out_dict[sample][MAG] = [p,c,o,f,g,s]
        
    for line in gen_line_reader(GTDBTK_arc_path):
        if line.startswith("user_genome	classification	closest_genome_reference"):
            continue
        splt = line.split("\t")
        if splt[0].startswith("ERR") or splt[0].startswith("SRR"):
            sample = splt[0].partition("_")[0]
            MAG = splt[0].partition("_")[2]
        else:
            sample_splt = splt[0].split("_")
            sample = "_".join(sample_splt[:3])
            MAG = "_".join(sample_splt[3:])
        if ";" not in splt[1]: #This skips unclassified bins
            continue
        taxonomy = splt[1].split(";")
        p = taxonomy[1]
        c = taxonomy[2]
        o = taxonomy[3]
        f = taxonomy[4]
        g = taxonomy[5]
        s = taxonomy[6]
        if sample not in out_dict:
            out_dict[sample] = {}
        out_dict[sample][MAG] = [p,c,o,f,g,s]
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

def gap_filler(in_dict):
    """
    """
    #Find all taxonomies
    tax_list = []
    for sample in in_dict:
        for tax in in_dict[sample]:
            tax_list.append(tax)
    tax_set = set(tax_list) #Convert to set to only retain unique taxa
    tax_list = list(tax_set) #Convert back to list to guarentee there is no accidental changes to order
    #Convert in_dict from a nested dictionary into a dictionary of ordered lists containing all found taxonomies
    out_dict = {}
    for sample in in_dict:
        out_list = []
        for tax in tax_list:
            if tax not in in_dict[sample]:
                out_list.append(0)
            else:
                out_list.append(in_dict[sample][tax])
        out_dict[sample] = out_list
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
    parser.add_argument('-i_bac', help='Path to GTDB-TK bacterial output containing the taxonomic assignments of all bins', required=True, dest="in_bac")
    parser.add_argument('-i_arc', help='Path to GTDB-TK archeal output containing the taxonomic assignments of all bins', required=True, dest="in_arc")
    parser.add_argument('-i', help='Directory to search for coverm outputs', required=True, dest="in_dir")
    parser.add_argument('-o', help='Path/name for the prefix of the output tsv file. Will add "_*taxonomy level*.tsv" behind the prefix', required=False, dest="out")
    parser.add_argument('-f', help='Path/name of newline-delimited text file containing the names of samples to be considered. If provided, any sample not within the list will be omitted', required=False, dest="filter")
    in_args = vars(parser.parse_args())
    if in_args["filter"]:
        sampl_list = filter_parse(in_args["filter"])
    else:
        sampl_list = False
    out = in_args["out"]
        
        
    #Find MAG taxonomies
    print("Reading MAG taxonomies")
    taxonomy_dict = GTDBTK_parser(in_args["in_bac"], in_args["in_arc"])
    
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
    
    #Find taxonomy abundances per sample
    print("Calculating taxonomy abundances")
    p_dict = {}
    c_dict = {}
    o_dict = {}
    f_dict = {}
    g_dict = {}
    s_dict = {}
    #Iterate over all samples
    for sample in RA_dict:
        if sample not in taxonomy_dict:
            print("No MAG taxonomies found for {}".format(sample))
            continue
        p_dict[sample] = {}
        c_dict[sample] = {}
        o_dict[sample] = {}
        f_dict[sample] = {}
        g_dict[sample] = {}
        s_dict[sample] = {}
        #Iterate over all MAGs
        for MAG in RA_dict[sample]:
            if MAG not in taxonomy_dict[sample]: #Skip "unmapped" and any MAGs that were omitted due to being unclassified
                print(MAG)
                print(taxonomy_dict[sample])
                continue
            #Acquire the taxonomy names for each taxonomic level
            p = taxonomy_dict[sample][MAG][0]
            c = taxonomy_dict[sample][MAG][1]
            o = taxonomy_dict[sample][MAG][2]
            f = taxonomy_dict[sample][MAG][3]
            g = taxonomy_dict[sample][MAG][4]
            s = taxonomy_dict[sample][MAG][5]
            #Check if the names are in the output dictionaries, if not, add them with the corresponding relative abundance. If present, sum the relative abundance
            if not p.endswith("_"): # If a name ends with "_" it has no classificiation
                if p not in p_dict[sample]:
                    p_dict[sample][p] = RA_dict[sample][MAG]
                else:
                    p_dict[sample][p] += RA_dict[sample][MAG]
            if not c.endswith("_"): # If a name ends with "_" it has no classificiation
                if c not in c_dict[sample]:
                    c_dict[sample][c] = RA_dict[sample][MAG]
                else:
                    c_dict[sample][c] += RA_dict[sample][MAG]
            if not o.endswith("_"): # If a name ends with "_" it has no classificiation
                if o not in o_dict[sample]:
                    o_dict[sample][o] = RA_dict[sample][MAG]
                else:
                    o_dict[sample][o] += RA_dict[sample][MAG]
            if not f.endswith("_"): # If a name ends with "_" it has no classificiation
                if f not in f_dict[sample]:
                    f_dict[sample][f] = RA_dict[sample][MAG]
                else:
                    f_dict[sample][f] += RA_dict[sample][MAG]
            if not g.endswith("_"): # If a name ends with "_" it has no classificiation
                if g not in g_dict[sample]:
                    g_dict[sample][g] = RA_dict[sample][MAG]
                else:
                    g_dict[sample][g] += RA_dict[sample][MAG]
            if not s.endswith("_"): # If a name ends with "_" it has no classificiation
                if s not in s_dict[sample]:
                    s_dict[sample][s] = RA_dict[sample][MAG]
                else:
                    s_dict[sample][s] += RA_dict[sample][MAG]
    
    #Add all found taxonomies to each dictionary, and convert the dictionaries of dictionaries to dictionaries of ordered lists.
    p_dict = gap_filler(p_dict)
    c_dict = gap_filler(c_dict)
    o_dict = gap_filler(o_dict)
    f_dict = gap_filler(f_dict)
    g_dict = gap_filler(g_dict)
    s_dict = gap_filler(s_dict)
    
    #Calculate Bray-Curtis dissimilarities       
    print("Calculating dissimilarities")
    dissim_dict = {}
    for sample1 in p_dict:
        dissim_dict[sample1] = {}
        for sample2 in p_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(p_dict[sample1],p_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_phylum.tsv", dissim_dict)
    
    dissim_dict = {}
    for sample1 in c_dict:
        dissim_dict[sample1] = {}
        for sample2 in c_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(c_dict[sample1],c_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_class.tsv", dissim_dict)
    
    dissim_dict = {}
    for sample1 in o_dict:
        dissim_dict[sample1] = {}
        for sample2 in o_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(o_dict[sample1],o_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_order.tsv", dissim_dict)
    
    dissim_dict = {}
    for sample1 in f_dict:
        dissim_dict[sample1] = {}
        for sample2 in f_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(f_dict[sample1],f_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_family.tsv", dissim_dict)
    
    dissim_dict = {}
    for sample1 in g_dict:
        dissim_dict[sample1] = {}
        for sample2 in g_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(g_dict[sample1],g_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_genus.tsv", dissim_dict)
    
    dissim_dict = {}
    for sample1 in s_dict:
        dissim_dict[sample1] = {}
        for sample2 in s_dict:
            dissim_dict[sample1][sample2] = distance.braycurtis(s_dict[sample1],s_dict[sample2])
    #Output dissimilarities to a tsv file
    output_tsv(out + "_species.tsv", dissim_dict)