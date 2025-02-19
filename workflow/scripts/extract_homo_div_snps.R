# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

# Get variables

## Debug
#GENO_FILE = "/hps/nobackup/birney/users/ian/somites/genos/F0_and_F1/snps_with_AD/all.txt"
#MIN_AD = 5

## True
GENO_FILE = snakemake@input[["genos"]]
MIN_AD = snakemake@params[["min_ad"]] %>% 
  as.numeric()
OUT_FULL = snakemake@output[["full"]]
OUT_SITES = snakemake@output[["sites"]]

# Read in file

genos = readr::read_tsv(GENO_FILE)

# Tidy up column names
colnames(genos) = colnames(genos) %>% 
  stringr::str_remove(pattern = "\\[.*\\]") %>% 
  stringr::str_remove(pattern = "# ") %>% 
  stringr::str_replace(pattern = ":", "_")
  
# Recode genotypes

rc = genos %>% 
  # remove allele depth columns for Cab and Kaga
  dplyr::select(-c(Cab_AD, Kaga_AD)) %>% 
  # recode alleles
  dplyr::mutate(dplyr::across(c(Cab_GT,
                                 Kaga_GT,
                                 F1_GT),
                              ~dplyr::case_when(. == "1|1" | . == "1/1" ~ "11",
                                                . == "0|0" | . == "0/0" ~ "00",
                                                . == "0|1" | . == "0/1" ~ "01",
                                                . == ".|." | . == "./." ~ "MISS",
                                                TRUE ~ .),
                              .names = "{.col}_RC")) %>% 
  # split F1 allele depth column
  tidyr::separate(col = F1_AD,
                  into = c("F1_AD_REF", "F1_AD_ALT"),
                  sep = ",",
                  convert = T) %>% 
  # reorder columns
  dplyr::select(CHROM, POS, REF, ALT, Cab_GT, Kaga_GT, F1_GT, F1_AD_REF, F1_AD_ALT, Cab_GT_RC, Kaga_GT_RC, F1_GT_RC)

# Create pass/fail filter for homozygous-divergent SNPs with a minimum per-allele depth in F1

filt = rc %>% 
  dplyr::mutate(FILTER = dplyr::case_when(Cab_GT_RC == "00" & Kaga_GT_RC == "11" & F1_GT_RC == "01" & F1_AD_REF >= MIN_AD & F1_AD_ALT >= MIN_AD ~ "PASS",
                                          Cab_GT_RC == "11" & Kaga_GT_RC == "00" & F1_GT_RC == "01" & F1_AD_REF >= MIN_AD & F1_AD_ALT >= MIN_AD ~ "PASS",
                                          TRUE ~ "FAIL"))
## Write to file
readr::write_csv(filt, OUT_FULL)

# Filter for passes to create sites file

sites = filt %>% 
  dplyr::filter(FILTER == "PASS") %>% 
  dplyr::select(CHROM, POS_1 = POS, POS_2 = POS, REF, ALT, Cab_GT, Kaga_GT) %>% 
  # replace "|" with "/"
  dplyr::mutate(dplyr::across(c(Cab_GT, Kaga_GT),
                              ~stringr::str_replace(.x, "\\|", "\\/")))

## Write to file
readr::write_tsv(sites, OUT_SITES, col_names = F)

