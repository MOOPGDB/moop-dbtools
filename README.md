# MOOP Database Tools

Database setup, analysis, and loading utilities for MOOP (Multiple Organisms One Platform).

## Important: Work Off the Server

**You do not need to run these tools on your MOOP web server.** All analysis, database creation, and loading can be done on a separate machine (local computer, HPC cluster, etc.). Once complete, simply copy the final `organism.sqlite` file to your MOOP organisms data directory.

This keeps the web server free from processing overhead and allows you to test data before deployment. See the guides below for details on deploying the final database.

## Documentation

Choose a guide based on your task:

### [DATABASE_LOADING.md](docs/DATABASE_LOADING.md) - Creating and Loading the Database
Instructions for:
- Setting up the SQLite database
- Loading gene features from TSV files
- Loading annotations into the database

Start here if you have gene data or annotations ready to load.

### [ANALYSIS_AND_PARSING.md](docs/ANALYSIS_AND_PARSING.md) - BLAST Homolog Analysis
Complete workflow for:
- Downloading reference protein databases (UniProt, Ensembl)
- Running DIAMOND BLASTP searches
- Parsing DIAMOND results into MOOP annotation format
- Loading annotations into the database

Start here if you want to find homologous proteins for your genes.

### [ANNOTATION_TYPES.md](docs/ANNOTATION_TYPES.md) - Standard Annotation Types
Reference guide for:
- All standard MOOP annotation types (Orthologs, Domains, Gene Ontology, etc.)
- Required format for annotation TSV files
- Custom annotation type support
- How MOOP manages annotation metadata

Start here to understand what annotation types are available and how to format custom analysis output.

## Custom Analysis Formats

**You are not limited to DIAMOND and InterProScan!** Any analysis tool output can be formatted to load into MOOP as long as it follows the MOOP annotation format rules:

### Required Format for Annotations

All annotation TSV files must have:

**1. Metadata Headers (lines starting with `##`)**
```
## Annotation Source: Your Tool Name
## Annotation Source Version: 1.0.0
## Annotation Accession URL: https://example.com/
## Annotation Source URL: https://example.com/
## Annotation Type: Protein Domains | Gene Families | Gene Ontology | Custom
## Annotation Creation Date: 2025-01-30
```

**2. Tab-Delimited Data Format**

Column order matters. Column headers can be anything, but data must follow this format:

```
## Gene    Accession    Description    Score
feature_uniquename    hit_id    hit_description    score_value
```

Where:
- **Column 1 (feature_uniquename):** Must match first column from your genes.tsv file (ID_IN_FEATURE_TABLE)
- **Column 2 (hit_id):** Accession/ID for the hit in the reference database (Annotation-Analysis-HIT-ID)
- **Column 3 (hit_description):** Text description of the hit (Annotation-description)
- **Column 4 (score):** Numerical score, e-value, confidence, or other assessment metric (hit-assessment-score)

### Example Custom Annotation Format

```
## Annotation Source: MyProteinPredictor
## Annotation Source Version: 2.5.1
## Annotation Accession URL: https://myserver.org/protein/
## Annotation Source URL: https://myserver.org/
## Annotation Type: Protein Families
## Annotation Creation Date: 2025-01-30
## MyGene    PredictorHit    FamilyInfo    Confidence
CCA3t004839001.1    PRED001    Family_ABC    0.95
CCA3t004843001.1    PRED002    Family_XYZ    0.87
CCA3t004844001.1    PRED003    Family_ABC    0.92
```

## Installing Conda or Mamba

You need a conda-compatible package manager **only if you want to use these database tools**. Choose from several options:

**When do you need conda/mamba?**
1. **Database loading (minimal)** - Just need Perl, DBI, DBD::SQLite (smallest install)
2. **DIAMOND analysis** - If you want to run DIAMOND BLASTP searches
3. **InterProScan** - If you want to run protein domain analysis
4. **Optional** - You can also set up your own analysis workflows and just use our database loading scripts

### Minimal Install (Recommended for Database Loading Only)

If you only need to load gene and annotation data into the database:

```bash
# Create minimal environment
mamba create -n moop-dbtools -c bioconda -c conda-forge perl perl-dbi perl-dbd-sqlite

# Activate environment
mamba activate moop-dbtools
```

This minimal install is ~100 MB and includes everything needed for database creation and loading.

### Full Install (With Analysis Tools)

If you want to include DIAMOND, InterProScan, or both:

```bash
# Full environment with all tools
mamba env create -f environment.yml
mamba activate moop-dbtools
```

This install is larger (~2-3 GB) due to analysis tool databases.

**Selective Installation:**

If you want only specific tools, edit `environment.yml` before creating the environment:
- Remove the `diamond` line if you have DIAMOND installed elsewhere
- Remove the `interproscan` line if you don't need protein domain analysis (saves ~1-2 GB)

Or install/remove after creation:
```bash
# Create minimal environment first
mamba create -n moop-dbtools -c bioconda -c conda-forge perl perl-dbi perl-dbd-sqlite

# Add specific tools as needed
mamba activate moop-dbtools
mamba install -c bioconda diamond
mamba install -c bioconda interproscan

# Or remove tools to save space
mamba remove diamond interproscan
```

**Using External Tools:**

You can still use our Perl parsing scripts with tools installed elsewhere:
- Have DIAMOND on your system? Use `parse_DIAMOND_to_MOOP_TSV.pl` with your own DIAMOND installation
- Have InterProScan installed? Use `parse_InterProScan_to_MOOP_TSV.pl` with your own InterProScan
- No need for conda at all if you already have these tools!

If you already have Perl, DBI, and DBD::SQLite installed elsewhere, you don't need conda just for database loading.

**Available conda/mamba options:**
- **Miniforge** (recommended) - Lightweight, conda-based, smallest download
- Mambaforge - Lightweight, mamba-based, faster for large environments
- Anaconda - Full-featured, larger download
- Miniconda - Smaller than Anaconda, still substantial
- Micromamba - Ultra-lightweight (C++ implementation)

### Quick Install: Miniforge (Recommended)

We recommend **Miniforge** because it's the smallest lightweight option that includes conda.

**Linux/Mac:**
```bash
# Download installer
curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh -o miniforge.sh

# Run installer
bash miniforge.sh

# Follow prompts, accept license, choose install location
# Add to PATH when asked

# Verify installation
conda --version
```

**Windows:**
Download the `.exe` installer from:
https://github.com/conda-forge/miniforge/releases

Run the installer and follow the setup wizard.

**After installation:**
```bash
# Initialize shell (do this once)
conda init

# Restart your terminal, then you're ready to use conda
```

**Alternative: Mambaforge (faster for large environments)**

If you prefer faster package resolution, use Mambaforge instead:
https://github.com/conda-forge/mambaforge/releases

Use `mamba` instead of `conda` for all commands below.

## Quick Reference

### Setup (required for all tasks)

```bash
# Create the environment
mamba env create -f environment.yml

# Activate the environment
mamba activate moop-dbtools
```

### Common Tasks

**Convert GFF3 to MOOP gene format:**
```bash
perl parsers/parse_GFF3_to_MOOP_TSV.pl genomic.gff3 organisms.tsv Chamaeleo calyptratus CCA3 > genes.tsv
```

**Create empty database:**
```bash
sqlite3 organism.sqlite < create_schema_sqlite.sql
```

**Load gene data:**
```bash
perl loaders/load_genes_sqlite.pl --db organism.sqlite --genus Chamaeleo --species calyptratus --file genes.tsv
```

**Load annotations:**
```bash
perl loaders/load_annotations_sqlite.pl --db organism.sqlite --file annotations.tsv --source "Analysis Name" --version "1.0"
```

**Run DIAMOND BLAST:**
```bash
diamond blastp --ultra-sensitive --evalue 1e-5 --query proteins.fa --db ref.dmnd --out hits.tsv --outfmt 6 qseqid sseqid stitle evalue
```

**Parse DIAMOND results:**
```bash
perl parsers/parse_DIAMOND_to_MOOP_TSV.pl hits.tsv uniprot_sprot > annotations.tsv
```

**Run InterProScan protein domain analysis:**
```bash
# On the machine where InterProScan is installed:
interproscan.sh -i proteins.fa -f tsv -o proteins_interpro.tsv

# Capture the InterProScan version (optional but recommended)
interproscan.sh -version > interproscan.version
```

**Parse InterProScan results:**
```bash
# If you have the interproscan.version file in the same directory:
perl parsers/parse_InterProScan_to_MOOP_TSV.pl proteins_interpro.tsv

# Or if running on a different machine, provide version explicitly:
perl parsers/parse_InterProScan_to_MOOP_TSV.pl proteins_interpro.tsv --version 5.72-103.0

# If version cannot be determined, script will use 'none_provided' with a warning
```

This automatically generates multiple MOOP-format TSV files for different annotation types.

**Note:** If running InterProScan on one machine and parsing results on another:
1. On analysis machine: `interproscan.sh -version > interproscan.version`
2. Transfer both `proteins_interpro.tsv` and `interproscan.version` to parsing machine
3. Run parser: `perl parsers/parse_InterProScan_to_MOOP_TSV.pl proteins_interpro.tsv`

## End-to-End Workflow

A complete test workflow is available in `test_workflow.sh` that demonstrates:
1. GFF3 parsing to feature table
2. SQLite database creation
3. Feature loading
4. Annotation loading from multiple sources

**Quick test:**
```bash
cd /var/www/html/dbtools
./test_workflow.sh
```

This uses sample data in `test_data/` and outputs to `test_output/`.

## Scripts Overview

| Script | Purpose | Input | Output |
|--------|---------|-------|--------|
| `parse_GFF3_to_MOOP_TSV.pl` | Convert GFF3 to MOOP format | GFF3 + organisms.tsv | genes.tsv with headers |
| `parse_DIAMOND_to_MOOP_TSV.pl` | Convert DIAMOND output | tophit.tsv | *_homologs.moop.tsv |
| `parse_InterProScan_to_MOOP_TSV.pl` | Convert InterProScan output | iprscan.tsv | Multiple annotation files |
| `load_genes_sqlite.pl` | Load gene features into database | genes.tsv + organism.sqlite | Updated organism.sqlite |
| `load_annotations_sqlite.pl` | Load annotations into database | annotations.tsv + organism.sqlite | Updated organism.sqlite |
| `create_schema_sqlite.sql` | Database schema | - | organism.sqlite |

## Directory Structure

```
moop-dbtools/
├── README.md                    # This file
├── environment.yml              # Conda dependencies
├── test_workflow.sh             # Complete end-to-end example
├── create_schema_sqlite.sql     # Database schema with comments
├── parsers/                     # Parsing scripts
│   ├── parse_GFF3_to_MOOP_TSV.pl
│   ├── parse_DIAMOND_to_MOOP_TSV.pl
│   └── parse_InterProScan_to_MOOP_TSV.pl
├── loaders/                     # Database loading scripts
│   ├── load_genes_sqlite.pl
│   └── load_annotations_sqlite.pl
├── analysis/                    # Example analysis workflows
│   ├── download_uniprot_sprot.sh
│   ├── format_uniprot_db.sh
│   ├── run_diamond_vs_uniprot_sprot.sh
│   ├── download_ensembl_human.sh
│   ├── format_ensembl_human_db.sh
│   ├── run_diamond_vs_ensembl_human.sh
│   └── run_interproscan.sh
├── docs/                        # Detailed documentation
│   ├── DATABASE_LOADING.md
│   └── ANALYSIS_AND_PARSING.md
├── test_data/                   # Sample data for testing
│   ├── organisms.tsv
│   ├── genomic.gff3
│   ├── protein.aa.fa
│   ├── ENS_homo_sapiens.tophit.tsv
│   ├── UNIPROT_sprot.tophit.tsv
│   └── iprscan_results.tsv
└── test_output/                 # Output from test workflow (gitignored)
```

## Requirements

All installed in the conda environment:
- Perl 5.10+
- DBI module
- DBD::SQLite module  
- DIAMOND sequence search tool (optional - for homolog searches)
- InterProScan (optional - for protein domain analysis)

## Deactivating the Environment

When done:

```bash
mamba deactivate
```

## Contributing

For issues or improvements, please open an issue or pull request.