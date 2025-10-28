import pandas as pd
from Bio import SeqIO
import os

# 📥 Input files
input_excel = 'Orthogroups_extracted_dupliMarked_splitted.xlsx'
fasta_path = '/Users/jinyeongchoi/Desktop/Projects/Bacteroidota/dN:dS_Symbiont_vs._free-living_bactrium_2nd/rawSeq_aa/combined.faa'

# 📤 Output folder (make sure it exists or create it)
output_dir = '/Users/jinyeongchoi/Desktop/Projects/Bacteroidota/dN:dS_Symbiont_vs._free-living_bactrium_2nd/Extracted_AA_seq/'
os.makedirs(output_dir, exist_ok=True)

# 🔁 Load Excel and sequences
df = pd.read_excel(input_excel, header=None)
all_seqs = {record.id: record for record in SeqIO.parse(fasta_path, 'fasta')}

# 🔍 For each row, extract gene set and save
for index, row in df.iterrows():
    filename = row.iloc[0]
    output_file = os.path.join(output_dir, f"{filename}.faa")

    sequence_names = row.iloc[1:].dropna().astype(str)

    found = []
    missing = []

    for gene_id in sequence_names:
        if gene_id in all_seqs:
            found.append(all_seqs[gene_id])
        else:
            missing.append(gene_id)

    # Save matching sequences
    with open(output_file, 'w') as out_handle:
        SeqIO.write(found, out_handle, 'fasta')

    # Terminal report
    if missing:
        print(f"⚠️  {filename}: {len(missing)} sequence(s) not found:")
        for m in missing:
            print(f"   - {m}")
    else:
        print(f"✅ {filename}: All sequences found ({len(found)})")
