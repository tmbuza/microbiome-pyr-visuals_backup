rule import_processed_data:
    output:
        "data/ps_df.csv"
    conda:
        "envs/myenv.yaml",
        "r-microbiome"
    script:
        """
        library(microbiome)

        # Load the dietswap phyloseq object
        data('dietswap', package = "microbiome")

        # Convert dietswap phyloseq object to dataframe
        ps_df <- psmelt(dietswap)

        # Save the dataframe as CSV
        write.csv(ps_df, file = "{output}", row.names = FALSE)
        """



rule basic_barplot:
    input:
        "data/ps_df.csv"
    output:
        "figures/basic_barplot.png"
    params:
        max_y = 100
    conda:
        "../envs/environment.yml"
    script:
        """
        ../scripts/barplot.R
        """