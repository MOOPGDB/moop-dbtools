#!/bin/bash
# End-to-end MOOP database workflow test
#
# This script demonstrates the complete workflow:
# 1. Parse GFF3 to create feature table
# 2. Create SQLite database
# 3. Load features into database
# 4. Load DIAMOND annotation results
# 5. Load InterProScan results
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

# Step 2: Create SQLite database schema
echo "Step 2: Creating SQLite database schema..."
sqlite3 "$DB_FILE" < create_schema_sqlite.sql
echo "✓ Created database schema: $DB_FILE"
echo ""

# Step 3: Load organism and genome metadata
echo "Step 3: Loading organism and genome metadata..."
perl loaders/load_genes_sqlite.pl --schema --db "$DB_FILE" --genus "$GENUS" --species "$SPECIES"
echo "✓ Loaded organism/genome metadata"
echo ""

# Step 4: Load features into database
echo "Step 4: Loading features into database..."
perl loaders/load_genes_sqlite.pl --db "$DB_FILE" --genus "$GENUS" --species "$SPECIES" --file "$OUTPUT_DIR/features.tsv"
echo "✓ Loaded features into database"
echo ""

# Step 5: Parse and load DIAMOND results
echo "Step 5: Parsing DIAMOND results..."
perl parsers/parse_DIAMOND_to_MOOP_TSV.pl "$TEST_DATA/UNIPROT_sprot.tophit.tsv" uniprot_sprot > "$OUTPUT_DIR/diamond_annotations.tsv"
echo "✓ Created: $OUTPUT_DIR/diamond_annotations.tsv"

echo "Loading DIAMOND annotations into database..."
perl loaders/load_annotations_sqlite.pl --db "$DB_FILE" --file "$OUTPUT_DIR/diamond_annotations.tsv" --source "UNIPROT/SwissProt" --version "2024.01"
echo "✓ Loaded DIAMOND annotations"
echo ""

# Step 6: Parse and load InterProScan results
echo "Step 6: Parsing InterProScan results..."
perl parsers/parse_InterProScan_to_MOOP_TSV.pl "$TEST_DATA/iprscan_results.tsv" > "$OUTPUT_DIR/interproscan_annotations.tsv"
echo "✓ Created: $OUTPUT_DIR/interproscan_annotations.tsv"

echo "Loading InterProScan annotations into database..."
perl loaders/load_annotations_sqlite.pl --db "$DB_FILE" --file "$OUTPUT_DIR/interproscan_annotations.tsv" --source "InterProScan" --version "5.52.0"
echo "✓ Loaded InterProScan annotations"
echo ""

echo "=== Workflow Complete ==="
echo ""
echo "Database: $DB_FILE"
echo "Output files in: $OUTPUT_DIR/"
echo ""
echo "To query the database:"
echo "  sqlite3 $DB_FILE '.schema'"
echo "  sqlite3 $DB_FILE 'SELECT COUNT(*) FROM gene;'"
echo "  sqlite3 $DB_FILE 'SELECT COUNT(*) FROM annotation;'"
