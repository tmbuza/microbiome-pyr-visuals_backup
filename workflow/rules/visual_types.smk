rule visualize_processed_data:
    input:
        rules.import_processed_data.output
    output: 
        "visual_types/explore_n_visualize.Rmd"
    shell: 
        "echo {output}"


rule heatmaps: 
    input:
        rules.visualize_processed_data.output
    output: 
        "visual_types/heatmaps/{prefix}.Rmd",
    run: 
        """
        echo {wildcards.prefix} > {output}
        """


rule hierarchical_clusters:
    input:
        rules.visualize_processed_data.output
    output: 
        "visual_types/hclusters/{prefix}.Rmd"
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


