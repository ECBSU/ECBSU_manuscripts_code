import pandas as pd

# Load the Excel file
input_file = 'Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final2_dNdS_FLPA.xlsx'  # Replace with your actual filename
df = pd.read_excel(input_file)

# Define target columns
target_columns = [
    "CRMU", "CRGE", "ICPU", "ICSE", "DRPI", "DRCO", "COCA", "LLAX", "ORUR", "ACLA",
    "ASSP", "ININ_H", "RASP", "PUIS", "AUIS", "ASNE", "COCH", "RIMA", "RHAM", "EUCO", "RAIS"
]

# Replace numbers > 1.0 with string "> 1.0"
df[target_columns] = df[target_columns].applymap(lambda x: "> 1.0" if pd.notnull(x) and isinstance(x, (int, float)) and x > 1.0 else x)

# Save the modified DataFrame
output_file = 'Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final2_dNdS_FLPA_>1.0Marked.xlsx'
df.to_excel(output_file, index=False)

print(f"✅ Replacement complete. Output saved to: {output_file}")
