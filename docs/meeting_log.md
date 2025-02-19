---
title: "Meeting log"
author: "Ian Brettell"
date: '2021-12-17'
output:
  html_document:
    toc: true
    toc_float: true
    dev: 'svg'
    number_sections: false
    keep_md: false
    pandoc_args: --lua-filter=color-text.lua
    highlight: pygments
editor_options: 
  markdown: 
    wrap: 72
zotero: ["PhD"]
bibliography: references.bib
---

# Notebook

## 2 December 2021

Ali has sent the third batch of F2 data.

Sample 323 is missing the first pair. 

## 26 November 2021

Suggestions from EB:

-   Set up guardrails -- e.g. the site must have at least 0.2 to 0.8 iCab vs Total
-   Limit to >= 100 and <= 10000
-   Plot chromosomes before filtering

## 17 November 2021

Other HMM genotyping by sequencing (GBS) methods:

-   Slides explaining HMM: https://alphagenes.roslin.ed.ac.uk/wp/wp-content/uploads/2019/05/05-JohnHickeyHMMIceCreamfastPHASEValenciaMay2018.pdf

-   magicImpute

    -   Paper: https://academic.oup.com/genetics/article/210/1/71/6088020?login=true
    -   Implemented in RABBIT: https://github.com/chaozhi/RABBIT

-   R/qtl2

    -   https://kbroman.org/qtl2/assets/vignettes/user_guide.htmlparalel
    -   Requires genotype file

-   TIGER

    -   Paper: https://www.g3journal.org/content/5/3/385
    -   GitHub: https://github.com/betharowan/TIGER_Scripts-for-distribution
    -   Thesis describing TIGER: <https://core.ac.uk/download/pdf/78377942.pdf>
    -   Paper using TIGER for outbred founders: https://gsejournal.biomedcentral.com/articles/10.1186/s12711-019-0487-1

-   FSFHap

    -   Paper: https://acsess.onlinelibrary.wiley.com/doi/full/10.3835/plantgenome2014.05.0023
    -   Implemented in TASSEL 5.0: https://tassel.bitbucket.io/
    -   Appears specific to plants, as it infers parental sequence from the progency seqeunce bcause "the plants that were sequenced are usually not the same ones that were used to make the full sib population and may have somewhat different genotypes" (https://bitbucket.org/tasseladmin/tassel-5-source/wiki/UserManual/FSFHapImputation/FSFHapImputation). 
    -   "Also, the progeny taken together generally provide very high coverage for the parental sequence and are often a better source for inferring the parent sequence than the parents themselves. FSFHap has a few different algorithms for inferring the parent haplotype. The default is the most robust and should be tried first for populations derived from F1's."
    -   "The windowLD method works well for highly inbred parents, but has problems if one of the parents has residual heterozygosity. Additional options exist for backcross populations."

-   LB-Impute

    -   Imputes missing alleles with an HMM.
    -   Paper: https://www.genetics.org/content/202/2/487
    -   GitHub: https://github.com/dellaporta-laboratory/LB-Impute 
    
-   fastPHASE

    -   estimates missing genotypes and reconstructing haplotypes from unphased SNP genotype data of *unrelated* individuals.

## 16 November 2021

-   [https://www.ncbi.nlm.nih.gov/](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5345719/)

@rowan2015 (TIGER)

-   Trained Individual GenomE Reconstruction \> The number of crossovers
    is typically limited to only one or two per chromosome pair per
    meiosis.

-   

@zan2019

-   Software / pipeline:
    <https://github.com/CarlborgGenomics/Stripes/tree/master/scripts>

-   Used 30x sequence data from founders, and \<0.5x sequence data on
    intercross individuals to infer the founder mosaic genotypes of
    intercross individuals.

-   7.6M markers segregated, and 10-13.7% of these fixed for alternative
    alleles in the founders.

-   95% agreement between genotypes from low-coverage data, and those
    obtained through SNP genotyping.

-   Estimated resolution of the inferred recombination breakpoints was
    relatively high, with 50% of them defined on regions shorter than 10
    kb.

-   Implements TIGER (referenced above)

-   

-   Experimenting with calling F0 and F2 together, to get:

    -   Better calling accuracy for F0; and

    -   To experiment with *bcftools*'s `roh` function
        <https://samtools.github.io/bcftools/bcftools.html#roh>, which
        uses an HMM to call runs of homozygosity.

    -   Also could test *plink1.9*'s `--homozyg` flag
        <https://www.cog-genomics.org/plink/1.9/ibd#homozyg>

        -   With the algorithm description in *plink1.7*'s docs here:
            <https://zzz.bwh.harvard.edu/plink/ibdibs.shtml#homo>

-   Differences in numbers of sites called:

    -   Original F0 only: 22618365 variants (18758908 SNPs)
    -   F0 with F2:

-   

    ## *bcftools*'s `roh` results:

## 23 September 2021

The following samples failed during the alignment of the second batch of
F2 individuals: `config/20210923_f2_fails.txt`. See that file for error
types.

## 22 September 2021

-   Ali has finished uploading the second batch of F2 sequences.
-   Tom has given me the GridLMM code, which is saved to
    `code/association_testing/gridLMM_gwas.R`

## 31 August 2021

### Location on EMBL server:

We use AnyConnect

vpn-gw1.embl.de

Server:

<smb://aulehla>

Username:

seleit

Location <smb://aulehla/aulehla/NGS_Data_Library/2021-08-12-AAAG3YWHV>

### `ascli`

They can use ascli from the terminal. All the info is at
<https://intranet.embl.de/it_services/services/data_sharing/aspera/index.html>.

`ascli` docs: <https://www.rubydoc.info/gems/aspera-cli>

Examples from docs:


```ruby
ascli faspex health
ascli faspex package list
ascli faspex package list --box=sent --fields=package_id --format=csv --display=data|tail -n 1);\
ascli faspex package list --fields=package_id --format=csv --display=data|tail -n 1);\
ascli faspex package recv --to-folder=. --box=sent --id="my_package_id"
ascli faspex package recv --to-folder=. --id="my_package_id"
ascli faspex package recv --to-folder=. --id=ALL --once-only=yes
ascli faspex package recv --to-folder=. --link="my_faspex_publink_recv_from_fxuser"
ascli faspex package send --delivery-info=@json:'{"title":"Important files delivery","recipients":["internal.user@example.com","FASPEX_USERNAME"]}' testfile.bin
ascli faspex package send --link="my_faspex_publink_send_to_dropbox" --delivery-info=@json:'{"title":"Important files delivery"}' testfile.bin
ascli faspex package send --link="my_faspex_publink_send_to_fxuser" --delivery-info=@json:'{"title":"Important files delivery"}' testfile.bin
ascli faspex source name "Server Files" node br /
ascli faspex5 node list --value=@json:'{"type":"received","subtype":"mypackages"}'
ascli faspex5 package list --value=@json:'{"mailbox":"inbox","state":["released"]}'
ascli faspex5 package receive --id="my_package_id" --to-folder=.
ascli faspex5 package send --value=@json:'{"title":"test title","recipients":[{"name":"${f5_user}"}]}' testfile.bin
```

Test:


```bash
# On EBI cluster
cd /nfs/ftp/private/indigene_ftp/upload/Ali/Kaga-Cab_F2_Fish201-400_WGS/

## Example
ascli faspex package recv --to-folder=. --link="my_faspex_publink_recv_from_fxuser"

## Tests
ascli faspex package recv --to-folder=. --link="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo="
#W, [2021-08-31T13:46:21.054223 #411589]  WARN -- : A new version is available: 4.2.0. You #have 4.1.0. Upgrade with: gem update 
#ascp: Error creating illegal char conversion table EINVAL, exiting.
#E, [2021-08-31T13:46:27.329374 #411589] ERROR -- : code: 11
#W, [2021-08-31T13:46:27.329485 #411589]  WARN -- : An error occured: ascp failed with code #1
#W, [2021-08-31T13:46:27.329507 #411589]  WARN -- : resuming in  2 seconds (retry left:6)
#ascp: Error creating illegal char conversion table EINVAL, exiting.
#E, [2021-08-31T13:46:30.441640 #411589] ERROR -- : code: 11
#W, [2021-08-31T13:46:30.441728 #411589]  WARN -- : An error occured: ascp failed with code #1
#E, [2021-08-31T13:46:30.441748 #411589] ERROR -- : non-retryable error
#ERROR: FASP(ascp]: ascp failed with code 1

ascli faspex package recv --to-folder=. --link="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo=#"
# As above

ascli faspex package recv --to-folder=. --link="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo"
# As above

ascli faspex package recv --to-folder=. --link=https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo=#
# As above

ascli faspex package recv --to-folder=. --delivery-info="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo="
# ERROR: Argument: Missing mandatory option: id

ascli faspex package recv --id=brettell@ebi.ac.uk --to-folder=. --delivery-info="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo="
# ERROR: Argument: Missing mandatory option: url

ascli faspex package recv --id=brettell@ebi.ac.uk --to-folder=. --url="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo="
# ERROR: Argument: Missing mandatory option: username

ascli faspex package recv --id=brettell@ebi.ac.uk --username=brettell@ebi.ac.uk --to-folder=. --url="https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo="
# ERROR: Argument: Missing mandatory option: password

ascli faspex package recv --to-folder=. --transfer=httpgw --transfer-info=@json:'{"url":"https://faspex.embl.de/aspera/faspex/external_deliveries/4366?passcode=221f3482a4d9b2fd87da2d21a2916156c2c1870d&expiration=MjAyMS0wOS0wN1QxMjo0Mjo0NVo=#"}'
```

### `lftp`

Hi, You can use the lftp command present in datatransfer.embl.de (here
is a tutorial)
<https://linuxconfig.org/lftp-tutorial-on-linux-with-examples> . If you
want to send files that are in your group share, they will be available
at /g/ location. Cheers.

------------------------------------------------------------------------

Josep Manel Andrés Moscardó Systems Engineer, IT Operations EMBL
Heidelberg T +49 6221 387-8394

## 3 August 2021

Added Cab and Kaga karyoplots.

Removed use of (almost) all wrappers in Snakemake pipeline. Now all
rules are containerised other than for pulling the reference sequence
from Ensembl.

[NOTE]{color="red"}: Install `plotly` and `DT` in R container.

## 15 July 2021

Notes for Ali:

-   Tried sample 171 again (the one you uploaded again), and it failed
    again at the alignment stage with the following error:


```bash
[mem_sam_pe_batch_post] paired reads have different names: "�0�����O&�����x�7�Z�HĻ�@�%Q�ü��", "ST-K00119:220:HKNVLBBXY:7:1101:1661:1138"
```

-   Fixed the sample names so that they don't include the pool number at
    the beginning, e.g. sample 171 is no longer called 7171

-   Cab has 15M homozygous sites, whereas Kaga only has 5M. Reason: Cab
    aligns better to HdrR, so there are many more 0/0 calls?

-   3.48M homozygous sites after joining Cab and Kaga homozygous site
    DFs.

-   2.7M homozygous divergent sites.

## 13 July 2021

### Attendees:

-   Ewan Birney
-   Alexander Aulehla
-   Tomas Fitzgerald
-   Ali Seleit
-   Ian Brettell

### Notes:

-   Genetics:

    -   Increase block size?

        -   Try site-by-site
        -   HMM would need to work on a *count* system so that it
            doesn't get skewed

-   [**ACTION**]{color="red"} (Ian):

    -   Check colours:

        -   Would expect Cab skew, especially as it has the reporter.

-   [**ACTION**]{color="red"} (Ian):

    -   Find number of reads covering each block for each individual.

    -   If they reach \< 5, increase the block size.

    -   Also check out chr 16 reporter locus.

    -   Make histogram of counts per block for each individual.

    -   Data frame:

        -   Fish ID
        -   Block ID
        -   Allele
        -   Count

    -   Plot a boxplot of counts per allele for all blocks per
        individual.

    -   Do for 5, 10 and 15 kb windows, then make boxplots to compare.

    -   Expect coverage across the homo-divergent regions is quite
        uneven.

    -   Also estimate heritability?

-   [**ACTION**]{color="red"} (Ali):

    -   Eyeball high phenotype points

    -   Also look at the plate position.

    -   Is there a between-day effect? (Note: Can only image 10
        individuals per day)

    -   Run a Kruskal-Wallis test for:

        -   day
        -   microscope (if they differ)
        -   any other way you can split it up
        -   look at the within-individual variance too

-   Re: sample size:

    -   Pause imaging while we check the above.
    -   Want to see the parents tight, and the F2 stretching out.
