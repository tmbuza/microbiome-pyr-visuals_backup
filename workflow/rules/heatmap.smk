rule heatmap:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/q2r_heatmap.svg", caption="../report/heatmap.rst", category="HeatMap"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/heatmap.R"