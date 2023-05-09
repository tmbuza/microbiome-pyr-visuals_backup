rule barplot:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/q2r_barplot.svg", caption="../report/barplot.rst", category="Barplot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/barplot.R"