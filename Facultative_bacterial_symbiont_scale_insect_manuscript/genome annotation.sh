# Genome annotation

# Prokka

conda activate prokka

prokka --compliant --rfam --evalue 1e-05 --cpus 32 --outdir Arsenophonus_FASP_pilon_prokka Arsenophonus_FASP_pilon.fasta


# ANIclustermap

conda activate aniclustermap
ANIclustermap -i [Genome fasta directory] -o [output directory]


# BUSCO

Conda activate busco

busco -i Arsenophonus_CRMU.fasta -c 96 -m geno -l bacteria_odb10 -o Arsenophonus_CRMU_busco

# genomad

Conda activate genomad
genomad end-to-end --cleanup --splits 8 GCF_009025895.1.fna.gz genomad_output genomad_db

# CRISPR CasTyper

conda activate cctyper
cctyper assembly.fa my_output --prodigal meta
