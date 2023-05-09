# Get project tree
rule project_tree:
	output:
		"results/project_tree.txt",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		bash workflow/scripts/tree.sh
		"""