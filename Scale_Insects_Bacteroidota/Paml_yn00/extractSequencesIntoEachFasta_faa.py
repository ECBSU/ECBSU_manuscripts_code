import pandas as pd
from Bio import SeqIO

# Read the Excel file
df = pd.read_excel('FLJO_vs_ACLA.xlsx', header=None)

# Iterate over each row in the DataFrame
for index, row in df.iterrows():
    # Extract filename from the first column
    filename = row.iloc[0]
    output_file_name = f"{filename}.faa"
    
    # Extract sequence names from the remaining columns
    sequence_names = row.iloc[1:].dropna()

    # Create a new output file for the current filename
    with open(output_file_name, 'w') as output_handle:
        # Iterate over the sequences in the faa file
        for record in SeqIO.parse('/Users/jinyeongchoi/Desktop/Projects/Bacteroidota/dN:dS_Symbiont_vs._free-living_bactrium_2nd/rawSeq_aa/combined.faa', 'fasta'):
            # Check if the sequence ID matches any desired sequence name in the row
            if record.id in sequence_names.values:
                # Write the matching sequence to the output file
                SeqIO.write(record, output_handle, 'fasta')
