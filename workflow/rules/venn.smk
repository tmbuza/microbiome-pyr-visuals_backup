rule venn:
    input:
        "data/metadata.csv",
        "data/shannon.csv",
    output:
        report("figures/q2r_venndiagram.svg", caption="../report/venndiagram.rst", category="VennDiagram"),
    conda:
        "../envs/environment.yml"
    script:
        "../scripts/venndiagram.R"



