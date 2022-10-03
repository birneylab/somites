rule run_reml_invnorm:
    input:
        phen = rules.split_inv_norm_pheno.output,
        grm = rules.make_grm_man.output,
    output:
        hsq = "results/gcta/reml_state_freq/{ref}/{max_reads}/{bin_length}/{cov}/{phenotype}.hsq"
    log:
        os.path.join(
            config["working_dir"],
            "logs/run_reml_invnorm/hdrr/{ref}/{max_reads}/{bin_length}/{cov}/{phenotype}.log"
        ),
    params:
        grm_pref = lambda wildcards, input: input.grm[0].replace(".grm.bin", ""),
        out_pref = lambda wildcards, output: output.hsq.replace(".hsq", ""),
    resources:
        mem_mb = 2000,
        threads = 1
    container:
        config["GCTA"]
    shell:
        """
        gcta64 \
            --reml \
            --grm {params.grm_pref} \
            --pheno {input.phen} \
            --out {params.out_pref} \
            --autosome-num 24 \
            --thread-num {resources.threads} \
                2> {log}
        """