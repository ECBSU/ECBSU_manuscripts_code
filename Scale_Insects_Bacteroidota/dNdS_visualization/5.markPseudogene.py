import pandas as pd

# Read the first Excel file (pseudogene information)
pseudogenes_file = 'PseudogenizedCDSs_0.65.xlsx'
pseudogenes_df = pd.read_excel(pseudogenes_file)

# Read the second Excel file (information on all genes)
all_genes_file = 'Orthogroups_extracted_dupliMarked_splitted.xlsx'
all_genes_df = pd.read_excel(all_genes_file)

# Extract the list of pseudogene names
pseudogene_names = pseudogenes_df.values.flatten()  # Flatten the pseudogenes_df into a 1D array

# Iterate through all columns in all_genes_df and mark pseudogenes with a star (*)
for column in all_genes_df.columns:
    all_genes_df[column] = all_genes_df[column].apply(lambda x: '*' + str(x) if str(x) in pseudogene_names else x)

# Save the modified DataFrame to a new Excel file
output_file = 'Orthogroups_extracted_dupliMarked_splitted_pseudoMarked.xlsx'
all_genes_df.to_excel(output_file, index=False)
