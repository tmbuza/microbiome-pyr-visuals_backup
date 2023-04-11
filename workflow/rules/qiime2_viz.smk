rule import_qiime2_data:
    output:
        features="data/feature_table.qza", 
        taxonomy = "data/taxonomy.qza", 
        metadata="data/sample_metadata.tsv",
        shannon="data/shannon.qza",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/importdata.R"
        

rule import_demo_qiime2_data:
    output:
        "resources/feature_table.qza",
        "resources/sample_metadata.tsv",
        "resources/taxonomy.qza",
        "resources/rooted_tree.qza",
        "resources/shannon_vector.qza",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/importdata.R"



rule qiime2_phyloseq_object:
    input:
        q2data=rules.import_qiime2_data.output,
        demo=rules.import_demo_qiime2_data.output,
    output:
        "data/q2_ps.rds",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/phyloseqobject.R"


rule convert_qiime2csv:
    input:
        features="data/feature_table.qza", 
        taxonomy = "data/taxonomy.qza", 
        metadata="data/sample_metadata.tsv",
        shannon="data/shannon.qza",
    output:
        "data/features.csv",
        "data/metadata.csv",
        "data/taxonomy.csv",
        "data/shannon.csv",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/qiime2csv.R"

rule venn_diagram:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/venndiagram.svg", caption="../report/venndiagram.rst", category="VennDiagram"),
    script:
        "../scripts/venndiagram.R"


rule line_point_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/lineplot.svg", caption="../report/lineplot.rst", category="LinePlot"),
    script:
        "../scripts/lineplot.R"


rule jitter_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/jitterplot.svg", caption="../report/jitterplot.rst", category="JitterPlot"),
    script:
        "../scripts/jitterplot.R"



rule pcoa_ordination:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/pcoa.svg", caption="../report/pcoa.rst", category="PCoA"),
    script:
        "../scripts/pcoa.R"



rule heatmap_plot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/heatmap.svg", caption="../report/heatmap.rst", category="HeatMap"),
    script:
        "../scripts/heatmap.R"



rule taxa_barplot:
    input:
        demo=rules.import_demo_qiime2_data.output,
    output:
        report("figures/barplot.svg", caption="../report/barplot.rst", category="Taxa Barplot"),
    script:
        "../scripts/barplot.R"


