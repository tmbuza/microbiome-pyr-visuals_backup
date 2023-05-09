rule processed_data:
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
        "../scripts/processed_data.R"

rule convert_qza2csv:
    input:
        demo=rules.processed_data.output,
    output:
        "data/features.csv",
        "data/metadata.csv",
        "data/taxonomy.csv",
        "data/shannon.csv",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/qiime2csv.R"
