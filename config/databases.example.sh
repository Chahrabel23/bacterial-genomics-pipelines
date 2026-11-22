# Copy to config/databases.sh, set the path, then load it before running a script:
#   source config/databases.sh
#
# Expected layout under DB_DIR:
#   bakta_db/                      Bakta database
#   busco_db/busco_downloads/      BUSCO lineages
#   CGE_dbs/mlst_db/               MLST (CGE)
#   CGE_dbs/resfinder_db/          ResFinder
#   CGE_dbs/pointfinder_db/        PointFinder
#   CGE_dbs/disinfinder_db/        DisinFinder
#   CGE_dbs/plasmidfinder_db/      PlasmidFinder
#   plsdb_local/plsdb_local        BLAST database (PLSDB)
#   Illumina_adapters/             adapter files for Trimmomatic
#   Reference_genomes/             host genomes for decontamination
#
# Without this file the scripts use the lab path /home/labuser/WGS/Databases.

export DB_DIR=/path/to/Databases
