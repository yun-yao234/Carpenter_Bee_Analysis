#!/bin/bash

#SBATCH --job-name=03_woodbee_snp
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=72:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/03_snp_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/03_snp_%j.err

# ==============================================================================
# Script: 03_snp_calling.sh
# Author: Yifei Xu
# Description: 
#   Step 3 of the pipeline. Performs joint variant calling across all 17 host-
#   enriched samples using bcftools. Generates a raw BCF file and exports a 
#   human-readable genotype matrix for downstream population analysis.
#
# Input: Host-only BAMs from Step 2 & Optimal Reference (GCA_049).
# Output: Joint BCF variants and final genotype table (Results).
# ==============================================================================

module purge
module load samtools
module load bcftools

# --- Path Definitions ---
BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
REF="${BASE_DIR}/00_refs/GCA_049004755.1_ASM4900475v1_genomic.fna"
IN_BAM_DIR="${BASE_DIR}/02_intermediate"
RESULT_DIR="${BASE_DIR}/03_results/03_snp_matrix"
THREADS=16

mkdir -p "$RESULT_DIR"

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Step 03: Joint Variant Calling"
echo "----------------------------------------------------------"

# Step 3.1: Generate a list of all host-enriched BAM files
echo "[INFO] Compiling list of 17 host-enriched samples..."
cd "$IN_BAM_DIR" || exit
ls host_*.sorted.bam > "${RESULT_DIR}/sample_list.txt"

# Step 3.2: Joint Calling using mpileup and call
echo "[RUN] Executing bcftools mpileup & call for joint variant detection..."
bcftools mpileup --threads $THREADS -f "$REF" -b "${RESULT_DIR}/sample_list.txt" -Ou | \
bcftools call --threads $THREADS -mv -Ob -o "${RESULT_DIR}/woodbee_variants.bcf"

# Step 3.3: Export to human-readable genotype matrix
echo "[RUN] Exporting the final genotype matrix table..."
bcftools query -f '%CHROM\t%POS\t%REF[\t%TGT]\n' "${RESULT_DIR}/woodbee_variants.bcf" > "${RESULT_DIR}/final_genotype_table.txt"

echo "[$(date)] Step 03 Completed Successfully. Genotype matrix is ready!"
