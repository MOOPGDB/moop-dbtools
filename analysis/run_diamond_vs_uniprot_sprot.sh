#!/bin/bash
# Run DIAMOND BLASTP search against Swiss-Prot
#
# NOTE: Requires DIAMOND installed
#   mamba activate moop-dbtools
# Or: conda activate moop-dbtools
# Or: mamba install -c bioconda diamond

# Query: test protein sequences
# Database: Swiss-Prot (must be formatted first with format_uniprot_db.sh)

diamond blastp \
  --query test_data/protein.aa.fa \
  --db uniprot_sprot.dmnd \
  --out diamond_results.m8 \
  --outfmt 6 \
  --evalue 1e-5 \
  --threads 2

echo "✓ DIAMOND search complete: diamond_results.m8"
echo ""
echo "Parse results with:"
echo "  perl parsers/parse_DIAMOND_to_MOOP_TSV.pl diamond_results.m8 uniprot_sprot > annotations.tsv"
