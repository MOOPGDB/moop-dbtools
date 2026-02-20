#!/bin/bash
# Download Ensembl human protein sequences

# Download latest Ensembl human proteins
wget https://ftp.ensembl.org/pub/release-115/fasta/homo_sapiens/pep/Homo_sapiens.GRCh38.pep.all.fa.gz

# Uncompress
gunzip Homo_sapiens.GRCh38.pep.all.fa.gz

echo "✓ Downloaded: Homo_sapiens.GRCh38.pep.all.fa"
echo ""
echo "Next step - format for DIAMOND:"
echo "  bash analysis/format_ensembl_human_db.sh"
