#!/bin/bash
set -euo pipefail

################################################################################################################################################
# CB 22.11.2026

# Snippy v4.6.0 (snippy-core), Gubbins v3.4, snp-sites v2.5.1, snp-dists v0.8.2, IQ-TREE v3.0.1

# Manual: https://github.com/tseemann/snippy

# Core-genome SNP analysis from the Snippy output of snippy_reads.sh or snippy_contigs.sh:
# 1) snippy-core: core-genome alignment of all samples against the same reference
# 2) Gubbins: detection and removal of recombination
# 3) snp-sites: core SNP alignment (variable sites only)
# 4) snp-dists: pairwise SNP distance matrix
# 5) IQ-TREE: maximum-likelihood tree with ascertainment bias correction (+ASC) and 1000 ultrafast bootstraps

# IMPORTANT: Use the same reference genome as in the Snippy runs (Input_reference/).

# NOTES:
# Core genome size: see core.txt
# Recombination removed: compare the number of SNPs in core.tab with the number of sites in core_snps.aln
# If Gubbins fails with RAxML, set tree_builder="fasttree" below

################################################################################################################################################

# Initialize Anaconda environmet
source ~/anaconda3/etc/profile.d/conda.sh
conda activate snippy_env

# Snippy output folder to use (Snippy_reads_output or Snippy_contigs_output)
snippy_folder="Snippy_reads_output"

# Reference folder and output folder
input_reference_folder="Input_reference"
output_folder="Snippy_core-genome_output"
mkdir -p "$output_folder"

# Optional BED file of reference regions to mask (e.g. phages, repeats). Leave empty if not needed
mask_bed=""

# Gubbins tree builder (raxml or fasttree) and CPU threads
tree_builder="raxml"
threads=20

################################################################################################################################################
# Do not modify below!
################################################################################################################################################

# Reference sequence
ref_file=$(find "$input_reference_folder" -maxdepth 1 -type f \( -name "*.fa" -o -name "*.fna" -o -name "*.fasta" \) | head -n 1)
if [[ -z "$ref_file" ]]; then
	echo "No reference (*.fa, *.fna, *.fasta) found in $input_reference_folder ... Stopping!"
	exit 1
fi

# Sample folders from Snippy
samples=()
for dir in "$snippy_folder"/*/; do
	[[ -d "$dir" ]] && samples+=("${dir%/}")
done
if [[ ${#samples[@]} -lt 2 ]]; then
	echo "Need at least 2 Snippy sample folders in $snippy_folder ... Stopping!"
	exit 1
fi
echo "Reference: $ref_file"
echo "Samples: ${#samples[@]} folders in $snippy_folder"

# 1) Core-genome alignment
mask_option=()
[[ -n "$mask_bed" ]] && mask_option=(--mask "$mask_bed")
echo "Running snippy-core.."
snippy-core --ref "$ref_file" --prefix "$output_folder/core" ${mask_option[@]+"${mask_option[@]}"} "${samples[@]}"

# Replace ambiguous and masked characters with N before Gubbins
snippy-clean_full_aln "$output_folder/core.full.aln" > "$output_folder/core.clean.full.aln"

# 2) Recombination with Gubbins
echo "Running Gubbins ($tree_builder).."
run_gubbins.py --threads "$threads" --tree-builder "$tree_builder" --prefix "$output_folder/gubbins" "$output_folder/core.clean.full.aln"

# 3) Core SNP alignment without recombinant sites
snp-sites -c -o "$output_folder/core_snps.aln" "$output_folder/gubbins.filtered_polymorphic_sites.fasta"

# 4) SNP distance matrix
echo "Calculating SNP distances.."
snp-dists -b -c "$output_folder/core_snps.aln" > "$output_folder/SNP_distance_matrix.csv"

# 5) Maximum-likelihood tree
iqtree_bin=$(command -v iqtree3 || command -v iqtree2 || command -v iqtree)
echo "Running IQ-TREE ($iqtree_bin).."
"$iqtree_bin" -s "$output_folder/core_snps.aln" -m GTR+ASC -B 1000 -alrt 1000 -T AUTO --prefix "$output_folder/core_snps_tree"

echo "Done. Main results in $output_folder: core.txt, SNP_distance_matrix.csv, core_snps_tree.treefile"
