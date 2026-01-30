# Annotation Types Reference

This document describes the standard annotation types used in MOOP and how to structure your analysis output to work with the MOOP database system.

## Overview

Annotation types define the categories of biological information imported into MOOP databases. Each annotation type has a specific structure and set of metadata that allows MOOP to organize, display, and query annotations consistently across the application.

When you parse analysis results (DIAMOND, InterProScan, GO, etc.), your output should follow the MOOP format to be compatible with the import system.

## Standard Annotation Types

The following annotation types are commonly used in MOOP:

### Orthologs
- **Color:** Primary (blue)
- **Description:** Homologous genes separated in evolution by speciation events. Orthologs represent genes in different species that evolved from a common ancestral gene.
- **Typical Source:** OrthoMCL, Ensembl Compara, or custom orthology analysis
- **Common Synonyms:** Orthology

### Homologs
- **Color:** Info (cyan)
- **Description:** Homologous genes in general, including both orthologs (separated by speciation) and paralogs (separated by gene duplication). This is the broader category.
- **Typical Source:** Sequence similarity searches, custom homology analysis

### Domains
- **Color:** Success (green)
- **Description:** Protein domains are conserved structural and functional units. Domain annotations identify these conserved regions using standard databases.
- **Typical Source:** InterProScan, Pfam, SMART, InterPro
- **Common Synonyms:** Protein Domains

### Gene Ontology
- **Color:** Warning (yellow)
- **Description:** Gene Ontology (GO) provides controlled vocabulary describing gene products in terms of biological processes, cellular components, and molecular functions.
- **Typical Source:** InterProScan (includes GO mappings), GO annotation files, UniProt
- **GO Categories:**
  - Biological Process (BP)
  - Cellular Component (CC)
  - Molecular Function (MF)

### Gene Families
- **Color:** Danger (red)
- **Description:** Groups of genes sharing similar sequences and functions, typically arising from gene duplication events.
- **Typical Source:** PANTHER, TreeFam, Ensembl gene trees, custom clustering

### AI Annotations
- **Color:** Purple
- **Description:** AI-based protein function predictions using machine learning and protein sequence language models to infer biological roles from sequences.
- **Typical Source:** ProtNLM, ESMPLFold, other neural network-based predictors
- **Common Synonyms:** ProtNLM

### Mapping
- **Color:** Secondary (gray)
- **Description:** Genomic mapping information including chromosomal locations, genetic markers, and physical positions of genes.
- **Typical Source:** Genome assembly files, linkage maps, QTL analysis

### Aliases
- **Color:** Secondary (gray)
- **Description:** Alternative names and identifiers for genes and gene products from various databases and nomenclature systems.
- **Typical Source:** UniProt, NCBI, species-specific databases

### Publications
- **Color:** Dark
- **Description:** Scientific literature and publications associated with genes, including references from PubMed and other sources.
- **Typical Source:** PubMed, Europe PMC, literature mining tools

## Creating Custom Analysis Output

To create annotation output compatible with MOOP, follow this format:

### Required Format

TSV file with metadata header followed by tab-delimited columns:

```
# MOOP Annotation Format
# annotation_type: [Type Name]
# analysis_tool: [Tool Name]
# analysis_version: [Version]
# annotation_description: [Optional description]

feature_uniquename	annotation_accession	annotation_description	score
```

### Column Structure

| Column | Description | Example |
|--------|-------------|---------|
| `feature_uniquename` | Unique identifier matching the feature in genes.tsv (first column) | `AT1G01010` |
| `annotation_accession` | Unique ID for this annotation hit from the source database | `GO:0008150` |
| `annotation_description` | Human-readable description of the annotation | `Biological process` |
| `score` | Numerical score or categorical value (e.g., e-value, confidence, namespace) | `0.001` or `cellular_component` |

### Metadata Header Rules

The first few lines of your TSV file MUST include:
- `# MOOP Annotation Format` - Identifies the file format
- `# annotation_type:` - The type of annotation (from the list above or custom)
- `# analysis_tool:` - Name of the analysis tool used
- `# analysis_version:` - Version of the analysis tool
- `# annotation_description:` (optional) - Brief description of the analysis

Example:
```
# MOOP Annotation Format
# annotation_type: Gene Ontology
# analysis_tool: InterProScan
# analysis_version: 5.61-92.0
# annotation_description: Gene Ontology annotations from InterProScan

feature_uniquename	GO_ID	GO_DESCRIPTION	NAMESPACE
AT1G01010	GO:0008150	biological_process	biological_process
AT1G01010	GO:0005575	cellular_component	cellular_component
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
            "color": "warning",
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
- `color` - Bootstrap color class for UI elements
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
