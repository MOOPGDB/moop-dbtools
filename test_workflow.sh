#!/bin/bash
# End-to-end MOOP database workflow test
#
# This script demonstrates the complete workflow:
# 1. Parse GFF3 to create feature table
# 2. Create SQLite database schema
# 3. Load features into database
# 4. Parse and load DIAMOND annotation results (UniProt and Ensembl)
# 5. Parse and load InterProScan results
#
# NOTE: Requires conda environment activated
#   mamba activate moop-dbtools
# Or: conda activate moop-dbtools

set -e

echo "=== MOOP Database Workflow Test ==="
echo ""

# Setup
TEST_DATA="test_data"
OUTPUT_DIR="test_output"
GENUS="Chamaeleo"
SPECIES="calyptratus"
ASSEMBLY="CCA3"
DB_FILE="${OUTPUT_DIR}/organism.sqlite"

mkdir -p "$OUTPUT_DIR"

# Step 1: Parse GFF3 to features TSV
echo "Step 1: Parsing GFF3 to create feature table..."
perl parsers/parse_GFF3_to_MOOP_TSV.pl "$TEST_DATA/genomic.gff3" "$TEST_DATA/organisms.tsv" "$GENUS" "$SPECIES" "$ASSEMBLY" > "$OUTPUT_DIR/features.tsv"
echo "✓ Created: $OUTPUT_DIR/features.tsv"
echo ""

# Step 2: Create SQLite database using schema
echo "Step 2: Creating SQLite database with schema..."
sqlite3 "$DB_FILE" < create_schema_sqlite.sql
echo "✓ Created database: $DB_FILE"
echo ""

# Step 3: Load features into database
echo "Step 3: Loading features into database..."
perl loaders/load_genes_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/features.tsv"
echo "✓ Loaded features into database"
echo ""

# Step 4: Parse and load DIAMOND results
echo "Step 4: Parsing DIAMOND results (UniProt)..."
perl parsers/parse_DIAMOND_to_MOOP_TSV.pl "$TEST_DATA/UNIPROT_sprot.tophit.tsv" "UniProtKB/Swiss-Prot" "2024.01" "https://www.uniprot.org" "https://www.uniprot.org/uniprotkb/"
echo "✓ Created UniProtKB_Swiss-Prot.homologs.moop.tsv"

echo "Loading DIAMOND annotations (UniProt) into database..."
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "UniProtKB_Swiss-Prot.homologs.moop.tsv"
echo "✓ Loaded DIAMOND annotations (UniProt)"

echo "Parsing DIAMOND results (Ensembl)..."
perl parsers/parse_DIAMOND_to_MOOP_TSV.pl "$TEST_DATA/ENS_homo_sapiens.tophit.tsv" "Ensembl Homo sapiens" "115" "https://www.ensembl.org" "https://www.ensembl.org/Homo_sapiens/Gene/Summary?g="
echo "✓ Created Ensembl_Homo_sapiens.homologs.moop.tsv"

echo "Loading DIAMOND annotations (Ensembl) into database..."
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "Ensembl_Homo_sapiens.homologs.moop.tsv"
echo "✓ Loaded DIAMOND annotations (Ensembl)"
echo ""

# Step 5: Parse and load InterProScan results
echo "Step 5: Parsing InterProScan results..."
perl parsers/parse_InterProScan_to_MOOP_TSV.pl "$TEST_DATA/iprscan_results.tsv" --version "5.52.0" --outdir "$OUTPUT_DIR"
echo "✓ Created InterProScan annotations TSV files"

echo "Loading InterProScan annotations into database..."
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/CDD.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/Coils.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/FunFam.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/Gene3D.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/InterPro.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/MobiDBLite.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/NCBIfam.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/PANTHER.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/PRINTS.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/Pfam.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/Phobius.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/ProSitePatterns.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/ProSiteProfiles.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/SMART.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/SUPERFAMILY.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/SignalP_GRAM_POSITIVE.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/TMHMM.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/InterPro2GO.iprscan.moop.tsv"
perl loaders/load_annotations_sqlite.pl "$DB_FILE" "$OUTPUT_DIR/PANTHER2GO.iprscan.moop.tsv"
echo "✓ Loaded InterProScan annotations"
echo ""

echo "=== Workflow Complete ==="
echo ""
echo "Database: $DB_FILE"
echo "Output files in: $OUTPUT_DIR/"
echo ""
echo "To query the database:"
echo "  sqlite3 $DB_FILE '.schema'"
echo "  sqlite3 $DB_FILE 'SELECT COUNT(*) FROM feature;'"
echo "  sqlite3 $DB_FILE 'SELECT COUNT(*) FROM annotation;'"
echo "  sqlite3 $DB_FILE 'SELECT * FROM feature;'"
