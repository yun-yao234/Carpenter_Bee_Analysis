#!/bin/bash

#SBATCH --job-name=05_woodbee_pca
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=04:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/05_pca_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/05_pca_%j.err

# ==============================================================================
# Script: 05_pca_analysis.sh
# Author: Yifei Xu (Student ID: 2144638)
# Description: 
#   Phase 5 of the pipeline. Performs Principal Component Analysis (PCA) to
#   visualize population clusters for Xylocopa appendiculata.
#   It converts BCF format to PLINK format and calculates the top 10 PCs.
#
# Input: Joint BCF variants (03_results/03_snp_matrix/)
# Output: Eigenvectors and Eigenvalues (03_results/05_pca_results/)
# ==============================================================================

# Load necessary modules
module purge
module load vcftools
module load plink

# --- Absolute Path Definitions ---
BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
IN_DIR="${BASE_DIR}/03_results/03_snp_matrix"
INTER_DIR="${BASE_DIR}/02_intermediate"
OUT_DIR="${BASE_DIR}/03_results/05_pca_results"

# Ensure output directory exists
mkdir -p "$OUT_DIR"

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Phase 5: Commencing PCA Analysis"
echo "----------------------------------------------------------"

# --- Action 1: Convert BCF to PLINK format (.map/.ped) ---
# Using vcftools to bridge the gap between BCF and PLINK
echo "[RUN] Converting BCF to PLINK format..."
vcftools --bcf "${IN_DIR}/woodbee_variants.bcf" \
    --plink \
    --out "${INTER_DIR}/woodbee_for_pca"

# --- Action 2: Run PCA calculation via PLINK ---
# Note: --allow-extra-chr is required for non-standard chromosome names (e.g., GCA_049 scaffolds)
echo "[RUN] Calculating top 10 Principal Components..."
plink --file "${INTER_DIR}/woodbee_for_pca" \
    --pca 10 \
    --allow-extra-chr \
    --out "${OUT_DIR}/woodbee_pca_result"

echo "----------------------------------------------------------"
echo "[$(date)] Phase 5 Completed. Results generated in ${OUT_DIR}"
echo "----------------------------------------------------------"
