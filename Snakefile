from snakemake.utils import min_version

min_version("6.10.0")

# Configuration file containing all user-specified settings
configfile: "config/config.yml"

report: "report/workflow.rst"


rule all:
    input:
        "data/ps_raw.rds",
        "data/ps_rel.rds",
        "data/phyloseq_objects.rda",
        "figures/basic_barplot.png",
        "figures/barplot_w_labels.png",
        "dags/rulegraph.png",



rule process_input_data:
    output:
        "data/ps_raw.rds",
        "data/ps_rel.rds",
        "data/phyloseq_objects.rda"
    conda:
        "workflow/envs/environment.yml",
    script:
        "workflow/scripts/process_input_data.R"


rule tidy_dataframe:
    input:
        "data/ps_raw.rds",
    output:
        "data/ps_df.rds"
    conda:
        "workflow/envs/environment.yml",
    script:
        "workflow/scripts/physeq_to_dataframe.R"

rule basic_barplot:
    input:
        "data/ps_df.rds"
    output:
        "figures/basic_barplot.png",
    params:
        max_y = 100
    conda:
        "workflow/envs/environment.yml"
    script:
        "workflow/scripts/basic_barplot.R"

rule barplot_w_labels:
    input:
        "data/ps_df.rds"
    output:
        "figures/barplot_w_labels.png"
    params:
        max_y = 100
    conda:
        "workflow/envs/environment.yml"
    script:
        "workflow/scripts/barplot_w_labels.R"


rule get_rulegraph:
	output:
		"dags/rulegraph.svg",
		"dags/rulegraph.png",
	shell:
		"bash workflow/scripts/rules_dag.sh"