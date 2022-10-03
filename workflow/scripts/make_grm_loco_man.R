# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)
library(genio)

# Set variables

## Debug
IN_PREF = "/hps/nobackup/birney/users/ian/somites/beds/F2/hdrr/None/5000/0.8"
LOW_COV = c(26, 89, 166, 178, 189, 227, 239, 470, 472, 473, 490, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511) %>% 
  as.character()
OUT_PREF = "/hps/nobackup/birney/users/ian/somites/grm_man/hdrr/None/5000/grm_man_0.8"
OUT_PNG = here::here("book/plots/grm_man/hdrr/None/5000/grm_man_0.8.png")
OUT_PDF = here::here("book/plots/grm_man/hdrr/None/5000/grm_man_0.8.pdf")

## True
IN_PREF = snakemake@params[["in_pref"]]
LOW_COV = snakemake@params[["low_cov_samples"]]
OUT_PREF = snakemake@params[["out_pref"]]
OUT_PNG = snakemake@output[["png"]]
OUT_PDF = snakemake@output[["pdf"]]

# Read in files

## Read bed
fam = genio::read_fam(IN_PREF)
bim = genio::read_bim(IN_PREF)
df_genos = genio::read_bed(IN_PREF,
                           names_loci = bim$id,
                           names_ind = fam$id) %>% 
  as.data.frame()


# Get indexes of all non-low coverage samples
ind_keep = which(!as.character(fam$id) %in% LOW_COV)
# Filter out low-cov samples from `fam` and `df_genos`
df_genos = df_genos[, ind_keep]
fam = fam %>% 
  dplyr::filter(!id %in% LOW_COV)

# Convert genos to matrix

x = df_genos %>% 
  # transpose
  t(.) %>% 
  # convert back to data frame
  as.data.frame(.)

# Compute GRM "manually"
# Following guidance here: https://zjuwhw.github.io/2021/08/20/GRM.html

n = dim(x)[1]
m = dim(x)[2]
# For each SNP, sum the ALT alleles and divide by 2n to get the ALT allele frequency
p_hat = apply(x, 2, sum)/(2*n)
# Standardise matrix by allele frequency
w = apply(rbind(x,p_hat), 2, function(x) (x-2*x[length(x)])/sqrt(2*x[length(x)]*(1-x[length(x)])))[1:n,]

# Cacluate the GRM
A = w %*% t(w) / m

# Write to file
genio::write_grm(OUT_PREF,
                 kinship = A,
                 fam = fam %>% 
                   dplyr::select(fam, id))

#########################
# Plot GRM
#########################

# Order
ord = hclust(dist(A, method = "euclidean"), method = "ward.D")$order
labs = rownames(A)[ord]
# Get labs with cross
labs_x = tibble(SAMPLE = labs) %>% 
  dplyr::left_join(f2 %>% 
                     dplyr::select(SAMPLE, PAT_MAT),
                   by = "SAMPLE") %>% 
  # combine
  dplyr::mutate(S_X = paste(SAMPLE, PAT_MAT, sep = "_"))

# Order matrix
A_ord = A[ord, ord]

# Convert to DF
df_fig = A_ord %>% 
  as.data.frame() %>% 
  tibble::rownames_to_column(var = "SAMPLE_1") %>% 
  tidyr::pivot_longer(-c(SAMPLE_1), names_to = "SAMPLE_2", values_to = "VALUE")

## Inspect
#df_fig %>% 
#  dplyr::arrange(desc(VALUE)) %>% 
#  dplyr::filter(!SAMPLE_1 == SAMPLE_2) %>% 
#  View()

fig = df_fig %>% 
  ggplot() +
  geom_tile(aes(x = SAMPLE_1, y = SAMPLE_2, fill = VALUE)) +
  scale_fill_viridis_c(option = "plasma") +
  theme(aspect.ratio = 1) +
  theme(axis.text.x = element_text(angle = 90),
        axis.text = element_text(size = 2)) +
  xlab("sample A") +
  ylab("sample B")


ggsave(OUT_PNG,
       fig,
       device = "png",
       width = 30,
       height = 30,
       units = "in",
       dpi = 400)

ggsave(OUT_PDF,
       fig,
       device = "pdf",
       width = 30,
       height = 30,
       units = "in",
       dpi = 400)

