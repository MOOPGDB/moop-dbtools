#!/bin/bash
# Format UniProt/Swiss-Prot FASTA for DIAMOND
#
# NOTE: Requires DIAMOND installed
#   mamba activate moop-dbtools
# Or: conda activate moop-dbtools
# Or: mamba install -c bioconda diamond

# Create DIAMOND database
diamond makedb --in uniprot_sprot.fasta -d uniprot_sprot.dmnd -p 2

echo "✓ DIAMOND database created: uniprot_sprot.dmnd"
echo ""
echo "Next step - run BLAST search:"
echo "  bash analysis/run_diamond_vs_uniprot_sprot.sh"
