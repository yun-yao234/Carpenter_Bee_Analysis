#!/bin/bash
#SBATCH --job-name=06_woodbee_ssaf
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=04:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/06_ssaf_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/06_ssaf_%j.err

# ==============================================================================
# Script: 06_allele_frequency.sh
# Author: Yifei Xu (Student ID: 2144638)
# Description: 
#   Phase 6 of the pipeline. Calculates site-by-site frequency dynamics, specifically
#   the Site-Specific Allele Frequency (SSAF) / Site-Specific Frequency Value (SSFV),
#   across Beijing, Suzhou Shangfang Mountain, and Suzhou Site 2 populations.
#
# Input: Joint BCF variants & Population definition lists (03_results/03_snp_matrix/)
# Output: Site-by-site SSAF frequency profile matrices (03_results/06_allele_frequency/)
# ==============================================================================

# Load precise computational module environment
module purge
module load bcftools/1.16-gcc-8.5.0-vnk2pom

# --- Absolute Path Definitions ---
BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
SNP_DIR="${BASE_DIR}/03_results/03_snp_matrix"
OUT_DIR="${BASE_DIR}/03_results/06_allele_frequency"
BCF_FILE="${SNP_DIR}/woodbee_variants.bcf"

mkdir -p "${OUT_DIR}"

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Phase 6: Commencing SSAF/SSFV Frequency Calculation"
echo "----------------------------------------------------------"

# --- Action 1: Calculate SSAF for Beijing Population ---
echo "[RUN] Profiling site-specific allele frequencies for Beijing population..."
bcftools view -S "${SNP_DIR}/pop_beijing.txt" -Ou "${BCF_FILE}" | \
bcftools +fill-tags -- -t AF | \
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AF\n' > "${OUT_DIR}/beijing_freq.txt"

# --- Action 2: Calculate SSAF for Suzhou Shangfang Mountain Population ---
echo "[RUN] Profiling site-specific allele frequencies for Suzhou Shangfang Mountain population..."
bcftools view -S "${SNP_DIR}/pop_sz_shangfang.txt" -Ou "${BCF_FILE}" | \
bcftools +fill-tags -- -t AF | \
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AF\n' > "${OUT_DIR}/sz_shangfang_freq.txt"

# --- Action 3: Calculate SSAF for Suzhou Site 2 Population ---
echo "[RUN] Profiling site-specific allele frequencies for Suzhou Site 2 population..."
bcftools view -S "${SNP_DIR}/pop_sz_site2.txt" -Ou "${BCF_FILE}" | \
bcftools +fill-tags -- -t AF | \
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AF\n' > "${OUT_DIR}/sz_site2_freq.txt"

echo "----------------------------------------------------------"
echo "[$(date)] Phase 6 Completed. Frequency matrices exported to ${OUT_DIR}"
echo "----------------------------------------------------------"
