# Create a GRM for all chromosomes
rule make_grm_man:
    input:
        bed = rules.create_bed.output.bed,
    output:
        grm = os.path.join(
            config["working_dir"],
            "grm_man/{ref}/{max_reads}/{bin_length}/grm_man_{cov}.grm.bin"
        ),
        png = "book/plots/grm_man/{ref}/{max_reads}/{bin_length}/grm_man_{cov}.png",
        pdf = "book/plots/grm_man/{ref}/{max_reads}/{bin_length}/grm_man_{cov}.pdf"
    log:
        os.path.join(
            config["working_dir"],
            "logs/make_grm_man/{ref}/{max_reads}/{bin_length}/{cov}.log"
        ),
    params:
        in_pref = lambda wildcards, input: input.bed.replace(".bed", ""),
        out_pref = lambda wildcards, output: output.grm.replace(".grm.bin", ""),    
        low_cov_samples = config["low_cov_samples"]
    resources:
        mem_mb = 10000,
        threads = 1
    container:
        config["R_4.1.3"]
    script:
        "../scripts/make_grm_loco_man.R"

## Create a LOCO-GRM for each chromosome and plot the matrix
#rule make_grm_loco_man:
#    input:
#        bed = rules.create_bed_grm_loco.output.bed,
#        F2_samples =  config["F2_samples_file"]
#    output:
#        grm = os.path.join(
#            config["workdir"],
#            "grms_loco_man/hdrr/{bin_length}/{cov}/{contig}.grm.bin"
#        ),
#        png = "book/figs/grm_loco_man/{bin_length}/{cov}/{contig}.png",
#        pdf = "book/figs/grm_loco_man/{bin_length}/{cov}/{contig}.pdf"
#    log:
#        os.path.join(
#            config["workdir"],
#            "logs/make_grm_loco_man/hdrr/{bin_length}/{cov}/{contig}.log"
#        ),
#    params:
#        in_pref = lambda wildcards, input: input.bed.replace(".bed", ""),
#        out_pref = lambda wildcards, output: output.grm.replace(".grm.bin", ""),    
#    resources:
#        mem_mb = 10000,
#        threads = 1
#    container:
#        config["R_4.2.0"]
#    script:
#        "../scripts/make_grm_loco_man.R"
#
## Create a LOCO-GRM for each chromosome and plot the matrix
## This one creates a GRM based on all 20M SNPs, rather than
## The 44K with no missing calls
#rule make_grm_loco_man_no_miss:
#    input:
#        bed = rules.create_bed_all.output.bed,
#        F2_samples =  config["F2_samples_file"]
#    output:
#        grm = os.path.join(
#            config["workdir"],
#            "grms_loco_man_no_miss/hdrr/{bin_length}/{cov}/{contig}.grm.bin"
#        ),
#        png = "book/figs/grm_loco_man_no_miss/{bin_length}/{cov}/{contig}.png",
#        pdf = "book/figs/grm_loco_man_no_miss/{bin_length}/{cov}/{contig}.pdf"
#    log:
#        os.path.join(
#            config["workdir"],
#            "logs/make_grm_loco_man_no_miss/hdrr/{bin_length}/{cov}/{contig}.log"
#        ),
#    params:
#        in_pref = lambda wildcards, input: input.bed.replace(".bed", ""),
#        out_pref = lambda wildcards, output: output.grm.replace(".grm.bin", ""),    
#    resources:
#        mem_mb = 800000,
#        queue = "bigmem"
#    container:
#        config["R_4.2.0"]
#    script:
#        "../scripts/make_grm_loco_man_no_miss.R"

