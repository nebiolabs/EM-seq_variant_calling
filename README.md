# Variant calling with EM-seq data
This pipeline can be used to do germline variant calling on EM-seq libraries. Because of enzymatic conversion for detecting methylated Cs, T's at C positions (or As aligned to the G opposite the C) must be masked prior to variant calling or they will result in artifical calls.

We utilize the tool Revelio in this pipeline, which allows us to pre-process our aligned bams for use with conventional variant callers.

Nunn A, Otto C, Fasold M, Stadler PF, Langenberger D. Manipulating base quality scores enables variant calling from bisulfite sequencing alignments using conventional bayesian approaches. BMC Genomics. 2022 Jun 28;23(1):477. doi: 10.1186/s12864-022-08691-6. PMID: 35764934; PMCID: PMC9237988.