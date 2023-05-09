rule github_pages:
	input:
		"dags/rulegraph.svg",
		"results/project_tree.txt",
		"report.html",
		"images/smkreport/screenshot.png",
	output:
		doc="index.html",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		R -e "library(rmarkdown); render('index.Rmd')"
		"""