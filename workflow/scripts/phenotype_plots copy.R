# Send output to log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

# Set variables

## Debug
IN_F2 = here::here("config/phenos_with_reporter_genoandpheno.csv")
OUT_PNG = here::here("book/plots/phenotypes/invnorm_intercept.png")
OUT_PDF = here::here("book/plots/phenotypes/invnorm_intercept.pdf")

## True
IN_F01 = snakemake@input[["f01"]]
IN_F2 = snakemake@input[["f2"]]
OUT_PNG = snakemake@output[["png"]]
OUT_PDF = snakemake@output[["pdf"]]

########################
# Plotting parameters
########################

# Intercept
intercept_pal = c("#8D99AE", "#2b2d42")

# Mean
mean_pal = c("#177E89", "#084C61")

# PSM
unsegmented_psm_area_pal = c("#D9D0DE", "#401F3E")

# Get lighter/darker functions

devtools::source_gist("c5015ee666cdf8d9f7e25fa3c8063c99")

########################
# Read in file
########################

df_f2 = readr::read_delim(IN_F2, delim = ";") %>% 
  # add `GEN` column
  dplyr::mutate(GEN = "F2") %>% 
  # factorise Microscope
  dplyr::mutate(Microscope = factor(Microscope, levels = c("AU", "DB")))


########################
# Plot
########################

########### Histogram raw

raw_fig = df_f2 %>% 
  # remove NAs
  dplyr::filter(!is.na(Microscope)) %>% 
  ggplot() +
  geom_histogram(aes(intercept, fill = Microscope),
                 bins = 50) +
  scale_fill_manual(values = intercept_pal) +
  cowplot::theme_cowplot() + 
  facet_grid(rows = vars(Microscope)) +
  xlab('period intercept') + 
  guides(fill = "none")

########### Histogram raw

trans_fig = df_f2 %>% 
  
  # remove NAs
  dplyr::filter(!is.na(Microscope)) %>% 
  ggplot() +
  geom_histogram(aes(intercept, fill = Microscope),
                 bins = 50) +
  scale_fill_manual(values = intercept_pal) +
  cowplot::theme_cowplot() + 
  facet_grid(rows = vars(Microscope)) +
  xlab('period intercept') + 
  guides(fill = "none")



  geom_violin() + 
  geom_boxplot(width = 0.3) +
  ggbeeswarm::geom_beeswarm(aes(GEN, intercept, colour = Microscope), size = 0.4, alpha = 0.5) +
   + 
  scale_colour_manual(values = lighter(intercept_pal, amount = 50)) +
  
  cowplot::theme_cowplot() +
  theme(strip.background.x = element_blank(),
        strip.text.x = element_text(face = "bold")) +
  xlab("generation") +
  ylab("period intercept") +
  guides(fill = "none",
         colour = "none") +
  # add p-value
  geom_text(data = kw_df %>% 
              dplyr::filter(phenotype == "intercept"),
            aes(x = "F2", y = -Inf, label = p_final,
                vjust = -1
            ))


########### Together

period_final = cowplot::plot_grid(intercept_fig,
                                  mean_fig,
                                  psm_fig,
                                  align = "hv",
                                  nrow = 3,
                                  labels = c("A", "B", "C"),
                                  label_size = 16)

ggsave(OUT_PNG,
       device = "png",
       width = 11,
       height = 13.5,
       units = "in",
       dpi = 400)

ggsave(OUT_PDF,
       device = "pdf",
       width = 11,
       height = 13.5,
       units = "in",
       dpi = 400)


