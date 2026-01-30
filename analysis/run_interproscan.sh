#!/bin/bash
# Run InterProScan protein domain analysis

# Run InterProScan on test proteins
interproscan.sh \
  --input test_data/protein.aa.fa \
  --output interproscan_results \
  --formats tsv,json \
  --iprlookup \
  --goterms

echo "✓ InterProScan complete: interproscan_results.tsv"
echo ""
echo "Parse results with:"
echo "  perl parsers/parse_InterProScan_to_MOOP_TSV.pl interproscan_results.tsv > annotations.tsv"
