rule import_processed_data:
    output:
        rda="data/processed_data.rda"
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/import_processed_data.R"
        
    
rule visualize_processed_data:
    input:
        rules.import_processed_data.output,
    output: 
        "explore_n_visualize.Rmd"
    shell: 
        "touch explore_n_visualize.Rmd"


rule heatmaps:
    input:
        rules.visualize_processed_data.output
    output: 
        "heatmaps/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule clusters:
    input:
        rules.visualize_processed_data.output
    output: 
        "clusters/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule bar_plots: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "barplots/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule box_plots: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "boxplots/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule ordination_graphs: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "ordinations/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule phylogenetic_trees: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "phylotrees/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


