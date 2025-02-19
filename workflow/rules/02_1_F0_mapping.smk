#rule map_reads_F0:
#    input:
#        target = rules.get_genome.output,
#        query = lambda wildcards: F0_samples.loc[(wildcards.F0_sample, wildcards.unit), ["fq1", "fq2"]].dropna().tolist(),
#    output:
#        os.path.join(
#            config["working_dir"],
#            "sams/F0/{ref}/mapped/{F0_sample}-{unit}.sam"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/map_reads_F0/{ref}/{F0_sample}/{unit}.log"
#        ),
#    params:
#        extra="-ax sr",
#    resources:
#        mem_mb = 10000
#    threads:
#        8
#    container:
#        config["minimap2"]
#    shell:
#        """
#        minimap2 \
#            -t {threads} \
#            {params.extra} \
#            {input.target} \
#            {input.query} \
#                > {output[0]}
#        """
#
rule bwa_mem2_mem_F0:
    input:
        reads = lambda wildcards: F0_samples.loc[(wildcards.F0_sample, wildcards.unit), ["fq1", "fq2"]].dropna().tolist(),
        idx = rules.bwa_mem2_index.output,
        ref = rules.get_genome.output,
    output:
        os.path.join(
            config["working_dir"],
            "sams/F0/{ref}/bwamem2/mapped/{F0_sample}-{unit}.sam"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/bwa_mem2_mem/{ref}/{F0_sample}/{unit}.log")
    params:
        extra=r"-R '@RG\tID:{F0_sample}\tSM:{F0_sample}'",
    container:
        config["bwa-mem2"]
    resources:
        mem_mb = 10000
    threads:
        8
    shell:
        """
        bwa-mem2 mem \
            -t {threads} \
            {params.extra} \
            {input.ref} \
            {input.reads} \
                > {output} \
                    2> {log}
        """
#rule replace_rg_F0:
#    input:
#        rules.map_reads_F0.output,
#    output:
#        os.path.join(
#            config["working_dir"],
#            "sams/F0/{ref}/grouped/{F0_sample}-{unit}.sam"
#        ),
#    log:
#        os.path.join(
#            config["working_dir"],
#            "logs/replace_rg_F0/{ref}/{F0_sample}_{unit}.log"
#        ),
#    params:
#        "RGLB=lib1 RGPL=ILLUMINA RGPU={unit} RGSM={F0_sample}"
#    resources:
#        mem_mb=1024
#    container:
#        config["picard"]
#    shell:
#        """
#        picard AddOrReplaceReadGroups \
#            -Xmx{resources.mem_mb}M \
#            {params} \
#            INPUT={input[0]} \
#            OUTPUT={output[0]} \
#                &> {log}
#        """

rule sort_sam_F0:
    input:
        rules.bwa_mem2_mem_F0.output,
    output:
        os.path.join(
            config["working_dir"],
            "bams/F0/{ref}/sorted/{F0_sample}-{unit}.bam"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/sort_sam_F0/{ref}/{F0_sample}_{unit}.log"
        ),
    params:
        sort_order="coordinate",
        extra=lambda wildcards: "VALIDATION_STRINGENCY=LENIENT TMP_DIR=" + config["tmp_dir"]
    resources:
        java_mem_mb = 4096,
        mem_mb = 20000
    container:
        config["picard"]
    shell:
        """
        picard SortSam \
            -Xmx{resources.java_mem_mb}M \
            {params.extra} \
            INPUT={input[0]} \
            OUTPUT={output[0]} \
            SORT_ORDER={params.sort_order} \
                &> {log}
        """

rule mark_duplicates_F0:
    input:
        rules.sort_sam_F0.output,
    output:
        bam=os.path.join(
            config["working_dir"],
            "bams/F0/{ref}/marked/{F0_sample}-{unit}.bam"
        ),
        metrics=os.path.join(
            config["working_dir"],
            "bams/F0/{ref}/marked/{F0_sample}-{unit}.metrics.txt"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/mark_duplicates_F0/{ref}/{F0_sample}_{unit}.log"
        ),
    params:
        lambda wildcards: "REMOVE_DUPLICATES=true TMP_DIR=" + config["tmp_dir"]
    resources:
        java_mem_mb=1024,
        mem_mb=10000
    container:
        config["picard"]
    shell:
        """
        picard MarkDuplicates \
            -Xmx{resources.java_mem_mb}M \
            {params} \
            INPUT={input[0]} \
            OUTPUT={output.bam} \
            METRICS_FILE={output.metrics} \
                &> {log}
        """

rule merge_bams_F0:
    input:
        expand(os.path.join(
            config["working_dir"],
            "bams/F0/{{ref}}/marked/{{F0_sample}}-{unit}.bam"),
                unit = list(set(F0_samples['unit']))
        ),
    output:
        os.path.join(
            config["working_dir"],
            "bams/F0/{ref}/merged/{F0_sample}.bam"
        ),
    log:
        os.path.join(
            config["working_dir"],
            "logs/merge_bams_F0/{ref}/{F0_sample}.log"
        ),
    params:
        extra = lambda wildcards: "VALIDATION_STRINGENCY=LENIENT TMP_DIR=" + config["tmp_dir"],
        in_files = lambda wildcards, input: " I=".join(input)
    resources:
        java_mem_mb=1024,
        mem_mb = 5000
    container:
        config["picard"]
    shell:
        """
        picard MergeSamFiles \
            -Xmx{resources.java_mem_mb}M \
            {params.extra} \
            INPUT={params.in_files} \
            OUTPUT={output} \
                &> {log}
        """

rule samtools_index_F0:
    input:
        rules.merge_bams_F0.output
    output:
        os.path.join(
            config["working_dir"],
            "bams/F0/{ref}/merged/{F0_sample}.bam.bai"
        ),
    log:
        os.path.join(
            config["working_dir"], 
            "logs/samtools_index_F0/{ref}/{F0_sample}.log"
        ),
    container:
        config["samtools"]
    resources:
        mem_mb = 5000
    shell:
        """
        samtools index \
            {input[0]} \
            {output[0]} \
                &> {log}
        """

rule get_coverage_F0:
    input:
        bam = rules.merge_bams_F0.output,
        ind = rules.samtools_index_F0.output,
    output:
        os.path.join(
            config["working_dir"],
            "coverage/{ref}/bwamem2/{F0_sample}.txt"
        ),
    log:
        os.path.join(
            config["working_dir"], 
            "logs/get_coverage/{ref}/{F0_sample}.log"
        ),
    resources:
        mem_mb = 2000
    container:
        config["samtools"]
    shell:
        """
        samtools coverage \
            {input.bam} >\
                {output[0]} \
                    2> {log}
        """
