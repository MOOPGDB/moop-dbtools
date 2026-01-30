#!/bin/bash
# Format Ensembl human FASTA for DIAMOND
#
# NOTE: Requires DIAMOND installed
#   mamba activate moop-dbtools
# Or: conda activate moop-dbtools
# Or: mamba install -c bioconda diamond

# Create DIAMOND database
diamond makedb --in Homo_sapiens.GRCh38.pep.all.fa -d ensembl_human_GRCh38.dmnd -p 2

echo "✓ DIAMOND database created: ensembl_human_GRCh38.dmnd"
echo ""
echo "Next step - run BLAST search:"
echo "  bash analysis/run_diamond_vs_ensembl_human.sh"
