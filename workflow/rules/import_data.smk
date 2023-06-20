rule import_input_data:
    output:
        "data/phyloseq_objects.rda",
        "data/ps_transformed.rda",
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/import_data.R"

