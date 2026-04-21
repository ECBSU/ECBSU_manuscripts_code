# A = dada2 ASVs, B = SymPortal DIVs
ASVs=./output/ASV_Symbiodiniaceae_filtered.fasta
DIVsB=./input/20250805T070924.seqs.fasta

# A queries vs B database
vsearch --usearch_global $ASVs --db $DIVs --id 0.5 \
  --blast6out ASVs_vs_DIVs.tsv --maxaccepts 0 --maxrejects 0 --top_hits_only --strand both --threads 6

# B queries vs A database
vsearch --usearch_global $DIVs --db $ASVs --id 0.5 \
  --blast6out DIVs_vs_ASVs.tsv --maxaccepts 0 --maxrejects 0 --top_hits_only --strand both --threads 6
