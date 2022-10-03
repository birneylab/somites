# Send output to log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)

# Set variables

## Debug
IN = list("/hps/nobackup/birney/users/ian/somites/genos/F0_and_F1/hdrr/counts/Cab/5000.csv",
          "/hps/nobackup/birney/users/ian/somites/genos/F0_and_F1/hdrr/counts/Kaga/5000.csv",
          "/hps/nobackup/birney/users/ian/somites/genos/F0_and_F1/hdrr/counts/F1/5000.csv")

## True
IN = snakemake@input
OUT = snakemake@output[[1]]


# Read in files

names(IN) = purrr::map(IN, function(PATH){
  PATH %>% 
    stringr::str_split('/') %>% 
    unlist() %>% 
    .[length(.) -1]
}) %>% unlist()

df = purrr::map_dfr(IN,
                    readr::read_csv,
                    .id = "SAMPLE") %>% 
  dplyr::mutate(SAMPLE = factor(SAMPLE, levels = names(IN)))

# Get mean HOM/HET and write to file

df %>% 
  dplyr::group_by(SAMPLE) %>% 
  dplyr::summarise(MEAN_HOM = mean(PROP_HOM),
                   MEAN_HET = mean(PROP_HET)) %>% 
  readr::write_csv(OUT)

