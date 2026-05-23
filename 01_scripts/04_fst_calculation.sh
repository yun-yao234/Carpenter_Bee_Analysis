#!/bin/bash

#SBATCH --job-name=04_woodbee_fst
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/04_fst_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/04_fst_%j.err

# ==============================================================================
# Script: 04_fst_calculation.sh
# Author: Yifei Xu
# Description: 
#   Phase 4 of the pipeline. Calculates the Fixation Index (Fst) using sliding 
#   windows (100kb window, 10kb step) to evaluate genetic differentiation.
#
# Input : Joint BCF variants & Population text files (03_results/03_snp_matrix/)
# Output : Fst sliding window statistics (03_results/04_fst_results/)
# ==============================================================================

module purge
module load vcftools

BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
IN_DIR="${BASE_DIR}/03_results/03_snp_matrix"
OUT_DIR="${BASE_DIR}/03_results/04_fst_results"

mkdir -p "$OUT_DIR"

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Phase 4: Commencing Fst Sliding Window Analysis"
echo "----------------------------------------------------------"

# NOTE: pop_*.txt files must manually exist in the IN_DIR containing sample IDs.
BCF_FILE="${IN_DIR}/woodbee_variants.bcf"
POP_BJ="${IN_DIR}/pop_beijing.txt"
POP_SZ_SHANGFANG="${IN_DIR}/pop_sz_shangfang.txt"
POP_SZ_SITE2="${IN_DIR}/pop_sz_site2.txt"

if [ ! -f "$POP_BJ" ] || [ ! -f "$POP_SZ_SHANGFANG" ]; then
    echo "[ERROR] Population definition files missing in ${IN_DIR}."
    echo "[ERROR] Please create pop_*.txt files before running Phase 4."
    exit 1
fi

cd "$OUT_DIR" || exit

# --- Comparison 1: Beijing vs Suzhou Shangfang ---
echo "[RUN] Calculating Fst: Beijing vs Suzhou Shangfang..."
vcftools --bcf "$BCF_FILE" \
    --weir-fst-pop "$POP_BJ" \
    --weir-fst-pop "$POP_SZ_SHANGFANG" \
    --fst-window-size 100000 \
    --fst-window-step 10000 \
    --out "BJ_vs_SZ_Shangfang"

# --- Comparison 2: Beijing vs Suzhou Site 2 ---
echo "[RUN] Calculating Fst: Beijing vs Suzhou Site 2..."
vcftools --bcf "$BCF_FILE" \
    --weir-fst-pop "$POP_BJ" \
    --weir-fst-pop "$POP_SZ_SITE2" \
    --fst-window-size 100000 \
    --fst-window-step 10000 \
    --out "BJ_vs_SZ_Site2"

# --- Comparison 3: Suzhou Shangfang vs Suzhou Site 2 ---
echo "[RUN] Calculating Fst: Suzhou Shangfang vs Suzhou Site 2..."
vcftools --bcf "$BCF_FILE" \
    --weir-fst-pop "$POP_SZ_SHANGFANG" \
    --weir-fst-pop "$POP_SZ_SITE2" \
    --fst-window-size 100000 \
    --fst-window-step 10000 \
    --out "SZ_Internal_Compare"

echo "----------------------------------------------------------"
echo "[$(date)] Phase 4 Completed. Fst statistics generated successfully."
echo "----------------------------------------------------------"
