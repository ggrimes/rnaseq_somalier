# rnaseq_somalier
Perform genotype check on human RNA-Seq bam files to detect sample swaps.

## pre-requists

* [snakemake](https://snakemake.readthedocs.io/en/stable/)
* [somalier](https://github.com/brentp/somalier/releases/tag/v0.2.10)


# Example Run

```
snakemake --dry-run -p -s run.yml
```
