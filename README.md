# bacterial-genomics-pipelines

Bash scripts I use for bacterial whole-genome sequencing at the University of Bern (Institute of
Veterinary Bacteriology and Institute for Infectious Diseases). They take Illumina, Oxford Nanopore
or PacBio reads through QC, assembly, assembly QC, annotation, typing and resistance gene
detection, and comparative genomics.

Each script works on a folder of input files, runs one tool per sample and writes one output folder
per sample. The tool version is written in the header of each script. They run on Linux with one
conda environment per tool, on a workstation or on the UBELIX SLURM cluster.

## Layout

### 01_read_qc
| Script | Tool | Purpose |
|---|---|---|
| `fastqc.sh` | FastQC 0.12.1 | Read quality report (Illumina) |
| `trimmomatic.sh` | Trimmomatic 0.39 | Adapter and quality trimming (Illumina) |
| `porechop.sh` | Porechop 0.2.4 | Adapter removal (Nanopore) |
| `filtlong.sh` | Filtlong 0.2.1 | Length and quality filtering (long reads) |
| `host_decontamination.sh` | minimap2 2.30, samtools 1.22.1 | Removal of host reads from Nanopore data |

### 02_assembly
| Script | Tool | Purpose |
|---|---|---|
| `unicycler_spades.sh` | Unicycler 0.5.1, SPAdes 4.2.0 | Short-read and hybrid assembly |
| `hybrid_assembly_pipeline.sh` | Unicycler, Polypolish 0.6.0, Pypolca 0.3.1 | Hybrid assembly followed by one round of polishing |
| `longread_assembly_pipeline.sh` | Flye 2.9.6, Racon 1.5.0, Medaka 2.1.0 | Long-read assembly and polishing |

### 03_assembly_qc
| Script | Tool | Purpose |
|---|---|---|
| `quast.sh` | QUAST 5.3.0 | Assembly metrics and coverage with Illumina reads |
| `quast_nanopore.sh` | QUAST 5.3.0 | Same, with Nanopore reads |
| `busco.sh` | BUSCO 6.0.0 | Gene completeness |
| `checkm.sh` | CheckM 1.2.4 | Completeness and contamination |

### 04_annotation
| Script | Tool | Purpose |
|---|---|---|
| `bakta.sh` | Bakta 1.11.3 | Genome annotation |
| `prokka.sh` | Prokka 1.14.6 | Genome annotation (alternative) |

### 05_typing_amr
| Script | Tool | Purpose |
|---|---|---|
| `mlst.sh` | MLST (CGE) 2.0.9 | Sequence typing |
| `amrfinder.sh` | AMRFinderPlus 4.0.24 | Resistance genes and point mutations |
| `resfinder.sh` | ResFinder 4.7.2 | Acquired resistance genes, PointFinder, DisinFinder |
| `plasmidfinder.sh` | PlasmidFinder 2.1.6 | Plasmid replicons |
| `blast.sh` | BLAST 2.16.0 | Searches against a local plasmid database (PLSDB) |

### 06_comparative_genomics
| Script | Tool | Purpose |
|---|---|---|
| `snippy_reads.sh` | Snippy 4.6.0 | SNP calling from reads against a reference |
| `snippy_contigs.sh` | Snippy 4.6.0 | SNP calling from assemblies against a reference |
| `snippy_core-genome.sh` | snippy-core, Gubbins 3.4, snp-sites, snp-dists, IQ-TREE | Core-genome alignment, recombination removal, SNP distance matrix and tree |
| `syri.sh` | SyRI 1.7.1 | Synteny and structural rearrangements between two genomes |

## Setup

1. Create the conda environment named at the top of each script (for example `bakta_env`,
   `snippy_env`, `amrfinder_env`).
2. Download the databases and point the scripts to them:
   ```bash
   cp config/databases.example.sh config/databases.sh   # then edit DB_DIR
   source config/databases.sh
   ```
3. Put the input files in the folder named at the top of the script (for example `INPUT/`),
   check the thread number, and run it:
   ```bash
   bash 04_annotation/bakta.sh
   ```

The two assembly pipelines (`hybrid_assembly_pipeline.sh`, `longread_assembly_pipeline.sh`) call
step scripts from a `Pipeline_scripts/` folder in the working directory (`unicycler_step.sh` or
`flye_assembly_step.sh`, then `polishing_step.sh`). These step scripts are not in this repository.

## Where these scripts were used

- Complete genomes from hybrid short- and long-read assemblies, including *Paenimyroides ceti*
  MC-ZM-24 with a new subclass B1 metallo-β-lactamase (J Glob Antimicrob Resist, 2026)
- Description of *Macrococcus animalis* sp. nov. and *Macrococcus equi* sp. nov. (Int J Syst Evol Microbiol, 2025)
- Clonal dissemination of methicillin-resistant Staphylococcaceae between sheep farms (J Glob Antimicrob Resist, 2025)

Full publication list on [PubMed](https://pubmed.ncbi.nlm.nih.gov/?term=chahrazed+belhout).

## Related repositories

- [somatic-tn](https://github.com/Chahrabel23/somatic-tn): tumour-normal somatic variant pipeline for NGS panels (Snakemake)
- [microbiome-16S-analysis](https://github.com/Chahrabel23/microbiome-16S-analysis): 16S rRNA analysis in R (DADA2, phyloseq, DESeq2)

## Credits

`quast.sh` and `snippy_core-genome.sh` were written by a lab colleague (initials ECM in the script
header). All other scripts are mine.

## Licence

MIT
