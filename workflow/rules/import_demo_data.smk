rule import_demo_data:
    output:
        "data/processed_objects.rda",
        "data/feature_table.qza",
        "data/sample_metadata.tsv",
        "data/taxonomy.qza",
        "data/rooted_tree.qza",
        "data/shannon_vector.qza",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/import_demo_data.R"

rule convert_qza2csv:
    input:
        demo=rules.import_demo_data.output,
    output:
        "data/features.csv",
        "data/metadata.csv",
        "data/taxonomy.csv",
        "data/shannon.csv",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/qiime2csv.R"


rule line_point_plot:
    input:
        demo=rules.import_demo_data.output,
    output:
        report("figures/q2r_lineplot.svg", caption="../report/lineplot.rst", category="LinePlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/lineplot.R"


rule jitter_plot:
    input:
        demo=rules.import_demo_data.output,
    output:
        report("figures/q2r_jitterplot.svg", caption="../report/jitterplot.rst", category="JitterPlot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/jitterplot.R"



rule pcoa_ordination:
    input:
        demo=rules.import_demo_data.output,
    output:
        report("figures/q2r_pcoa.svg", caption="../report/pcoa.rst", category="PCoA"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/pcoa.R"



rule heatmap_plot:
    input:
        demo=rules.import_demo_data.output,
    output:
        report("figures/q2r_heatmap.svg", caption="../report/heatmap.rst", category="HeatMap"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/heatmap.R"



rule taxa_barplot:
    input:
        demo=rules.import_demo_data.output,
    output:
        report("figures/q2r_barplot.svg", caption="../report/barplot.rst", category="Taxa Barplot"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/barplot.R"


