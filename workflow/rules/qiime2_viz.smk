rule import_qiime2_data:
    output:
        "data/feature_table.qza",
        "data/sample_metadata.tsv",
        "data/taxonomy.qza",
        "data/rooted_tree.qza",
        "data/shannon_vector.qza",
    script:
        "../scripts/import_qiime2_data.R"


rule qiime2R_metadata_shannon_objects:
    input:
        rules.import_qiime2_data.output,
    output:
        "data/metadata.csv",
        "data/shannon.csv",
    script:
        "../scripts/qiime2_phyloseq_object.R"


rule venn_metadata_n_shannon:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/venn_metadata_shannon.svg", caption="../report/sample_venn.rst", category="Sample Venn"),
    script:
        "../scripts/plot_venn_metadata_shannon.R"


rule line_point_plot_w_errorbar:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/shannon_by_time.svg", caption="../report/shannon_div.rst", category="Shannon diversity"),
    script:
        "../scripts/plot_line_point_errorbar.R"