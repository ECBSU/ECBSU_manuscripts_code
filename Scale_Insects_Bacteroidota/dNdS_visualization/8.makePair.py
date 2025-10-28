import pandas as pd
import os

# ========== CONFIGURATION ==========
input_excel = "Orthogroups_extracted_dupliMarked_splitted_pseudoMarked_selected_final.xlsx"
output_dir = "genePairs"
summary_file = os.path.join(output_dir, "gene_pair_counts.txt")
os.makedirs(output_dir, exist_ok=True)

symbiont_prefixes = [
    'ORUR', 'ICPU', 'ICSE', 'DRPI', 'DRCO', 'COCA', 'LLAX', 'ACLA',
    'ASSP', 'ININ', 'RASP', 'PUIS', 'AUIS', 'ASNE', 'COCH',
    'RIMA', 'RHAM', 'EUCO', 'RAIS', 'CRMU', 'CRGE'
]

FLJO_cols = ['FLJO']
FLPA_cols = ['FLPA']

# Read Excel
df = pd.read_excel(input_excel)

def is_pseudogene(gene):
    return isinstance(gene, str) and gene.startswith('*')

# Start summary log
with open(summary_file, "w") as summary:
    summary.write("Gene pair counts (non-pseudogenized & unique)\n")
    summary.write("Symbiont\tFLJO_pairs\tFLPA_pairs\n")

    for sym_prefix in symbiont_prefixes:
        symbiont_cols = [col for col in df.columns if col.startswith(sym_prefix)]
        if not symbiont_cols:
            continue

        # ==== FLJO ====
        df_sym = df[['Orthogroup'] + FLJO_cols + symbiont_cols].copy()

        def clean_and_flatten_symbiont(row):
            sym_genes = row[symbiont_cols].dropna().tolist()
            intact = [g for g in sym_genes if not is_pseudogene(g)]
            return ','.join(intact) if intact else pd.NA

        df_sym[sym_prefix] = df_sym.apply(clean_and_flatten_symbiont, axis=1)
        df_sym = df_sym[['Orthogroup'] + FLJO_cols + [sym_prefix]]
        df_sym = df_sym.dropna(subset=[sym_prefix])
        df_sym = df_sym.drop_duplicates()
        fljo_count = len(df_sym)

        if not df_sym.empty:
            out_fljo = os.path.join(output_dir, f"FLJO_vs_{sym_prefix}.xlsx")
            df_sym.to_excel(out_fljo, index=False)
            print(f"✅ Saved FLJO file: {out_fljo} (Unique gene pairs: {fljo_count})")

        # ==== FLPA ====
        df_sym_flpa = df[['Orthogroup'] + FLPA_cols + symbiont_cols].copy()
        df_sym_flpa[sym_prefix] = df_sym_flpa.apply(clean_and_flatten_symbiont, axis=1)
        df_sym_flpa = df_sym_flpa[['Orthogroup'] + FLPA_cols + [sym_prefix]]
        df_sym_flpa = df_sym_flpa.dropna(subset=[sym_prefix])
        df_sym_flpa = df_sym_flpa.drop_duplicates()
        flpa_count = len(df_sym_flpa)

        if not df_sym_flpa.empty:
            out_flpa = os.path.join(output_dir, f"FLPA_vs_{sym_prefix}.xlsx")
            df_sym_flpa.to_excel(out_flpa, index=False)
            print(f"✅ Saved FLPA file: {out_flpa} (Unique gene pairs: {flpa_count})")

        # Write to summary
        summary.write(f"{sym_prefix}\t{fljo_count}\t{flpa_count}\n")

print("\n📄 Summary written to:", summary_file)
print("🎉 All files processed.")
