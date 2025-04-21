# Variant calling with EM-seq data
This pipeline can be used to do germline variant calling on EM-seq libraries. Methylation information is preserved on only one strand in EM-seq libraries, while the other strand can be used to detect genetic variation. Because of enzymatic conversion for detecting methylated Cs, C-to-T observations can result from either an unmethylated cytosine or a SNP. Bases that may have come from C-to-T conversion must be masked prior to variant calling or they will result in artifical calls. Additionally, mutations from any base to a C can be altered by enzymatic C-to-T conversion. This also applies in G-to-A context as Cs will occurr opposite Gs. Bases which could be the result of either conversion or mutation are set to the reference base and their base quality assigned to 0, so that they can be ignored for variant calling. 

Example masking scenarios. A. Without masking the variant caller would interpret an unmethylated C as a heterozygous C>T SNP. B. Mutations from any base to a C may be altered by C-to-T conversion. 

<p align="center"><img width="612" alt="image" src="https://github.com/user-attachments/assets/98c581c6-f597-4e13-9f3a-d7f4aeca6b3a" />
</p>

We utilize the tool [Revelio](https://github.com/bio15anu/revelio/blob/main/README.md)<sup>1</sup> in this pipeline, which allows us to pre-process our aligned bams for use with conventional variant callers.
<img width="2006" alt="image" src="https://github.com/user-attachments/assets/2cdea175-3318-4957-a8a0-58eb6d413874" />


1. Nunn A, Otto C, Fasold M, Stadler PF, Langenberger D. Manipulating base quality scores enables variant calling from bisulfite sequencing alignments using conventional bayesian approaches. BMC Genomics. 2022 Jun 28;23(1):477. doi: 10.1186/s12864-022-08691-6. PMID: 35764934; PMCID: PMC9237988.
2. File type graphics: James A. Fellows Yates, Maxime Garcia, Louis Le Nézet & nf-core; under a CC0 license (public domain)
