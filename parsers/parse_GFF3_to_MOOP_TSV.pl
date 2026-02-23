#!/usr/bin/perl
use strict;
use warnings;

sub usage {
    my ($msg) = @_;
    print STDERR "ERROR: $msg\n" if $msg;
    print STDERR <<'EOF';
Usage: parse_GFF3_to_MOOP_TSV.pl <genomic.gff3> <organisms.tsv> <genus> <species> <genome-accession>

Required arguments:
  genomic.gff3        GFF3 format annotation file (NOT GFF2)
  organisms.tsv       Organisms metadata TSV file
  genus               Organism genus (used to match organisms.tsv)
  species             Organism species (used to match organisms.tsv)
  genome-accession    Genome accession ID (used to match organisms.tsv)

organisms.tsv format (tab-delimited):
  Required columns (exact names): genus, species, genome-accession, ncbi-taxon-id, feature-types
  feature-types: comma-separated list (e.g., "mRNA,gene")
  Optional: common-name (defaults to "Genus species"), genome-name (defaults to genome-accession), 
            genome-source, details, and other metadata

Output:
  STDOUT containing gene features in MOOP format with metadata headers

Example:
  perl parse_GFF3_to_MOOP_TSV.pl genomic.gff3 organisms.tsv Chamaeleo calyptratus CCA3 > genes.tsv
EOF
    exit 1;
}

# Validate arguments
usage("Missing required arguments") unless @ARGV == 5;

my $gff = shift;
my $organisms_tsv = shift;
my $target_genus = shift;
my $target_species = shift;
my $target_accession = shift;

# Validate input files exist
usage("GFF file does not exist: $gff") unless -e $gff;
usage("GFF file is not readable: $gff") unless -r $gff;
usage("Organisms TSV file does not exist: $organisms_tsv") unless -e $organisms_tsv;
usage("Organisms TSV file is not readable: $organisms_tsv") unless -r $organisms_tsv;

# Read organisms metadata from TSV file
my %metadata;
open METADATA, $organisms_tsv or die "Can't open organisms metadata TSV file $! \n";

my $header_line = <METADATA>;
chomp $header_line;
$header_line =~ s/\r$//;
my @headers = split "\t", $header_line;

# Find required column indices
my ($genus_idx, $species_idx, $accession_idx, $taxon_idx);
for (my $i = 0; $i < @headers; $i++){
  $genus_idx = $i if $headers[$i] eq 'genus';
  $species_idx = $i if $headers[$i] eq 'species';
  $accession_idx = $i if $headers[$i] eq 'genome-accession';
  $taxon_idx = $i if $headers[$i] eq 'ncbi-taxon-id';
}

die "Required columns not found in $organisms_tsv (need: genus, species, genome-accession, ncbi-taxon-id)\n" 
  unless defined($genus_idx) && defined($species_idx) && defined($accession_idx) && defined($taxon_idx);

while (my $line = <METADATA>){
  chomp $line;
  $line =~ s/\r$//;
  my @cols = split "\t", $line;
  
  if ($cols[$genus_idx] eq $target_genus && $cols[$species_idx] eq $target_species && $cols[$accession_idx] eq $target_accession){
    for (my $i = 0; $i < @headers; $i++){
      $metadata{$headers[$i]} = $cols[$i] // '';
    }
    last;
  }
}
close METADATA;

if (!$metadata{genus}){
  usage("Organism not found: genus=$target_genus, species=$target_species, accession=$target_accession not found in $organisms_tsv");
}

my $genus = $metadata{genus} // '';
my $species = $metadata{species} // '';
my $commonname = $metadata{'common-name'} // '';
my $taxon_id = $metadata{'ncbi-taxon-id'} // '';
my $genome_accession = $metadata{'genome-accession'} // '';
my $genome_name = $metadata{'genome-name'} // '';
my $source = $metadata{'genome-source'} // '';
my $details = $metadata{details} // '';
my $feature_types_str = $metadata{'feature-types'} // '';

# Use fallback values if not provided
$commonname = "$genus $species" if !$commonname;
$genome_name = $genome_accession if !$genome_name;

if (!$feature_types_str){
  usage("Feature types not specified: feature-types column missing or empty for genus=$target_genus, species=$target_species, accession=$target_accession");
}

my @types = split ',', $feature_types_str;
@types = map { s/^\s+|\s+$//g; $_ } @types;

print "## Genus: $genus\n";
print "## Species: $species\n";
print "## Common Name: $commonname\n";
print "## NCBI Taxon ID: $taxon_id\n";
print "## Genome Accession: $genome_accession\n";
print "## Genome Name: $genome_name\n";
print "## Genome Description: Assembly is from $source. $details\n";
print "## This_Uniquename\tThis_Type\tParent_Uniquename\tParent_Type\tThis_Name\tThis_Description\n";

my %types; 
foreach my $type (@types){
  $types{$type}=1;
}

my %feature_types;
open GFF, $gff or die "Can't open GFF $! \n";
while (my $line = <GFF>){
  chomp $line;
  next if $line =~ /^#/;
  my ($ref,$src,$type,$score,$strand,$phase,$nine) = split "\t", $line;  
  my ($id) = $line =~ /ID=([^;]+)/;
  my $parent_id = '';
  my $parent_type = '';

  $feature_types{$id}=$type;

  if ($line =~ /Parent=/){
    ($parent_id) = $line =~ /Parent=([^;]+)/;
    $parent_type = $feature_types{$parent_id};
  }

  if (exists $types{$type}){
    my $name = $id;
    if ($line =~ /Name=([^;]+)/){
     $name = $1;
    }
    my $note = $id;
    if ($line =~ /Note=([^;]+)/){
     $note = $1;
    }
    print join("\t",$id,$type,$parent_id,$parent_type,$name,$note),"\n";
  }
}


