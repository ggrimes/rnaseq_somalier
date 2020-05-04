### Submitting on the cluster:
#snakemake -p plots/combined_plot.lagging.POLE_mut.pole.mm10.pdf --cluster-config cluster.json --cluster "qsub -V -cwd -l h_vmem={cluster.mem} -l h_stack={cluster.stack} -e {cluster.error} -o {cluster.output} -pe sharedmem {cluster.sharedmem}  " -j 50

##### load config and sample sheets #####

configfile: "config.yaml"
#read in bam files from file
f = open("samples.tsv", "r")
SAMPLES = f.read().splitlines()
f.close()
#SAMPLES = ["test", "test2"]

rule all:
    input:
        html="somalier.html",
        som=expand("cohort/{sample}.somalier", sample=SAMPLES)
        
        
        
import os
from snakemake.remote.HTTP import RemoteProvider as HTTPRemoteProvider

HTTP = HTTPRemoteProvider()
#downlaod site
rule download_sites:
    input: HTTP.remote("https://github.com/brentp/somalier/files/4566475/sites.hg38.rna.vcf.gz", keep_local=True)
    run:
        outputName = os.path.basename(input[0])
        shell("mv {input} {outputName}")        
#remove chr prefix from vcf file
rule add_chr:
    input: "sites.hg38.rna.vcf.gz"
    output: "sites.hg38.rna.nochr.vcf.gz"
    shell:
        "cp {input} > {output}"
# extract sites
rule somalier_extract:
    input:
        ref=config["params"]["ref"],
        sites="sites.hg38.rna.nochr.vcf.gz",
        dir=config["params"]["dir"],
        bam="{sample}.bam"
    output:
        file="cohort/{sample}.somalier",
    shell:
        "somalier extract --out-dir {input.dir} --sites {input.sites} --fasta {input.ref} {input.bam}; done"

#calculate relatedness on the extracted data:
rule somalier_relate:
    input:
        files=expand("cohort/{sample}.somalier", sample=SAMPLES),
        dir="cohort"
    output:
        "somalier.html"
    shell:
        "somalier relate {input.dir}/*"


