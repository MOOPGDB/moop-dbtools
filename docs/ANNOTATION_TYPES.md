# Annotation Types Reference

This document describes the standard annotation types used in MOOP and how to structure your analysis output to work with the MOOP database system.

## Overview

Annotation types define the categories of biological information imported into MOOP databases. Each annotation type has a specific structure and set of metadata that allows MOOP to organize, display, and query annotations consistently across the application.

When you parse analysis results (DIAMOND, InterProScan, GO, etc.), your output should follow the MOOP format to be compatible with the import system.

## Standard Annotation Types

The following annotation types are commonly used in MOOP:

### Orthologs
- **Description:** Homologous genes separated in evolution by speciation events. Orthologs represent genes in different species that evolved from a common ancestral gene.
- **Typical Source:** OrthoMCL, Ensembl Compara, or custom orthology analysis
- **Common Synonyms:** Orthology

### Homologs
- **Description:** Homologous genes in general, including both orthologs (separated by speciation) and paralogs (separated by gene duplication). This is the broader category.
- **Typical Source:** Sequence similarity searches, custom homology analysis

### Domains
- **Description:** Protein domains are conserved structural and functional units. Domain annotations identify these conserved regions using standard databases.
- **Typical Source:** InterProScan, Pfam, SMART, InterPro
- **Common Synonyms:** Protein Domains

### Gene Ontology
- **Description:** Gene Ontology (GO) provides controlled vocabulary describing gene products in terms of biological processes, cellular components, and molecular functions.
- **Typical Source:** InterProScan (includes GO mappings), GO annotation files, UniProt
- **GO Categories:**
  - Biological Process (BP)
  - Cellular Component (CC)
  - Molecular Function (MF)

### Gene Families
- **Description:** Groups of genes sharing similar sequences and functions, typically arising from gene duplication events.
- **Typical Source:** PANTHER, TreeFam, Ensembl gene trees, custom clustering

### AI Annotations
- **Description:** AI-based protein function predictions using machine learning and protein sequence language models to infer biological roles from sequences.
- **Typical Source:** ProtNLM, ESMPLFold, other neural network-based predictors
- **Common Synonyms:** ProtNLM

### Mapping
- **Description:** Genomic mapping information including chromosomal locations, genetic markers, and physical positions of genes.
- **Typical Source:** Genome assembly files, linkage maps, QTL analysis

### Aliases
- **Description:** Alternative names and identifiers for genes and gene products from various databases and nomenclature systems.
- **Typical Source:** UniProt, NCBI, species-specific databases

### Publications
- **Description:** Scientific literature and publications associated with genes, including references from PubMed and other sources.
- **Typical Source:** PubMed, Europe PMC, literature mining tools

## Creating Custom Analysis Output

To create annotation output compatible with MOOP, follow this format:

### Required Format

TSV file with metadata header followed by tab-delimited columns:

```
## Annotation Source: [Source Name]
## Annotation Source Version: [Version]
## Annotation Source URL: [Homepage URL]
## Annotation Accession URL: [Record Lookup URL]
## Annotation Type: [Type Name]
## Annotation Creation Date: [YYYY-MM-DD]
## Gene	Accession	Accession_Description	Score
```

### Column Structure

| Column | Description | Example |
|--------|-------------|---------|
| `Gene` | Gene/protein identifier from your dataset | `PROTEIN_001` |
| `Accession` | Unique ID for this annotation hit from the source database | `Q9BWM5` |
| `Accession_Description` | Human-readable description of the annotation | `Zinc finger protein 416` |
| `Score` | Numerical score or categorical value (e.g., e-value, confidence, namespace) | `3.94e-110` |

### Metadata Header Rules

The first few lines of your TSV file MUST include:
- `## Annotation Source:` - Name of the source database
- `## Annotation Source Version:` - Version or release date of the source
- `## Annotation Source URL:` - Homepage URL for the database
- `## Annotation Accession URL:` - URL prefix for individual record lookup
- `## Annotation Type:` - The type of annotation (Homologs, Domains, Gene Ontology, etc.)
- `## Annotation Creation Date:` - Date the annotation file was created (YYYY-MM-DD)

Example:
```
## Annotation Source: UniProtKB/Swiss-Prot
## Annotation Source Version: 2024.01
## Annotation Source URL: https://www.uniprot.org
## Annotation Accession URL: https://www.uniprot.org/uniprotkb/
## Annotation Type: Homologs
## Annotation Creation Date: 2025-06-17
## Gene	Accession	Accession_Description	Score
PROTEIN_001	Q9BWM5	Zinc finger protein 416	3.94e-110
PROTEIN_002	Q16342	Programmed cell death protein 2	2.04e-210
```

## Parsing Script Examples

### DIAMOND to MOOP Format

Use `parse_DIAMOND_to_MOOP_TSV.pl` to convert DIAMOND output:

```bash
perl parse_DIAMOND_to_MOOP_TSV.pl \
  diamond_output.tsv \
  uniprot_swissprot.version \
  > homologs.tsv
```

### InterProScan to MOOP Format

Use `parse_InterProScan_to_MOOP_TSV.pl` to convert InterProScan output:

```bash
perl parse_InterProScan_to_MOOP_TSV.pl \
  interproscan_output.tsv \
  interproscan.version \
  > domains.tsv
```

### GFF3 to Feature Table

Use `parse_GFF3_to_MOOP_TSV.pl` to create the initial feature table from GFF3:

```bash
perl parse_GFF3_to_MOOP_TSV.pl \
  genomic.gff3 \
  organisms.tsv \
  > features.tsv
```

## Loading Annotations into MOOP

Once your annotation TSV file is properly formatted:

```bash
perl load_annotations_sqlite.pl \
  -db /path/to/organism.sqlite \
  -tsv annotations.tsv
```

The loader will:
1. Read the metadata header to determine annotation type and version
2. Validate the format
3. Parse the feature_uniquename column to match against existing features
4. Import annotation data into the `annotation` table
5. Create cross-references in the `feature_annotation` table

## Annotation Type Configuration

In the full MOOP installation, annotation types are configured in `metadata/annotation_config.json`. This file is generated automatically by the MOOP administration tool, which scans all organism databases to ensure annotation types are complete and consistent across your MOOP instance.

Example configuration structure:
```json
{
    "annotation_types": {
        "Gene Ontology": {
            "display_name": "Gene Ontology",
            "color": "yellow",
            "order": 5,
            "description": "Gene Ontology (GO) provides a controlled vocabulary...",
            "enabled": true,
            "in_database": true,
            "annotation_count": 143045,
            "feature_count": 129142,
            "synonyms": []
        }
    }
}
```

Fields:
- `display_name` - How the annotation type is displayed in the UI
- `color` - Color used for UI elements (e.g., blue, green, yellow, red, etc.)
- `order` - Display order (lower numbers appear first)
- `description` - Full HTML description for information panels
- `enabled` - Whether this type is active
- `in_database` - Whether annotations exist in any loaded database
- `annotation_count` - Total number of annotations of this type
- `feature_count` - Number of unique features with this annotation type
- `synonyms` - Alternative names for this annotation type (for import matching)

## Extending with Custom Annotations

You can add custom annotation types by:

1. Creating a properly formatted TSV file with your analysis output
2. Using the correct metadata headers
3. Loading it with `load_annotations_sqlite.pl`
4. The annotation type will automatically appear in the MOOP database

Custom annotation types will appear in the MOOP administration interface and can be managed alongside standard types.

## Best Practices

1. **Consistent naming:** Use clear, descriptive names for custom annotation types
2. **Version tracking:** Always include the analysis tool version in your TSV header
3. **Data validation:** Ensure feature_uniquename values match exactly with those in your genes.tsv file
4. **Score formats:** Choose meaningful scores (e-values, confidence levels, categories) that help users interpret results
5. **Documentation:** Include a README or notes about your custom annotation source

## Additional Resources

- See [ANALYSIS_AND_PARSING.md](./ANALYSIS_AND_PARSING.md) for detailed workflow examples
- Check individual parser script usage: `perl [script].pl --help`
- Review [DATABASE_LOADING.md](./DATABASE_LOADING.md) for loading strategies
