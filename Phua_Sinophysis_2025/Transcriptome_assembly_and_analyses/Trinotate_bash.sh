#!/bin/bash
echo "File header: trinity_out_dir.Trinity"

#Hammer to identify protein domains
echo "starting Hammer"
hmmscan --cpu 8 --domtblout trinity_out_dir.Trinity.TrinotatePFAM.out /home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Pfam-A.hmm trinity_out_dir.Trinity.fasta.transdecoder.pep > trinity_out_dir.Trinity.pfam.log

#SignalP to predct signal peptides
echo "Starting Signalp"
/home/ecbsu/programs/signalp-4.1/signalp -f short -n trinity_out_dir.Trinity.signalp.out trinity_out_dir.Trinity.fasta.transdecoder.pep

#tmHMM for transmembrane proteins
echo "Starting tmHMM"
/home/ecbsu/programs/tmhmm-2.0c/bin/tmhmm --short < trinity_out_dir.Trinity.fasta.transdecoder.pep > trinity_out_dir.Trinity.tmhmm.out

#RNAMMER to identify rRNA transcripts
echo "Starting RNAMMER"
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/util/rnammer_support/RnammerTranscriptome.pl --transcriptome trinity_out_dir.Trinity.fasta --path_to_rnammer /home/ecbsu/programs/RNAMMER/rnammer

#BLAST homologies with Trinotate
blastx -query trinity_out_dir.Trinity.fasta -db /home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/uniprot_sprot.pep -num_threads 16 -max_target_seqs 1 -outfmt 6 > trinity_out_dir.Trinity.uniprot.blastx

blastp -query trinity_out_dir.Trinity.fasta.transdecoder.pep -db /home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/uniprot_sprot.pep -num_threads 16 -max_target_seqs 1 -outfmt 6 > trinity_out_dir.Trinity.uniprot.blastp

#LOAD TRANSCRIPTS AND CODING REGIONS
#Load a fresh Trinotate.sqlite from the Trinotate folder
cp ~/programs/Trinotate-Trinotate-v3.2.2/Trinotate.sqlite .

#Load info into sqlite database
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite init --gene_trans_map trinity_out_dir.Trinity.fasta.gene_trans_map --transcript_fasta trinity_out_dir.Trinity.fasta --transdecoder_pep trinity_out_dir.Trinity.fasta.transdecoder.pep
echo "Prepping annotation report"
#LOAD data and create annotation report
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_pfam trinity_out_dir.Trinity.TrinotatePFAM.out
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_swissprot_blastx trinity_out_dir.Trinity.uniprot.blastx
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_swissprot_blastp trinity_out_dir.Trinity.uniprot.blastp
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_tmhmm trinity_out_dir.Trinity.tmhmm.out
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_signalp trinity_out_dir.Trinity.signalp.out
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite LOAD_rnammer trinity_out_dir.Trinity.fasta.rnammer.gff
/home/ecbsu/programs/Trinotate-Trinotate-v3.2.2/Trinotate Trinotate.sqlite report > trinity_out_dir.Trinity_trinotate_annotation_report.xls
echo "Annotation report ready"

