#!/bin/bash
#SBATCH --job-name=07_woodbee_flank
#SBATCH --partition=cpu8358
#SBATCH --qos=52cores
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/07_flank_%j.log
#SBATCH --error=/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis/05_logs/07_flank_%j.err

# ==============================================================================
# Script: 07_get_flanking_fasta.sh
# Author: Yifei Xu (Student ID: 2144638)
# Description: 
#   Phase 7 of the pipeline. Extracts symmetric 20,001 bp coordinate genomic windows
#   (10 kb upstream and 10 kb downstream) flanking candidate extreme divergent sites 
#   screened by tiered Delta-SSFV thresholds to capture complete target gene architectures.
#
# Input: Filtered candidate extreme BED profile (03_results/06_allele_frequency/)
#        Surrogate Reference Genome matrix template (00_refs/)
# Output: Target flanking sequence nucleotide matrix FASTA (03_results/07_flanking_sequences/)
# ==============================================================================

# Load precise computational module environment
module purge
module load bedtools2

# --- Absolute Path Definitions ---
BASE_DIR="/gpfs/work/bio/yifeixu21/Carpenter_Bee_Analysis"
IN_DIR="${BASE_DIR}/03_results/06_allele_frequency"
OUT_DIR="${BASE_DIR}/03_results/07_flanking_sequences"
REF_FASTA="${BASE_DIR}/00_refs/GCA_049004755.1_ASM4900475v1_genomic.fna"

# Note: Ensure your tiered multi-threshold screened candidate BED resides here
INPUT_BED="${IN_DIR}/final_fixed_sites_extreme.bed"

mkdir -p "${OUT_DIR}"
cd "${OUT_DIR}" || exit 1

echo "----------------------------------------------------------"
echo "[$(date)] Pipeline Phase 7: Commencing 10kb Flanking Sequence Extraction"
echo "----------------------------------------------------------"

# --- Action 1: Construct Symmetric Coordinate Windows Centered on Candidate SNPs ---
# Converts 1-based variant position coordinates from input BED (skipping header via NR>1) 
# into standard 0-based interval coordinates [pos-10001, pos+10000) for complete structures.
echo "[RUN] Constructing flanking genomic interval window boundaries (BED)..."
awk 'NR>1 && $2 ~ /^[0-9]+$/ {
    pos = $2;
    start = pos - 10001;
    if(start < 0) start = 0;
    print $1"\t"start"\t"pos+10000"\t"$1"_"pos
}' "${INPUT_BED}" > snp_flanking_10kb.bed

# Robustness Check: Abort process if the parsed coordinate template is empty
if [ ! -s snp_flanking_10kb.bed ]; then
    echo "[ERROR] Failed to construct flanking BED intervals or the template is empty!"
    exit 1
fi
echo "[INFO] Total genomic interval windows mapped: $(wc -l < snp_flanking_10kb.bed)"

# --- Action 2: Perform Fasta Subsequence Retrieval via Bedtools ---
echo "[RUN] Fetching specific nucleotide profiles from reference genome template fna..."
bedtools getfasta -fi "${REF_FASTA}" -bed snp_flanking_10kb.bed -name -fo target_snps_10kb.fasta

# Final Validation Check: Confirm output file viability
if [ -s target_snps_10kb.fasta ]; then
    echo "[SUCCESS] Extraction task accomplished. Total sequence structures fetched: $(grep -c '^>' target_snps_10kb.fasta)"
else
    echo "[ERROR] Target output fasta file is blank. Please review slurm logs."
    exit 1
fi

echo "----------------------------------------------------------"
echo "[$(date)] Phase 7 Completed. Flanking fasta structures exported to ${OUT_DIR}"
echo "----------------------------------------------------------"
