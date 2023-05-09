rule jitter:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/q2r_jitterplot.svg", caption="../report/jitterplot.rst", category="JitterPlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/jitterplot.R"