#!/bin/bash
set -euo pipefail

################################################################################################################################################
# CB 22.11.2026

# QUAST v5.3.0

# Assembly QC report (draft or complete/hybrid assemblies) with QUAST, including read coverage from paired-end Illumina reads.
# NOTE: This script version uses Illumina reads. For Nanopore reads use quast_nanopore.sh

# IMPORTANT -- Assembly name and read names need to match!
# 	For example:
#	Assembly name: sample1.fna
#	Illumina reads: sample1_forward_paired.fastq.gz and sample1_reverse_paired.fastq.gz (Trimmomatic output)
#		Define below the read file endings!!

################################################################################################################################################

# Initialize Anaconda environmet
source ~/anaconda3/etc/profile.d/conda.sh
conda activate quast_env

# Define threads
threads="18"

# Define input and output folders
assembly_folder="INPUT_assembly"
read_folder="INPUT_reads"
output_folder="Quast_report"
mkdir -p "$output_folder"

# Illumina paired-end read endings (include underscore _)
END1="_forward_paired.fastq.gz"
END2="_reverse_paired.fastq.gz"

################################################################################################################################################
# Do not modify below!
################################################################################################################################################

# Main
for assembly in "$assembly_folder"/*.{fasta,fna,fa}; do
	# Check if assembly file is there
	[[ -e "$assembly" ]] || continue
	# Generate sample name
	sample_name=$(basename "$assembly")
	sample_name="${sample_name%.*}"
	# Get Illumina reads
	read1="$read_folder/${sample_name}${END1}"
	read2="$read_folder/${sample_name}${END2}"
	# If both reads exist then run QUAST
	if [[ -f "$read1" && -f "$read2" ]]; then
		echo "Running QUAST using Illumina reads on sample: $sample_name with $threads threads.."
		quast -t "$threads" -o "$output_folder/$sample_name" --pe1 "$read1" --pe2 "$read2" "$assembly"
		# Append name to output report
		mv "$output_folder/$sample_name/transposed_report.txt" "$output_folder/$sample_name/${sample_name}_transposed_report.txt"
	else
		echo "Illumina reads for ${sample_name} not found (${END1} / ${END2}) ... Skipping sample!"
	fi
done
