rule pcoa:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/q2r_pcoa.svg", caption="../report/pcoa.rst", category="PCoA"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/pcoa.R"