rule rulegraph:
	output:
		"dags/rulegraph.svg",
		"dags/rulegraph.png",
	conda:
		"../envs/environment.yml"	
	shell:
		"""
		snakemake -F --rulegraph | dot -Tsvg > dags/rulegraph.svg
		snakemake -F --rulegraph | dot -Tpng > dags/rulegraph.png
		"""
