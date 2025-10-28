import pandas as pd

# 🔧 Input and output filenames
input_file = "Orthogroups_extracted_dupliMarked.xlsx"
output_file = "Orthogroups_extracted_dupliMarked_splitted.xlsx"

# Load Excel file
df = pd.read_excel(input_file)

# DataFrame to store result
split_df = pd.DataFrame()

# ✅ Gene ID extractor
def extract_gene_code(cell_value):
    if isinstance(cell_value, str):
        parts = cell_value.strip().split('_')
        if len(parts) >= 3 and parts[1] == 'ign':
            return '_'.join(parts[:3])  # keep ACLA_ign_00325
        else:
            return '_'.join(parts[:2])  # keep DRPI_00250
    return ""

# Process each column
for col in df.columns:
    if df[col].dtype == 'object':
        # Split on comma
        split_values = df[col].astype(str).str.split(',', expand=True)

        # Apply gene ID extraction
        split_values = split_values.applymap(extract_gene_code)

        # ✅ Replace NaNs with empty strings
        split_values = split_values.fillna("").astype(str)

        # Rename columns
        split_values.columns = [f"{col}_gene{i+1}" for i in range(split_values.shape[1])]

        # Add to result
        split_df = pd.concat([split_df, split_values], axis=1)
    else:
        # For non-string columns, preserve original
        split_df = pd.concat([split_df, df[[col]]], axis=1)

# Save output
split_df.to_excel(output_file, index=False)
print(f"✅ Done! Output saved as: {output_file} — no NaNs, all empty cells filled.")
