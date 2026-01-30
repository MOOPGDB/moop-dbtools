#!/bin/bash
# Run DIAMOND BLASTP search against Ensembl human
#
# NOTE: Requires DIAMOND installed
#   mamba activate moop-dbtools
# Or: conda activate moop-dbtools

diamond blastp \
  --query test_data/protein.aa.fa \
  --db ensembl_human_GRCh38.dmnd \
  --out diamond_vs_ensembl_human.m8 \
  --outfmt 6 \
  --evalue 1e-5 \
  --threads 2

echo "✓ DIAMOND search complete: diamond_vs_ensembl_human.m8"
echo ""
echo "Parse results with:"
echo "  perl parsers/parse_DIAMOND_to_MOOP_TSV.pl diamond_vs_ensembl_human.m8 ensembl_human > annotations.tsv"
