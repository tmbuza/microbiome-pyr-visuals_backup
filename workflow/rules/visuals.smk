rule venn_diagram:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/q2r_venndiagram.svg", caption="../report/venndiagram.rst", category="VennDiagram"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/venndiagram.R"


rule line_point_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/q2r_lineplot.svg", caption="../report/lineplot.rst", category="LinePlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/lineplot.R"


rule jitter_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/q2r_jitterplot.svg", caption="../report/jitterplot.rst", category="JitterPlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/jitterplot.R"



rule pcoa_ordination:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/q2r_pcoa.svg", caption="../report/pcoa.rst", category="PCoA"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/pcoa.R"



rule heatmap_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/q2r_heatmap.svg", caption="../report/heatmap.rst", category="HeatMap"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/heatmap.R"



rule taxa_barplot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/q2r_barplot.svg", caption="../report/barplot.rst", category="Taxa Barplot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/barplot.R"


