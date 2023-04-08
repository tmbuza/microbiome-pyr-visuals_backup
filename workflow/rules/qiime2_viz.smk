rule import_qiime2_data:
    output:
        features="data/feature_table.qza", 
        taxonomy = "data/taxonomy.qza", 
        metadata="data/sample_metadata.tsv",
        shannon="data/shannon.qza",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/import_qiime2_data.R"
        

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
        "../scripts/import_qiime2_data.R"



rule qiime2_phyloseq_object:
    input:
        q2data=rules.import_qiime2_data.output,
        demo=rules.import_demo_qiime2_data.output,
    output:
        "data/q2_ps.rds",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/qiime2_phyloseq_object.R"


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
        "../scripts/convert_qiime2csv.R"

rule venn_metadata_shannon:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/venn_metadata_shannon.svg", caption="../report/shannon_metadata_venn.rst", category="Shannon_Metadata Venn"),
    script:
        "../scripts/plot_venn_metadata_shannon.R"


rule lineplot_shannon_diversity:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/line_shannon_by_time.svg", caption="../report/shannon_time_diversity.rst", category="Shannon diversity"),
    script:
        "../scripts/plot_shannon_diversity.R"


