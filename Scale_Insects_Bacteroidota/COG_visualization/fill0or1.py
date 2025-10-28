import pandas as pd

# Read the Excel file into a pandas DataFrame
df = pd.read_excel('DATA_byPhylogeny_reordered.xlsx')  # Replace 'your_excel_file.xlsx' with your actual file path

# Replace empty cells with 0 and non-empty cells with 1 for the entire DataFrame
df = df.applymap(lambda x: 1 if pd.notna(x) and x != '' else 0)

# Save the updated DataFrame to a new Excel file
df.to_excel('DATA_Phylogeny_reordered_0or1.xlsx', index=False)

print('Updated data saved to DATA_Phylogeny_reordered_0or1.xlsx')
