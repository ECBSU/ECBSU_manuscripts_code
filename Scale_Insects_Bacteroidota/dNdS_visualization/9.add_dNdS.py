import pandas as pd

# Load dN/dS table
df1 = pd.read_excel('dNdS_FLPA.xlsx')

# Load orthogroup gene table
df2 = pd.read_excel('Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final2.xlsx')

# Build gene-to-dNdS dictionary
gene_dict = dict(zip(df1['Gene'], df1['dNdS']))

# Work on a copy of the A–U columns
target = df2.iloc[:, :21].replace(gene_dict)
target = target.infer_objects(copy=False)

# Assign back to df2
df2.iloc[:, :21] = target

# Save result
df2.to_excel('Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final2_dNdS_FLPA.xlsx', index=False)

print("✅ Replacement complete. Output written to: Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final2_dNdS_FLPA.xlsx")
