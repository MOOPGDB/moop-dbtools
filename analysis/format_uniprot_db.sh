#!/bin/bash
# Format UniProt/Swiss-Prot FASTA for DIAMOND

# Download Swiss-Prot database (~560k sequences)
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz

# Uncompress
gunzip uniprot_sprot.fasta.gz

# Create DIAMOND database
diamond makedb --in uniprot_sprot.fasta -d uniprot_sprot.dmnd -p 2

echo "✓ DIAMOND database created: uniprot_sprot.dmnd"
