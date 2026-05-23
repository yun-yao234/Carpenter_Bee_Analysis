#!/bin/bash

#SBATCH --job-name=02_host_filter
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/02_filter_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/02_filter_%j.err

# ==============================================================================
# Script: 02_host_filtering.sh
# Author: Yifei Xu
# Description: 
#   Step 2 of the pipeline. Filters out unmapped reads (environmental noise)
#   using 'samtools view -F 4' to enrich host genomic data based on the optimal 
#   reference (GCA_049).
#
# Input: Sorted BAMs from Step 1 (*_GCA_049.sorted.bam).
# Output: Host-only BAMs (Intermediate) and summaries (Results).
# ==============================================================================

module purge
module load samtools

BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
IN_DIR="${BASE_DIR}/02_intermediate"
RESULT_DIR="${BASE_DIR}/03_results/02_filtered_summaries"
THREADS=8

mkdir -p "$RESULT_DIR"

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Step 02: Commencing Host Data Enrichment"
echo "----------------------------------------------------------"

# Target only the optimal reference alignment files
for in_bam in ${IN_DIR}/*_GCA_049.sorted.bam; do
    [ -f "$in_bam" ] || continue
    
    fname=$(basename "$in_bam")
    sample="${fname%_GCA_049.sorted.bam}"
    host_bam="${IN_DIR}/host_${sample}.sorted.bam"
    summary_txt="${RESULT_DIR}/${sample}_host_summary.txt"

    # Robustness Check: Skip if file is already processed and valid (>100MB)
    if [ -f "$host_bam" ]; then
        fsize=$(du -k "$host_bam" | cut -f1)
        if [ "$fsize" -gt 102400 ]; then
            echo "[SKIP] ${sample} already filtered. Skipping."
            continue
        fi
        rm -f "$host_bam"
    fi

    echo "[RUN] Extracting host reads for ${sample}..."
    samtools view -@ $THREADS -b -F 4 "$in_bam" -o "$host_bam"
    
    if [ -s "$host_bam" ]; then
        echo "[SUCCESS] Building index and generating summary for ${sample}"
        samtools index -@ $THREADS "$host_bam"
        samtools flagstat -@ $THREADS "$host_bam" > "$summary_txt"
    else
        echo "[ERROR] Failed to process ${sample}"
    fi
done

echo "[$(date)] Step 02 Completed Successfully."