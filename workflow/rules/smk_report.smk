# Get smk html report
rule interactive_smk_report:
	output:
		"report.html",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		snakemake --report report.html
		"""

# Get static report
rule static_smk_report:
	input:
		"report.html",
	output:
		"images/smkreport/screenshot.png",
	conda:
		"../envs/environment.yml"
	shell:
		"""
		hti -H report.html -o images/smkreport
		"""