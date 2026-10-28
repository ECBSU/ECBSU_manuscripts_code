#!/usr/bin/env python3
"""

"""
###################
# Import statements
###################  

import sys
import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors
import seaborn as sns
import pandas as pd
import scipy
import argparse
from scipy.spatial.distance import pdist, squareform
from skbio.stats.ordination import pcoa
from skbio import DistanceMatrix
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
                

def PCoA(data_dict, n, descr_dict, out, out_format, width=10, height=10, axxrange=False,axyrange=False):
    """
    Generates a PCoA plot based on the distance matrix provided in the input dictionary
    """
    from scipy.spatial import distance_matrix
    from sklearn.manifold import MDS
    from matplotlib.colors import LinearSegmentedColormap
    
    
    
    df = pd.DataFrame(data_dict)
    mds = MDS(n_components=n, dissimilarity='precomputed')
    coordinates = mds.fit_transform(df)
    
    descr_list = []
    color_list = []
    for i in df.columns:
        if i in descr_dict:
            descr_list.append(descr_dict[i])
        else:
            descr_list.append("unknown")
    unique_descr = sorted(set(descr_list))
    for x in descr_list:
        for i, cat in enumerate(unique_descr):
            if x == cat:
                color_list.append(i)
    custom_colors = ["#D4A26A","#103E50","#6E0E3D","#552C00","#527A0F","#6D92A0","#457385","#804D15","#000101","#554932","#022735","#FFD6AA"] #Taxon-based coloring
    #custom_colors = ["#D4A26A","#103E50","#6E0E3D","#527A0F","#6D92A0","#804D15","#554932","#022735"] #Taxon-based coloring for genome resolved function PCoA
    #custom_colors = ["#D4A26A","#103E50","#6E0E3D","#527A0F","#804D15","#022735"] #Taxon-based coloring for genome resolved taxonomy PCoA
    #custom_colors = ["#AA3939","#4B757F","#AA3939","#AA3939","#4B757F","#4B757F","#4B757F","#AA3939","#01323E","#01323E","#4B757F","#AA3939"] #Vertebrate/Invert-based coloring
    #custom_colors = ["#AA7239","#4B757F","#4B757F","#AA7239","#AA7239","#4B757F","#4B757F","#AA7239","#01323E","#01323E","#4B757F","#AA7239"] #Habitat-based coloring
    #custom_colors = ["#FFD1AA","#FFAAAA","#D49A6A","#552700","#D46A6A","#2D882D","#550000","#804515","#407F7F","#0D4D4D","#AA3939","#AA6C39"] #Taxon-based coloring
    custom_cmap = LinearSegmentedColormap.from_list("my_gradient", custom_colors)
    
    plt.figure(figsize=(width, height))
    fig = plt.scatter(coordinates[:, 0], coordinates[:, 1],c = color_list, cmap = custom_cmap)
    if axxrange:
        plt.xlim(float(axxrange[0]), float(axxrange[1]))
    if axyrange:
        plt.ylim(float(axyrange[0]), float(axyrange[1]))
    plt.title('PCoA Visualization')
    plt.xlabel('PCo1')
    plt.ylabel('PCo2')
    labels = np.unique(color_list)
    handles = [plt.Line2D([],[],marker="o", ls="", color=fig.cmap(fig.norm(yi))) for yi in labels]
    plt.legend(handles, unique_descr)
    plt.savefig(out, format = out_format)    
    
if __name__ == "__main__":
    #Parse arguments        
    parser = argparse.ArgumentParser(description='Reads a distance matrix and generates a PCoA plot from it')
    parser.add_argument('-i', help='Path to a tsv distance matrix. The first line, denoted by #, should contain the names of the samples', required=True, dest="in")
    parser.add_argument('-o', help='Path/name of output graphic file of the plot. Extension used in the name will be recognized, with the script attempting to output in the corresponding format', required=True, dest="out")
    parser.add_argument('-d', help='Path/name of descriptor text file. This is a tab-delimited text file with samplenames in the first column, and their category in the second. Used to color the samples in the PCoA', required=False, dest="descr")
    parser.add_argument('--height', help='Height of the output plot. (Default = 10)', default = 10, dest="h")
    parser.add_argument('--width', help='Width of the output plot. (Default = 10)', default = 10, dest="w")
    parser.add_argument('--x_range', help='Range of the x-axis, given as "minimum,maximum", e.g. -5,25 (use a = if it includes a minus sign). By default allows pyplot to set its own range', default = False, dest="xrange")
    parser.add_argument('--y_range', help='Range of the y-axis, given as "minimum,maximum", e.g. -5,25 (use a = if it includes a minus sign). By default allows pyplot to set its own range', default = False, dest="yrange")
    in_args = vars(parser.parse_args())
    outformat = in_args["out"].rpartition(".")[2]
    if in_args["xrange"]:
        xrange = in_args["xrange"].split(",")
    else:
        xrange = False
    if in_args["yrange"]:
        yrange = in_args["yrange"].split(",")
    else:
        yrange = False
    descr_dict = descriptor_parse(in_args["descr"])
    dist_dict = dist_matrix_parse(in_args["in"])
    
    
    PCoA(dist_dict,2,descr_dict,in_args["out"], outformat, in_args["h"], in_args["w"], xrange, yrange)
    