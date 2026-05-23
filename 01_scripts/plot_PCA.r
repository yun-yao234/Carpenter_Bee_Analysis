# ==============================================================================
# Script Name: plot_PCA.R
# Description: Principal Component Analysis (PCA) scatter plot with 95% 
#              confidence ellipses for Xylocopa population structure.
# ==============================================================================

library(ggplot2)

# 1. Set working directory (Update this path if necessary)
setwd("D:/bee")

# 2. Extract variance explained from eigenvalues
evals <- read.table("woodbee_pca_result.eigenval", header = FALSE)
pc_percent <- round(evals$V1 / sum(evals$V1) * 100, 2)

# 3. Load PCA coordinates
pca_data <- read.table("woodbee_pca_result.eigenvec", header = FALSE)
colnames(pca_data) <- c("FID", "IID", paste0("PC", 1:10))

# 4. Assign population groups and standard English labels
pca_data$Population <- "Unknown"
pca_data$Population[grepl("B169", pca_data$IID)] <- "Beijing (North)"
pca_data$Population[grepl("2310", pca_data$IID)] <- "Suzhou Site 1 (South)"
pca_data$Population[grepl("TMBee", pca_data$IID)] <- "Suzhou Site 2 (South)"

# Fix factor levels for correct legend display order
pca_data$Population <- factor(pca_data$Population, 
                              levels = c("Beijing (North)", "Suzhou Site 1 (South)", "Suzhou Site 2 (South)"))

# 5. Generate publication-ready plot (NPG color palette)
p_pca_en <- ggplot(pca_data, aes(x = PC1, y = PC2, color = Population)) +
  stat_ellipse(aes(fill = Population), geom = "polygon", alpha = 0.15, linetype = "dashed", linewidth = 0.3) +
  geom_point(size = 4, alpha = 0.85) +
  scale_color_manual(values = c("#E64B35", "#4DBBD5", "#00A087")) +
  scale_fill_manual(values = c("#E64B35", "#4DBBD5", "#00A087")) +
  theme_bw() +
  labs(
    title = expression(bold(paste("Principal Component Analysis of ", italic("Xylocopa"), " Populations"))),
    subtitle = "Based on whole-genome SNP variants",
    x = paste0("PC1 (", pc_percent[1], "% variance explained)"),
    y = paste0("PC2 (", pc_percent[2], "% variance explained)"),
    caption = "Ellipses represent 95% confidence intervals"
  ) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = c(0.85, 0.85),
    legend.background = element_rect(fill = alpha("white", 0.7), color = NA),
    legend.title = element_blank(),
    text = element_text(family = "sans", size = 12),
    plot.title = element_text(hjust = 0.5, size = 15),
    plot.subtitle = element_text(hjust = 0.5, size = 10, face = "italic"),
    axis.title = element_text(face = "bold")
  )

# 6. Save high-resolution figure
ggsave("Figure_1_PCA_Xylocopa.png", p_pca_en, width = 8, height = 6, dpi = 300)