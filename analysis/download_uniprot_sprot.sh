#!/bin/bash
# Download UniProt/Swiss-Prot protein sequences

# Download latest Swiss-Prot database (~560k sequences)
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz

# Uncompress
gunzip uniprot_sprot.fasta.gz

echo "✓ Downloaded: uniprot_sprot.fasta"
echo ""
echo "Next step - format for DIAMOND:"
echo "  bash analysis/format_uniprot_db.sh"
