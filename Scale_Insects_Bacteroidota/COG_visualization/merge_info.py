import pandas as pd
import re

# Regular expression pattern to extract "code name_5 digit numbers"
pattern = r'(\w+_\d{5})'

# Function to extract the desired format from the existing names
def extract_gene_code(name):
    if isinstance(name, str):  # Check if the value is a string
        match = re.search(pattern, name)
        if match:
            return match.group(1)
    return None

# Read the first Excel file into a pandas DataFrame
df1 = pd.read_excel('COGinfo.xlsx')

# Read the second Excel file into a pandas DataFrame
input_excel_file = 'GeneCodelist.xlsx'
output_excel_file = 'merged_excel_file.xlsx'
df2 = pd.read_excel(input_excel_file)

# Extract GeneCode from the second DataFrame
df2['GeneCode'] = df2['GeneCode'].apply(lambda x: extract_gene_code(x))

# Create a dictionary to store information based on GeneCode
code_info_dict = {}
for index, row in df1.iterrows():
    gene_codes = row['GeneCode'].split(',')
    for code in gene_codes:
        code_info_dict[code.strip()] = {
            'COG_category': row['COG_category'],
            'Description': row['Description'],
            'Preferred_name': row['Preferred_name']
        }

# Function to merge information
def merge_info(row):
    gene_codes = str(row['GeneCode']).split(',')
    merged_info = {
        'COG_category': [],
        'Description': [],
        'Preferred_name': []
    }
    for code in gene_codes:
        code = code.strip()
        if code in code_info_dict:
            merged_info['COG_category'].append(code_info_dict[code]['COG_category'])
            merged_info['Description'].append(code_info_dict[code]['Description'])
            merged_info['Preferred_name'].append(code_info_dict[code]['Preferred_name'])
    row['COG_category'] = ', '.join(merged_info['COG_category'])
    row['Description'] = ', '.join(merged_info['Description'])
    row['Preferred_name'] = ', '.join(merged_info['Preferred_name'])
    return row

# Apply the function to merge information to the second DataFrame
df2 = df2.apply(merge_info, axis=1)

# Save the merged DataFrame back to an Excel file
df2.to_excel(output_excel_file, index=False, na_rep='')

print(f'Merged data saved to {output_excel_file}')
