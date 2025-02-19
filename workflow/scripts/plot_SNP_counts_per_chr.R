# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

# Get variables

## Debug

IN = "/hps/nobackup/birney/users/ian/somites/sites_files/F0_Cab_Kaga/hdrr/homo_divergent/F1_het_min_DP.txt"
PNG = here::here("book/plots/sites/snp_counts_per_chr/hdrr.png")

## True

IN = snakemake@input[[1]]
PNG = snakemake@output[["png"]]
PDF = snakemake@output[["pdf"]]


df = readr::read_tsv(IN,
                     col_names = c("CHROM", "POS_1", "POS_2", "REF", "ALT", "F0_1_GT", "F0_2_GT"))

# Plot

out = df %>% 
  dplyr::count(CHROM) %>% 
  dplyr::mutate(CHROM = factor(CHROM, levels = sort(unique(CHROM)))) %>% 
  ggplot() +
  geom_col(aes(CHROM, n, fill = CHROM)) +
  guides(fill = "none") +
  cowplot::theme_cowplot() +
  xlab("chromosome") + 
  ylab("count") +
  scale_y_continuous(labels = scales::comma)

ggsave(PNG,
       out,
       device = "png",
       width = 9.6,
       height = 6,
       units = "in",
       dpi = 400)

ggsave(PDF,
       out,
       device = "pdf",
       width = 9.6,
       height = 6,
       units = "in",
       dpi = 400)
