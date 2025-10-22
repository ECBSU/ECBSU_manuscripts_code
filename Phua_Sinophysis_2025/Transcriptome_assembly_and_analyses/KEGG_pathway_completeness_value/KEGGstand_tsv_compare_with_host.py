#!/usr/bin/env python3
"""
Processes and merges all the KEGGstand output in the provided directory, and gives them as a single output file
for downstream analyses or visualization

Usage: (python) KEGGstand_tsv_maker.py --in_dir /directory/of/KEGGstand/output --output output_prefix [arguments]

Output:
Tab-delimited file where module completion is shown per sample, for each sample in the provided directory
"""

###################
#Import statements
################### 
import sys
import os

###################
# Functions
###################

def gen_line_reader(file_path):
    """
    Generator function that allows reading a text file line
    by line, without reading the full file into memory
    """
    for line in open(file_path, "r"):
        yield line


def leading_dash_counter(string):
    """
    Counts the number of leading dashes in the string. Returns
    this number as a integer
    """
    dash = 0
    for char in string:
        if char == "-":
            dash += 1
        else:
            break
    return dash


def completion_tsv_reader(filepath):
    """
    Parser function for reading the completion values in the KEGGstand pipeline output.
    Returns a dictionary where the module is the key, and its completion fraction is the value
    """
    out_dict = {}
    for line in gen_line_reader(filepath):
        if line.startswith("#"):
            continue
        # Combine the KEGG Module code and its name into a single variable
        KEGG_name = "{} {}".format(line.split("\t")[0], line.split("\t")[1])
        completion = float(line.split("\t")[2])
        out_dict[KEGG_name] = completion
    return out_dict


def BRITE_output_parser(file_path, BRITE_list, allbrite):
    """
    Parser function for reading the BRITE/pathway gene counts given in the KEGGstand pipeline output.
    Returns a dictionary where the pathway is the key, and the value is a string:
    "genes_found	otal_genes", which will be parsed in the output function
    """
    out_dict = {}
    # Check if allbrite was given (this means every category will be returned)
    # If not, only return the categories in the BRITE_list
    if not allbrite:
        # To determine which categories are subcategories of interest, keep track of the leading dashes
        cat_leading_dash = 100
        # Initiate a variable that shows that we are processing a subcategory
        in_cat = False
        for line in gen_line_reader(file_path):
            # If there are fewer or equal leading dashes as the categories of interest,
            # then we are not in a subcategory, and the line will be ignored
            if leading_dash_counter(line) <= cat_leading_dash:
                in_cat = False
            # If the line contains a category of interest, the category will be stored. Furthermore,
            # every next line, UNTIL there are fewer or equal dashes, is a subcategory, which will
            # also be processed using the in_cat variable.
            if line.split("\t")[0].strip("-").strip() in BRITE_list:
                out_dict[line.split("\t")[0]] = line.split("\t")[1].strip()
                cat_leading_dash = leading_dash_counter(line)
                in_cat = True
            if in_cat:
                out_dict[line.split("\t")[0]] = line.split("\t")[1].strip()
    # If allbrite is given, simply output every single category
    else:
        for line in gen_line_reader(file_path):
            out_dict[line.split("\t")[0]] = line.split("\t")[1]
    return out_dict

def remove_modules_below_completion(module_dict, minimum_completion, method = "avg"):
    """
    Remove any modules from the input dictionary that are below the minimum completion.
    How this is calculated depends on the specified method either considering the average (avg)
    minimum (min), or maximum (max) across samples. 
    """
    out_dict = {}
    out_modules = []
    #Check which modules need to be entered into the output dictionary
    #Use a dummy loop to enter and iterate over the "modules" dictionary first
    for dummy in module_dict:
        for module in module_dict[dummy]:
            temp_list = []
            #Iterate over each organism/fasta, adding their completion for the module in question to the temp_list
            for org in module_dict:
                #Add the organism to the out_dict
                if org not in out_dict:
                    out_dict[org] = {}
                temp_list.append(module_dict[org][module])
            #Check if the average completion (if avg) or any completion (if not avg) is higher than the minimum
            #completion
            if method == "avg":
                if sum(temp_list)/len(temp_list) >= minimum_completion:
                    out_modules.append(module)
            elif method == "min":
                if min(temp_list) >= minimum_completion:
                    out_modules.append(module)
            elif method == "max":
                if max(temp_list) >= minimum_completion:
                    out_modules.append(module)
        break
    #Make the output dictionary
    for org in out_dict:
        for module in out_modules:
            out_dict[org][module] = module_dict[org][module]
    return out_dict

def retain_only_specified_modules(module_dict, search_string_list, filter_string_list):
    """
    Outputs a new dictionary removing or retaining modules based on the strings found in the specified
    lists. Search_string_list specifies strings of modules to be retained, while filter_string_list specifies
    strings that should be removed from the module_dict
    """
    temp_dict = {}
    #Remove any modules matching string in the filter_string_list
    if len(filter_string_list) > 0:
        for org in module_dict:
            for module in module_dict[org]:
                for string in filter_string_list:
                    if string not in module:
                        if org not in temp_dict:
                            temp_dict[org] = {}
                        temp_dict[org][module] = module_dict[org][module]
    #Only use the modules with a string matching the search_string_list
    if len(search_string_list) > 0:
        out_dict = {}
        for org in temp_dict:
            for module in temp_dict[org]:
                for string in search_string_list:
                    if string in module:
                        out_dict[org][module] = module_dict[org][module]
    else:
        out_dict = temp_dict
    return out_dict

def module_output(module_dict, out_file):
    """
    Output function to write the contents of the module dictionary to a tab-delimited text file.
    """
    out = open(out_file, "w")

    # Write header line
    out.write("#Module\t")
    for org in module_dict:
        out.write(org + "\t")
    out.write("\n")
    # Write per module completions for modules
    # First iterate over the modules by grabbing the first organism, and iterating over the keys
    # of its nested dictionary, after which the loop is broken
    for x in module_dict:
        for module in module_dict[x]:
            out.write(module + "\t")
            for org in module_dict:
                out.write(str(module_dict[org][module])+ "\t")
            out.write("\n")
        break

def category_collapser(module_dict, module_db_path, level, method, show_module_count):
    """
    'Collapses' the modules into their overarching categories. Requires the module database. Level 
    specifies the level of category, 1 being the broadest, and 2 being the more specific categories. 
    Method species the way to consolidate the modules into a category. The value can be the average (avg), 
    the lowest value (min), or the highest value (max). Show module count specifies that the new categories should
    list the number of modules they represent. 
    """
    out_dict = {}
    #Iterate over the module database, finding which modules belong to which categories.
    #Make a list for each category, listing the completions of included modules
    for line in gen_line_reader(module_db_path):
        if line.startswith("Module: "):
            name = line.strip("Module:").strip()
        if line.startswith("Class: "):
            clss = line.partition(";")[2].split(";")
            clss = clss[level-1].strip()
            for org in module_dict:
                if name in module_dict[org]:
                    if org not in out_dict:
                        out_dict[org] = {}
                    if clss not in out_dict[org]:
                        out_dict[org][clss] = []
                    out_dict[org][clss].append(module_dict[org][name])
    #Rename the categories, adding the number of modules that they represent
    if show_module_count:
        temp_dict = {}
        for org in out_dict:
            #Add new categories
            temp_dict[org] = {}
            for clss in out_dict[org]:
                    value  = out_dict[org][clss]
                    new_clss = "{} ({} modules)".format(clss, len(value))
                    temp_dict[org][new_clss] = value
        out_dict = temp_dict             
    #Consolidate the lists into single values depending on the specified method    
    for org in out_dict:
        for clss in out_dict[org]:
            if method == "avg":
                out_dict[org][clss] = sum(out_dict[org][clss]) / len(out_dict[org][clss])
            if method == "min":
                out_dict[org][clss] = min(out_dict[org][clss])
            if method == "max":
                out_dict[org][clss] = max(out_dict[org][clss])
    return out_dict

def BRITE_output(brite_dict, out_file):
    """
    Output function to write the contents of the BRITE dictionary to a tab-delimited text file
    """
    out = open(out_file, "w")
    # Write header line
    out.write("#Module\t")
    for org in brite_dict:
        out.write(org + "\t")
    out.write("\n")
    # Write per category gene count. Write total genes known behind the category
    for x in brite_dict:
        for cat in brite_dict[x]:
            total_genes = brite_dict[x][cat].split("/")[1]
            out.write(cat + " ({} genes)\t".format(total_genes))
            for org in brite_dict:
                if cat in brite_dict[org]:
                    out.write(str(brite_dict[org][cat].split("/")[0]) + "\t")
                else:
                    out.write("0" + "\t")
            out.write("\n")
        break
        
            

####################################################################
#MAIN
####################################################################    
if __name__ == "__main__":
    if "--in_dir" in sys.argv:
        indir = sys.argv[sys.argv.index("--in_dir") + 1]
    else:
        print("No input specified, specify input directory with '--in_dir'")
        sys.exit()
    if "--output" in sys.argv:
        out_prefix = sys.argv[sys.argv.index("--output") + 1]
    else:
        out_prefix = "KEGGstand_merged"
    #Initiate variables
    module_dict = {}
    BRITE_dict = {}
    #Iterate over the files in the input directory            
    for root, dirs, files in os.walk(indir): 
        for file in files: 
            #Obtain the completion value per module per fasta
            if file.endswith(".emapper.annotations_KEGG_completion.tsv"):
                org_name = file.partition(".emapper")[0]
                modules = completion_tsv_reader(os.path.join(root, file))
                module_dict[org_name] = modules  

concat_dict = module_dict["symbionts_cat_intact.faa"]
free1_dict = module_dict["CP102480_output_intact.faa"]
sym1_dict = module_dict["sym2_default_intact.faa"]
free2_dict = module_dict["free2_default_intact.faa"]
sym2_dict = module_dict["cyano_edit3_final_intact.faa"]
host_dict = module_dict["sino_clean_transcriptome.faa"]
threeway_dict = module_dict["Cyano_Sym2_Sino_combined"]

degraded1_pathways = []
degraded2_pathways = []
complemented_pathways = []
supplementation_candidates = []
supplementation_candidates_by_host = []
supplementation_for_host = []

for mod in sym1_dict:
    if float(free1_dict[mod]) > float(sym1_dict[mod]):
        degraded1_pathways.append(mod)
    if float(free2_dict[mod]) > float(sym2_dict[mod]):
        degraded2_pathways.append(mod)
    if float(concat_dict[mod]) > float(sym1_dict[mod]) and float(concat_dict[mod]) > float(sym2_dict[mod]): 
        complemented_pathways.append(mod)
    if float(concat_dict[mod]) == 1 and float(sym2_dict[mod]) + float(sym1_dict[mod]) < 2:
        supplementation_candidates.append(mod)
    if float(sym2_dict[mod]) == 1 and float(sym1_dict[mod]) < 1:
        supplementation_candidates.append(mod)
    if float(sym1_dict[mod]) == 1 and float(sym2_dict[mod]) < 1:
        supplementation_candidates.append(mod)
    if float(threeway_dict[mod]) > float(host_dict[mod]) and float(threeway_dict[mod]) > float(sym1_dict[mod]) and float(threeway_dict[mod]) > float(sym2_dict[mod]):
        supplementation_for_host.append(mod)
    if float(threeway_dict[mod]) > float(concat_dict[mod]):
        supplementation_candidates_by_host.append(mod)
        
        
with open(out_prefix + ".tsv", "w") as out:
    out.write("Sym1 degraded pathways   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in degraded1_pathways:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
    out.write("Sym2 degraded pathways   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in degraded2_pathways:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
    out.write("Symbionts complemented pathways   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in complemented_pathways:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
 
    deg_com_pathways = set(degraded1_pathways).intersection(set(complemented_pathways))
    out.write("Sym1 degraded pathways complemented by symbiont   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in deg_com_pathways:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
    deg_com_pathways = set(degraded2_pathways).intersection(set(complemented_pathways))
    out.write("Sym2 degraded pathways complemented by symbiont   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in deg_com_pathways:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
  
    out.write("Supplementation candidates (complete together or in symbiont)   Sym1	Free1	Sym2	Free2   Sym_combined \n")
    for mod in supplementation_candidates:
        out.write("{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod]))
    out.write("\n\n")
    
    out.write("Supplemented by host (more complete with host, compared to just symbionts)   Sym1	Free1	Sym2	Free2   Sym_combined host all_combined \n")
    for mod in supplementation_candidates_by_host:
        out.write("{}	{}	{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod], host_dict[mod],threeway_dict[mod]))
    out.write("\n\n")
    
    out.write("Supplemented for host (more complete all partners combined than individually)   Sym1	Free1	Sym2	Free2   Sym_combined host all_combined \n")
    for mod in supplementation_for_host:
        out.write("{}	{}	{}	{}	{}	{}	{}	{}\n".format(mod,sym1_dict[mod],free1_dict[mod],sym2_dict[mod],free2_dict[mod], concat_dict[mod], host_dict[mod],threeway_dict[mod]))
    out.write("\n\n")
    
