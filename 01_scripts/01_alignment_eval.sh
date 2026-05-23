#!/bin/bash

#SBATCH --job-name=01_align_eval
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/01_align_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/01_align_%j.err

# ==============================================================================
# Script: 01_alignment_eval.sh
# Author: Yifei Xu
# Description: 
#   Step 1 of the pipeline. Evaluates 4 candidate reference genomes by aligning
#   clean WGS reads from 17 samples across 3 sequencing batches.
#
# Input: Clean PE Fastq files from MINTANG lab sources.
# Output: Sorted BAMs (Intermediate) and flagstat reports (Results).
# ==============================================================================

module purge
module load bwa
module load samtools

# --- Path Definitions ---
BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
REF_DIR="${BASE_DIR}/00_refs"
BAM_DIR="${BASE_DIR}/02_intermediate"
STATS_DIR="${BASE_DIR}/03_results/01_mapping_stats"
THREADS=8

mkdir -p "$BAM_DIR" "$STATS_DIR"

# --- Raw Data Batches ---
DATA_DIRS=(
    "/gpfs/work/bio/mintang/data/30wildbee_2019Bj-Yn/00.cleaned"
    "/gpfs/work/bio/mintang/data/SuzhouWildBeeGut202311_3rd/00.cleanData"
    "/gpfs/work/bio/mintang/data/SuzhouWildBee5th202405/00.QC"
)

# --- Candidate Genomes ---
REFERENCES=(
    "GCA_049004755.1_ASM4900475v1_genomic.fna"
    "GCA_051362155.1_iyXylVirg4_p1.fna"
    "GCA_963969225.2_iyXylViol4.fna"
    "GCF_050948175.1_iyXylSono1_principal_genomic.fna"
)

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Start: Global Alignment Evaluation"
echo "----------------------------------------------------------"

for d_dir in "${DATA_DIRS[@]}"; do
    echo "[INFO] Scanning directory: $d_dir"
    for r1 in ${d_dir}/*clean.1.fq.gz; do
        [ -f "$r1" ] || continue
        
        r2="${r1/.clean.1.fq.gz/.clean.2.fq.gz}"
        fname=$(basename "$r1")
        sample="${fname%%.*}"

        for ref in "${REFERENCES[@]}"; do
            ref_id=$(echo "$ref" | cut -d'_' -f1,2)
            out_bam="${BAM_DIR}/${sample}_${ref_id}.sorted.bam"
            out_stats="${STATS_DIR}/${sample}_${ref_id}_stats.txt"

            if [ -s "$out_stats" ]; then
                echo "[SKIP] Stats already exist for ${sample} on ${ref_id}"
                continue
            fi

            echo "[RUN] Aligning ${sample} to ${ref_id}..."
            bwa mem -t $THREADS "${REF_DIR}/${ref}" "$r1" "$r2" | \
            samtools sort -@ $THREADS -o "$out_bam" -
            
            samtools index -@ $THREADS "$out_bam"
            samtools flagstat -@ $THREADS "$out_bam" > "$out_stats"
        done
    done
done

echo "[$(date)] Step 01 Completed Successfully."