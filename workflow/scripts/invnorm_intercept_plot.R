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

# Get means per microscope
f2_means_notrans = df_f2 %>% 
  dplyr::filter(!is.na(Microscope)) %>% 
  dplyr::group_by(Microscope) %>% 
  dplyr::summarise(MEAN = mean(intercept, na.rm = T))


########################
# Plot
########################

########### Histogram raw

raw_fig = df_f2 %>% 
  # remove NAs
  dplyr::filter(!is.na(Microscope)) %>% 
  ggplot(aes(intercept)) +
  geom_histogram(aes(y = ..density.., fill = Microscope), bins = 40) +
  geom_density(aes(colour = Microscope)) +
  geom_vline(data = f2_means_notrans, aes(xintercept = MEAN)) +
  scale_fill_manual(values = intercept_pal) +
  scale_colour_manual(values = darker(intercept_pal,amount = 75)) +
  cowplot::theme_cowplot() + 
  facet_grid(rows = vars(GEN, Microscope)) +
  xlab('period intercept') + 
  guides(fill = "none", colour = "none") +
  labs(subtitle = "original data")

########### Histogram inverse-normalised

invnorm = function(x) {
  res = rank(x)
  res = qnorm(res/(length(res)+0.5))
  return(res)
}

trans_df = df_f2 %>% 
  # inverse-normalise within microscope
  dplyr::group_by(Microscope) %>% 
  dplyr::mutate(intercept = invnorm(intercept)) %>% 
  dplyr::ungroup() %>% 
  # remove NAs
  dplyr::filter(!is.na(Microscope))

# Get means per microscope
f2_means_trans = trans_df %>% 
  dplyr::filter(!is.na(Microscope)) %>% 
  dplyr::group_by(Microscope) %>% 
  dplyr::summarise(MEAN = mean(intercept, na.rm = T))

trans_fig = trans_df %>% 
  # plot
  ggplot(aes(intercept)) +
  geom_histogram(aes(y = ..density.., fill = Microscope), bins = 40) +
  geom_density(aes(colour = Microscope)) +
  geom_vline(data = f2_means_trans, aes(xintercept = MEAN)) +
  scale_fill_manual(values = intercept_pal) +
  scale_colour_manual(values = darker(intercept_pal,amount = 75)) +
  cowplot::theme_cowplot() + 
  facet_grid(rows = vars(GEN, Microscope)) +
  xlab('period intercept (inverse-normalised)') + 
  guides(fill = "none", colour = "none") +
  labs(subtitle = "inverse-normalised within microscope")


########### Together

final = cowplot::plot_grid(raw_fig,
                                  trans_fig,
                                  align = "hv",
                                  nrow = 2,
                                  labels = c("A", "B"),
                                  label_size = 16)

ggsave(OUT_PNG,
       device = "png",
       width = 8,
       height = 8.5,
       units = "in",
       dpi = 400)

ggsave(OUT_PDF,
       device = "pdf",
       width = 8,
       height = 8.5,
       units = "in",
       dpi = 400)


