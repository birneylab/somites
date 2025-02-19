# Send log

log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type = "message")

# Load libraries

library(tidyverse)
library(GridLMM)
library(KRLS)

# Get variables

## Debug
#GENO_FILE = "/hps/nobackup/birney/users/ian/somites/association_testing/20220321/all_sites/inputs/5000.rds"
##PHENO_FILE = "data/20220321_phenotypes.xlsx" # True phenotypes
#PHENO_FILE = "/hps/nobackup/birney/users/ian/somites/permuted_phenos/20220321/8.xlsx" # permuted phenotypes
#SOURCE_FILE = "workflow/scripts/run_gwas_source.R"
#BIN_LENGTH = 20000
#TARGET_PHENO = "intercept"
#COVARIATES = "Microscope"
#INVERSE_NORM = TRUE

## True
GENO_FILE = snakemake@input[["gt_pos_list"]]
PHENO_FILE = snakemake@input[["phenotypes_file"]]
BIN_LENGTH = snakemake@params[["bin_length"]] %>%
    as.numeric()
TARGET_PHENO = snakemake@params[["target_phenotype"]]
COVARIATES = snakemake@params[["covariates"]]
INVERSE_NORM = snakemake@params["inverse_norm"] %>% 
    as.logical()
REDUCED_FORMULA = snakemake@params[["reduced_formula"]]
SOURCE_FILE = snakemake@params[["source_file"]]
OUT_FILE = snakemake@output[[1]]

# Get GWAS functions

source(SOURCE_FILE)

# Load genotypes and positions

in_list = readRDS(GENO_FILE)

# Read in phenotypes

## Get covariates
if (COVARIATES == "None"){
    COVARIATES = NULL
    # if there are multiple covariates (separated by "-")
} else if (stringr::str_detect(COVARIATES, "-")){
    COVARIATES = COVARIATES %>% 
        stringr::str_split("-") %>% 
        unlist()
}

## Read in phenotype file and wrangle
phenos = readxl::read_xlsx(PHENO_FILE) %>%
    # adjust sample names
    dplyr::mutate(SAMPLE = fish %>% stringr::str_remove("KC")) %>%
    # select key columns
    dplyr::select(SAMPLE, all_of(TARGET_PHENO), all_of(COVARIATES)) %>%
    # ensure that the phenotype column is numeric
    dplyr::mutate(dplyr::across(all_of(TARGET_PHENO),
                                ~ as.numeric(.x)))

## Filter and order phenotypes
in_list[["phenotypes"]] = phenos %>%
    # filter phenotypes for those with genotypes
    dplyr::filter(SAMPLE %in% in_list[["sample_order"]]) %>%
    # join to `sample_order` to ensure phenotypes are in the correct order   
    dplyr::left_join(tibble::tibble(SAMPLE = in_list[["sample_order"]]),
                     .,
                     by = "SAMPLE") %>%
    # remove NAs (created by the samples that have genotypes but not phenotypes)
    tidyr::drop_na() %>%
    # the GridLMM code doesn't work with tibbles
    as.data.frame()

## Filter genotypes for those that have phenotypes
in_list[["genotypes"]] = in_list[["genotypes"]] %>%
  dplyr::slice(in_list[["sample_order"]] %in% in_list[["phenotypes"]]$SAMPLE %>% 
                 which())

## Filter sample_order for those that have phenotypes
in_list[["sample_order"]] = in_list[["phenotypes"]]$SAMPLE

##################
# Formulas
##################

# Create `formula`
if (is.null(covariates)){
  MAIN_FORMULA = "y~1 + (1|Geno)"
} else if (!is.null(covariates)){
  MAIN_FORMULA = paste("y~1 +", paste(covariates, collapse = " + "), "+ (1|Geno)")
}
MAIN_FORMULA = as.formula(MAIN_FORMULA)

# Create `test_formula`
if (is.null(covariates)){
  TEST_FORMULA = "~1"
} else if (!is.null(covariates)){
  TEST_FORMULA = paste("~1 +", paste(covariates, collapse = " + "))
}
TEST_FORMULA = as.formula(TEST_FORMULA)

# Create `reduced_formula`
REDUCED_FORMULA = as.formula(REDUCED_FORMULA)
            
# Run GWAS

out = run_gwas(d = in_list[["genotypes"]],
               m = in_list[["positions"]],
               p = in_list[["phenotypes"]],
               invers_norm = INVERSE_NORM,
               covariates = COVARIATES,
               main_formula = MAIN_FORMULA,
               test_formula = TEST_FORMULA,
               reduced_formula = REDUCED_FORMULA
              )

# Write results to file

## Make sure the directory exists
dir.create(dirname(OUT_FILE), recursive = T, showWarnings = F)
## Write
out = saveRDS(out, OUT_FILE)

