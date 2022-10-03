# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

IN = "/hps/software/users/birney/ian/repos/somites/results/annotations_invnorm/hdrr/None/5000/0.8/intercept/vep_out.txt"
IN = "/hps/software/users/birney/ian/repos/somites/results/annotations_psm/hdrr/None/5000/0.8/unsegmented_psm_area/None/vep_out.txt"

OUT_CONS = here::here("book/plots/annotations/intercept_consequence.png")
OUT_CONS = here::here("book/plots/annotations/psm_consequence.png")

OUT_CONS_GENES = 

CSV_CONS = here::here("results/annotations_invnorm/hdrr/None/5000/0.8/intercept/vep_consequence_counts.csv")
CSV_CONS = here::here("results/annotations_psm/hdrr/None/5000/0.8/unsegmented_psm_area/None/vep_consequence_counts.csv")

# Read in file

df = readr::read_tsv(IN, comment = "##",
                     na = "-",
                     col_types = c("ccccccciiicccc")) %>% 
  dplyr::mutate(Consequence = stringr::str_replace_all(Consequence, "_", " ")) 


# Total SNPs
df %>% 
  dplyr::distinct(Location) %>% 
  nrow()

# Counts for consequences

df %>% 
  dplyr::count(Consequence, name = "Count") %>% 
  dplyr::arrange(desc(Count)) %>% 
  readr::write_csv(CSV_CONS)

# Counts for genes covered by missense, stop loss or stop gained
df %>% 
  dplyr::filter(Consequence %in% c("missense variant", "start lost", "stop lost")) %>% 
  dplyr::distinct(Gene, Consequence) %>% 
  dplyr::count(Consequence) 


conseq_fig = df %>% 
  ggplot() +
    geom_bar(aes(Consequence, fill = Consequence)) +
    cowplot::theme_cowplot() +
    colorspace::scale_fill_discrete_qualitative(palette = "Set 3") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
    scale_y_log10() +
    guides(fill = 'none') +
    xlab("consequence")

ggsave(OUT_CONS,
       conseq_fig,
       device = "png",
       width = 12,
       height = 8,
       units = "in",
       dpi = 400)
