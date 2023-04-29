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
        "visual_types/explore_n_visualize.Rmd"
    shell: 
        "touch visual_types/explore_n_visualize.Rmd"


rule heatmaps:
    input:
        rules.visualize_processed_data.output
    output: 
        "visual_types/heatmaps/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule clusters:
    input:
        rules.visualize_processed_data.output
    output: 
        "visual_types/clusters/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule bar_plots: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "visual_types/barplots/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule box_plots: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "visual_types/boxplots/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule ordination_graphs: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "visual_types/ordinations/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


rule phylogenetic_trees: 
    input:
        rules.visualize_processed_data.output  
    output: 
        "visual_types/phylotrees/{prefix}.Rmd"
    shell: 
        "echo {wildcards.prefix} > {output}"


