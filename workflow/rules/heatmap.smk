rule create_heatmaps:
    input:
        counts="data/microbiome_counts.csv",
        metadata="data/sample_metadata.csv"
    output:
        heatmap="results/heatmap.png"
    conda:
        "envs/my_env.yaml"
    script:
        r_script = "scripts/create_heatmap.R"
        python_script = "scripts/create_heatmap.py"
    shell:
        """
        Rscript {script.r_script} {input.counts} {input.metadata} {output.heatmap}
        python {script.python_script} {input.counts} {input.metadata} {output.heatmap}
        """

rule qiime2R_heatmap:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/qiime2R_heatmap.svg", caption="../report/qiime2R_heatmap.rst", category="Heatmap by qiime2R"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/qiime2R_heatmap.R"


rule ggplot_heatmap:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/gg_bray_heatmap.svg", caption="../report/ggplot_heatmap.rst", category="Bray_Heatmap"),
        report("figures/gg_jcard_heatmap.svg", caption="../report/ggplot_heatmap.rst", category="Jaccard-Heatmap"),
        # report("figures/gg_bray_jcard_heatmap.svg", caption="../report/ggplot_heatmap.rst", category="Bray-Jcard Heatmap"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/ggplot_heatmap.R"


rule microViz_heatmap:
    input:
        demo=rules.processed_data.output,
    output:
        report("figures/microViz_wo_heatmap.svg", caption="../report/microViz_heatmap.rst", category="microViz_Heatmap"),
        # report("figures/microViz_w_heatmap.svg", caption="../report/microViz_heatmap.rst", category="microViz_Heatmap"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/microViz_heatmap.R"




