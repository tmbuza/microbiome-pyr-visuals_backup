rule lineplot:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/q2r_lineplot.svg", caption="../report/lineplot.rst", category="LinePlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/lineplot.R"