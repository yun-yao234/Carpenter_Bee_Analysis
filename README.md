# Genomic Characterization and Variation Analysis of Wild Xylocopa appendiculata Populations

**Module:** BIO319 | **Program:** BSc Bioinformatics
**Author:** Yifei Xu (Student ID: 2144638)
**Live GitHub Repository:** [https://github.com/yun-yao234/Carpenter_Bee_Analysis]

---

## 1. Project Abstract

*Xylocopa appendiculata* is a dominant native pollinator species in China with critical ecological value. Howea ver, genomic resources and population genetic studies for its local populations remain extremely limited.The core objective of this study is to characterize the genomic diversity of *X. appendiculata* and explore the genetic differentiation and clustering patterns among sampled individuals.


The raw whole-genome sequencing (WGS) data of *Xylocopa appendiculata* analyzed in this project was provided by the **"Sustainable to Bee" Research Group** (via Mintang).

**Computational Platform & Data Availability :**
All computational analyses were performed on the **Xi'an Jiaotong-Liverpool University (XJTLU) High-Performance Computing (HPC) Cluster**. 

The dataset consists of 17 individuals collected across different sequencing batches. The samples originate from three distinct sources with the following ecological metadata:
* **Site 1 (Beijing):** Wild environment; sex undetermined. 
  * Path: `/gpfs/work/bio/mintang/data/30wildbee_2019Bj-Yn/00.cleaned/`
  * Includes samples: `B16952`, `B16954`, `B16956`, `B16958`, `B16960`, `B16962`.
* **Site 2 (Suzhou):** Collected from *Brassica campestris* (Field Mustard); sex undetermined.
  * Path: `/gpfs/work/bio/mintang/data/SuzhouWildBeeGut202311_3rd/00.cleanData/`
  * Includes samples: `231001G085`, `231001G086`, `231001G087`, `231004G073`, `231004G074`, `231004G075`.
* **Shangfang Mountain (Suzhou):** Collected from *Cosmos sulphureus* (Sulfur Cosmos); all individuals confirmed as **Female**.
  * Path: `/gpfs/work/bio/mintang/data/SuzhouWildBee5th202405/00.QC/`
  * Includes samples: `TMBeeG0040`, `TMBeeG0042`, `TMBeeG0043`, `TMBeeG0044`, `TMBeeG0045`.

Due to the substantial file sizes of the raw paired-end reads across multiple sequencing batches, the initial FASTQ files are securely hosted on the HPC system rather than this GitHub repository.
Because whole-body crushing was used for sequencing, the raw dataset contains not only host genomic reads but also contaminating reads from gut microbiota, food residues, and environmental bacteria.


## 3. Bioinformatics Workflow

The complete analysis pipeline is modularized into four main phases. All execution scripts are stored in the `01_scripts/` directory, while intermediate and final outputs are strictly organized in `02_intermediate/` and `03_results/` respectively.

### Phase 1: Reference Genome Evaluation

Since no specific genome assembly exists for *X. appendiculata*, reference genomes of four related species within the genus *Xylocopa* were evaluated. Clean paired-end WGS reads from 17 samples were aligned to these candidates using BWA-MEM. Based on mapping efficiency (Total Mapping Rate and Properly Paired Rate), *X. dejeanii* (Assembly: GCA_049) was identified as the optimal reference for downstream analysis.

*  **Script :** `01_scripts/01_alignment_eval.sh`
*  **Input :** Clean paired-end Fastq files (from Lab sources) & 4 candidate genomes (`00_refs/`).
*  **Intermediate:** Raw sorted BAM files (`02_intermediate/${sample}_${ref_id}.sorted.bam`).
Some intermediate files are too large to upload, so I have submitted compressed TXT files instead. Please locate the source files on the server.
*  **Output :** Flagstat mapping reports (`03_results/01_mapping_stats/${sample}_${ref_id}_stats.txt`).

---

### Phase 2: Host Sequence Enrichment and Filtering

Because the wild bee samples were processed via whole-body crushing, the raw sequences contained substantial environmental noise, including gut microbiota and food residues. Based on the alignments to the optimal *X. dejeanii* reference, strict filtering (`samtools view -F 4`) was applied to discard unmapped reads. This crucial step effectively enriched the pure host genomic sequences, providing a clean dataset for accurate variant calling.

*  **Script :** `01_scripts/02_host_filtering.sh`
*  **Input:** Optimal reference BAM files from Phase 1 (`02_intermediate/${sample}_GCA_049.sorted.bam`).
*  **Intermediate :** Host-enriched BAM files (`02_intermediate/host_${sample}.sorted.bam`).
*  **Output :** Post-filtering QC summary reports (`03_results/02_filtered_summaries/${sample}_host_summary.txt`).


### Phase 3: Joint Variant Calling and Genotype Matrix Generation

To uncover the genetic variation across different geographical populations, joint variant calling was performed on all 17 host-enriched samples. Utilizing `bcftools mpileup` and `bcftools call`, we identified single nucleotide polymorphisms (SNPs) across the samples based on the optimal *X. dejeanii* reference. The raw binary variant call format (BCF) was subsequently queried to generate a human-readable genotype matrix, serving as the foundational dataset for exploring regional and sex-based genetic differentiation.


*  **Script :** `01_scripts/03_snp_calling.sh`
*  **Input :** Host-enriched BAM files (`02_intermediate/host_*.sorted.bam`) & Optimal Reference (`00_refs/GCA_049004755.1_ASM4900475v1_genomic.fna`).
*  **Intermediate :** Raw joint variants in BCF format (`03_results/03_snp_matrix/woodbee_variants.bcf`).
*  **Output :** Final Genotype Matrix table (`03_results/03_snp_matrix/final_genotype_table.txt`).


### Phase 4: Population Differentiation and FST Analysis

To quantify the genetic divergence among the sampled groups, we calculated Wright's Fixation Index ($F_{ST}$) using a sliding window approach (100 kb window size, 10 kb step size). Pairwise comparisons were established across three dimensions: 
1) Cross-regional differentiation (Beijing vs. Suzhou populations).
2) Intra-city control (Suzhou Site 2 vs. Suzhou Shangfang Mountain). 

*  **Script:** `01_scripts/04_fst_calculation.sh`
*  **Input:** Joint BCF variants (`03_results/03_snp_matrix/woodbee_variants.bcf`) & Population definition lists (`pop_beijing.txt`, etc.).
*  **Intermediate :** Sliding window raw log files (`*.fst.log`).
*  **Output:** FST statistical tables for all pairwise comparisons (`03_results/04_fst_results/*.windowed.weir.fst`).


### Phase 5: Principal Component Analysis (PCA)

To visualize the genetic structure and clustering patterns of the *X. appendiculata* populations, we performed Principal Component Analysis (PCA). The high-dimensional SNP data was first converted into PLINK format, followed by the calculation of the top 10 principal components (PCs) using `PLINK`. This dimensionality reduction approach allows us to project individuals onto a 2D or 3D space, revealing potential genetic clusters associated with geographic origin (Beijing vs. Suzhou) or biological traits (sex differences).


*  **Script :** `01_scripts/05_pca_analysis.sh`
*  **Input :** Joint BCF variants (`03_results/03_snp_matrix/woodbee_variants.bcf`).
*  **Intermediate:** PLINK format files (`02_intermediate/woodbee_for_pca.map`, `.ped`).
*  **Output :** PCA eigenvectors and eigenvalues (`03_results/05_pca_results/woodbee_pca_result.eigenvec`, `.eigenval`).


### Phase 6: Site-Specific Allele Frequency (SSAF) Profiling

To evaluate localized genetic divergence, site-by-site frequency dynamics were quantified across the Beijing and Suzhou sub-populations. Instead of executing traditional hard allele frequency estimates, this pipeline computes the Site-Specific Frequency Value (SSFV / SSAF), which offers a relative measure of variant prevalence within the aligned WGS reads of each geographical group. Utilizing `bcftools +fill-tags`, the raw frequency matrices were enriched to calculate the absolute frequency divergence (ΔSSFV) across all discovered polymorphic loci.

* **Script :** `01_scripts/06_allele_frequency.sh`
* **Input :** Joint BCF variants (`03_results/03_snp_matrix/woodbee_variants.bcf`) & Population lists (`pop_beijing.txt`, etc.).
* **Intermediate:** Streaming binary frequency conversion descriptors (`stdout`).
* **Output :** Site-by-site SSAF/SSFV text tables (`03_results/06_allele_frequency/*_freq.txt`).

### Phase 7: Tiered Divergence Screening, Flanking Extraction, and BLASTx Annotation

A tiered screening was performed on the constructed frequency profiles based on three increasingly stringent SSFV thresholds: Absolute Fixation (ΔSSFV = 1.0), High Differentiation (ΔSSFV ≥ 0.90), and Significant Divergence (ΔSSFV ≥ 0.80). To map these divergent sites to specific functional genes, symmetric 20,001 bp coordinate windows (10 kb upstream/downstream) centered on the top 20 variants exhibiting the strongest selection signals were established. Utilizing `bedtools getfasta`, flanking nucleotide sequences were extracted from the *X. dejeanii* template and independently subjected to homology searches against the NCBI protein database using BLASTx to uncover adaptive pathways (e.g., chemosensation, detoxification, and development).

* **Script :** `01_scripts/07_get_flanking_fasta.sh`
* **Input :** Multi-threshold filtered candidate file (`03_results/06_allele_frequency/final_fixed_sites_extreme.bed`) & Reference genome assembly (`00_refs/GCA_049004755.1_ASM4900475v1_genomic.fna`).
* **Intermediate:** Symmetrical flanking interval window maps (`03_results/07_flanking_sequences/snp_flanking_10kb.bed`).
* **Output :** Top 20 candidate flank sequence FASTA matrix (`03_results/07_flanking_sequences/target_snps_10kb.fasta`) & Downstream homology BLAST mapping records.


### Phase 8: Data Visualization (R Scripting)

To intuitively display the results of population structure and genetic differentiation, high-resolution publication-ready figures were generated using R (`ggplot2`). The PCA scatter plot visualizes the clustering of different geographical populations with 95% confidence ellipses, while the Manhattan plot highlights genomic regions with significant divergence (exceeding the Top 1% $F_{ST}$ threshold) between the Beijing and Suzhou groups.

*Note to Reviewers: Unlike the Bash scripts which are executed on the HPC cluster, the visualization R scripts are designed to be run on a local machine. Please adjust the `setwd()` path in the scripts to match your local directory.*

*  **Scripts:** `01_scripts/plot_PCA.R`, `01_scripts/plot_Manhattan.R`
*  **Input :** PCA vectors (`03_results/05_pca_results/`) & FST statistics (`03_results/04_fst_results/`).
* **Output :** High-resolution population genetic figures (`04_figures/`):
    * `04_figures/PCA_Final_Professional.png`
    * `04_figures/Manhattan_Clean_BJ_vs_SZ1.png`
    * `04_figures/Manhattan_Clean_BJ_vs_SZ2.png`
    * `04_figures/Manhattan_Clean_SZ_Internal.png`

---

## 4. Future Biological Interpretation

To further explore the adaptive evolution of X. appendiculata, the following analyses are planned:
4.1 Functional Annotation (GO/KEGG): We will extract coordinates of $F_{ST}$ outliers from Phase 4 to identify candidate genes. Using the X. dejeanii annotation, we will perform GO/KEGG enrichment to uncover pathways linked to local adaptation, such as metabolic or sensory responses.
4.2 Nucleotide Diversity ($\pi$): We will calculate $\pi$ for each population to assess genetic health. Significant reductions in $\pi$ can indicate historical population bottlenecks or intense selective sweeps within specific geographic environments.

5. AI Usage Statement
This project utilized Large Language Models (LLMs) primarily for technical debugging and documentation refinement. Specific applications include: Script Optimization and Documentation.
The experimental design, biological parameter selection, and data interpretation were conducted independently by the author.

---