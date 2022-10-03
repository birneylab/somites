rule top_and_bottom_karyos:
    input:
        genos = rules.true_hmmlearn.output.csv,
        phenos = rules.split_inv_norm_pheno.output,
    output:
        prop_sites_total_top = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/prop_sites_total_top.png",
        prop_sites_total_bottom = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/prop_sites_total_bottom.png",
        karyoplot_no_missing_top = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/karyoplot_no_missing_top.png",
        karyoplot_no_missing_bottom = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/karyoplot_no_missing_bottom.png",
        karyoplot_with_missing_top = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/karyoplot_wi_missing_top.png",
        karyoplot_with_missing_bottom = "book/plots/{ref}/F1_het_min_DP/top_and_bottom_karyos/{max_reads}/{bin_length}/{cov}/{phenotype}/karyoplot_wi_missing_bottom.png",
    log:
        os.path.join(
            config["working_dir"],
            "logs/top_and_bottom_karyos/F1_het_min_DP/{ref}/{max_reads}/{bin_length}/{cov}/{phenotype}.log"
        ),
    params:
        cov = "{cov}",
        bin_length = "{bin_length}",
        max_reads = "{max_reads}"
    resources:
        mem_mb = 50000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/top_and_bottom_karyos.R"

rule kaga_F0_chr3:
    input:
        counts = rules.trio_gt_counts_in_bins.output,
        res = rules.run_mlma_loco_invnorm.output,
        min_p = rules.get_min_p_perms_invnorm.output,
    output:
        fig = "book/plots/{ref}/sig_region_zoom/{max_reads}/{cov}/{phenotype}/{sample}_{bin_length}_chr3.png",
    log:
        os.path.join(
            config["working_dir"],
            "logs/kaga_F0_chr3/{ref}_{max_reads}_{cov}_{phenotype}_{sample}_{bin_length}.log"
        ),
    params:
        bin_length = "{bin_length}"
    resources:
        mem_mb = 20000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/kaga_F0_chr3.R"

rule F2_chr3_pheno_by_gt:
    input:
        genos = rules.true_hmmlearn.output.csv,
        phenos = rules.split_inv_norm_pheno.output,
        res = rules.run_mlma_loco_invnorm.output,    
        min_p = rules.get_min_p_perms_invnorm.output,
    output:
        fig = "book/plots/{ref}/pheno_by_geno/{max_reads}/{cov}/{phenotype}/{bin_length}_chr3.png",
    log:
        os.path.join(
            config["working_dir"],
            "logs/F2_chr3_pheno_by_gt/{ref}_{max_reads}_{cov}_{phenotype}_{bin_length}.log"
        ),
    params:
        bin_length = "{bin_length}"
    resources:
        mem_mb = 20000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/F2_chr3_pheno_by_gt.R"

rule compile_scatters_thesis:
    input:
        standard = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/A.csv",
        trans_probs = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/B.csv",
        var_0_01 = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/D.csv",
        var_0_33 = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/C.csv",
        var_0_8 = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/F.csv",
        var_1 = "/hps/nobackup/birney/users/ian/somites/hmm_out/F2/hdrr/hmmlearn/None/5000/G.csv"
    output:
        png = "book/plots/thesis/scatter_collage.png",
        pdf = "book/plots/thesis/scatter_collage.pdf"
    log:
        os.path.join(
            config["working_dir"],
            "logs/compile_scatters_thesis/all.log"
        ),
    resources:
        mem_mb = 10000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/compile_scatters_thesis.R"

rule phenotype_plots:
    input:
        f01 = "data/F0_F1_period.xlsx",
        f2 = config["phenotypes_file"]
    output:
        png = "book/plots/phenotypes/phenotypes.png",
        pdf = "book/plots/phenotypes/phenotypes.pdf"
    log:
        os.path.join(
            config["working_dir"],
            "logs/phenotype_plots/all.log"
        ),
    resources:
        mem_mb = 5000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/phenotype_plots.R"

rule invnorm_intercept_plot:
    input:
        f2 = config["phenotypes_file"]
    output:
        png = "book/plots/phenotypes/invnorm_intercept.png",
        pdf = "book/plots/phenotypes/invnorm_intercept.pdf"
    log:
        os.path.join(
            config["working_dir"],
            "logs/invnorm_intercept_plot/all.log"
        ),
    resources:
        mem_mb = 5000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/invnorm_intercept_plot.R"

rule mean_hom_and_het_F0_F1:
    input:
        expand(rules.trio_gt_counts_in_bins.output,
            ref = "hdrr",
            bin_length = 5000,
            sample = ["Cab", "Kaga", "F1"]
        ),
    output:
        csv = "data/mean_hom_het_F0_F1.csv",
    log:
        os.path.join(
            config["working_dir"],
            "logs/mean_hom_and_het_F0_F1/all.log"
        ),
    resources:
        mem_mb = 5000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/mean_hom_and_het_F0.R"

rule coverage_plot_F0:
    input:
        rules.get_coverage_F0.output,
    output:
        png = "book/plots/coverage/F0_coverage.png",
        pdf = "book/plots/coverage/F0_coverage.pdf",
    log:
        os.path.join(
            config["working_dir"],
            "logs/coverage_plot_F0/all.log"
        ),
    resources:
        mem_mb = 2000
    container:
        config["R_4.1.3"]
    script:
        "../scripts/coverage_plot.R"    

