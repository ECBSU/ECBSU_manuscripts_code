import pandas as pd

# Load gene product list
gene_list_df = pd.read_excel("TargetGeneList_order.xlsx")
gene_products = gene_list_df["Gene_product"].tolist()

# Load Orthogroups file
orthogroups_df = pd.read_excel("Orthogroups.xlsx", sheet_name=0)

# Get all genome columns (excluding "Orthogroup")
genome_columns = orthogroups_df.columns.tolist()[1:]

# Prepare results
matched_rows = []
matched_products = []

# Search for each gene product (allow multiple orthogroup hits per product)
for product in gene_products:
    found = False
    for idx, row in orthogroups_df.iterrows():
        for col in genome_columns:
            cell = row[col]
            if pd.isna(cell):
                continue
            if product in str(cell):  # substring match
                matched_rows.append(row)
                matched_products.append(product)
                found = True  # mark as found, but keep going to get all matches
                break  # break column loop, not row loop
    if not found:
        print(f"❌ Not found: {product}")

# Create output DataFrame with all matches
output_df = pd.DataFrame(matched_rows, columns=orthogroups_df.columns)

# Save to Excel
output_df.to_excel("Orthogroups_extracted.xlsx", index=False)

print("\n📁 Output saved as Orthogroups_extracted.xlsx")
