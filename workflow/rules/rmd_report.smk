# Get dot rule graphs
rule get_dot_rulegraph:
	output:
		"dags/rulegraph.svg",
		"dags/rulegraph.png",
	conda:
		"../envs/environment.yml"	
	shell:
		"bash workflow/scripts/rules_dag.sh"


# Get project tree
rule project_tree:
	output:
		tree="results/project_tree.txt",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		bash workflow/scripts/tree.sh
		"""

# Get smk html report
rule snakemake_interactive_report:
	output:
		smkhtml="report.html",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		bash workflow/scripts/smk_html_report.sh
		"""

# Get smk html report
rule snakemake_static_report:
	output:
		smkpng="images/smkreport/screenshot.png",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		bash workflow/scripts/smk_html_report.sh
		"""


# User styled report for GHPages
rule deploy_to_github_pages:
	input:
		rulegraph="dags/rulegraph.svg",
		tree="results/project_tree.txt",
		smkpng="images/smkreport/screenshot.png",
	output:
		doc="index.html",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		R -e "library(rmarkdown); render('index.Rmd')"
		"""