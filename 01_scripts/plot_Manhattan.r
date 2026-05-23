# ==============================================================================
# Script Name: plot_Manhattan.R
# Description: Manhattan plot of genome-wide FST values identifying 
#              divergent selection regions between North and South populations.
# ==============================================================================

library(ggplot2)
library(dplyr)

# 1. Set working directory (Update this path if necessary)
setwd("D:/bee")

# 2. Load windowed FST data
# Make sure the file name matches your Step 3 output
fst_data <- read.table("BJ_vs_SZ_Site1.windowed.weir.fst", header = TRUE)

# Filter out missing values
fst_data <- fst_data %>% filter(!is.na(WEIGHTED_FST))

# 3. Define the top 1% significance threshold
threshold <- quantile(fst_data$WEIGHTED_FST, 0.99)

# 4. Prepare continuous genomic coordinates for plotting
plot_data <- fst_data %>%
  group_by(CHROM) %>%
  summarise(chr_len = max(BIN_START)) %>%
  mutate(tot = cumsum(as.numeric(chr_len)) - chr_len) %>%
  select(-chr_len) %>%
  left_join(fst_data, ., by = c("CHROM" = "CHROM")) %>%
  arrange(CHROM, BIN_START) %>%
  mutate(BPcum = BIN_START + tot)

# Create an alternating color index for scaffolds/chromosomes
plot_data$CHROM_FACTOR <- as.factor(plot_data$CHROM)
plot_data$COLOR_GROUP <- as.numeric(plot_data$CHROM_FACTOR) %% 2

# 5. Generate publication-ready Manhattan Plot
p_manhattan <- ggplot(plot_data, aes(x = BPcum, y = WEIGHTED_FST)) +
  geom_point(aes(color = as.factor(COLOR_GROUP)), alpha = 0.75, size = 1.2) +
  scale_color_manual(values = c("#4DBBD5", "#3C5488")) +
  geom_hline(yintercept = threshold, color = "#E64B35", linetype = "dashed", linewidth = 0.8) +
  theme_bw() +
  labs(
    title = expression(bold(paste("Genome-wide Genetic Differentiation (", F[ST], ")"))),
    subtitle = paste("Comparison: Beijing vs. Suzhou Site 1"),
    x = "Genomic Position",
    y = expression(paste("Weighted ", F[ST]))
  ) +
  theme(
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.text.x = element_blank(), 
    axis.ticks.x = element_blank(),
    text = element_text(family = "sans", size = 12),
    plot.title = element_text(hjust = 0.5, size = 15),
    plot.subtitle = element_text(hjust = 0.5, size = 10, face = "italic"),
    axis.title = element_text(face = "bold")
  ) +
  # Add threshold annotation text
  annotate("text", x = max(plot_data$BPcum) * 0.9, y = threshold + 0.02, 
           label = paste("Top 1% Threshold =", round(threshold, 3)), 
           color = "#E64B35", fontface = "italic", size = 4)

# 6. Save high-resolution figure
ggsave("Figure_2_Manhattan_BJ_vs_SZ1.png", p_manhattan, width = 10, height = 4.5, dpi = 300)