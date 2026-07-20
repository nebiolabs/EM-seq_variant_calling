# Variant calling with EM-seq data
This pipeline can be used to call germline variants in EM-seq libraries. Methylation information is contained on only one strand in EM-seq libraries, while the other strand can be used to detect genetic variation. Because of enzymatic conversion for detecting methylated Cs, C-to-T observations can result from either an unmethylated cytosine or a SNP. Bases that may have come from C-to-T conversion must be masked prior to variant calling or they will result in artifical calls. Additionally, mutations from any base to a C can be altered by enzymatic C-to-T conversion. This also applies in G-to-A context as Cs will occurr opposite Gs. Bases which could be the result of either conversion or mutation are set to the reference base and their base quality assigned to 0, so that they can be ignored for variant calling. 

Example masking scenarios. A. Without masking, the variant caller would interpret an unmethylated C as a heterozygous C>T SNP. B. Mutations from any base to a C, e.g. T>C, may be altered by C-to-T conversion. 

<p align="center"><img width="650" alt="image" src="https://github.com/user-attachments/assets/98c581c6-f597-4e13-9f3a-d7f4aeca6b3a" />
</p>

We utilize the tool [Revelio](https://github.com/bio15anu/revelio/blob/main/README.md)<sup>1</sup> in this pipeline, which allows us to pre-process our aligned bams for use with conventional variant callers. We have also trained custom [DeepVariant models](https://nam10.safelinks.protection.outlook.com/?url=https%3A%2F%2Fzenodo.org%2Frecords%2F21416823&data=05%7C02%7Clblum%40neb.com%7C7eaa19bc1a7f44abded808dee45567d1%7C77cefbc6b3d64d6a9f740664881c384b%7C0%7C0%7C639199253068273777%7CUnknown%7CTWFpbGZsb3d8eyJFbXB0eU1hcGkiOnRydWUsIlYiOiIwLjAuMDAwMCIsIlAiOiJXaW4zMiIsIkFOIjoiTWFpbCIsIldUIjoyfQ%3D%3D%7C0%7C%7C%7C&sdata=XreGjEwqGnt6xlUoH6jv7X7qsbHB70oRIn6zgGwCjYc%3D&reserved=0) using NA12878 EM-seq libraries with unconverted libraries as a truth set for use with the WGS and WES modes. Results from germline calling for whole genome and target capture NA12878 libraries can be found in the poster below. 

<img width="3000" height="450" alt="variant calling workflow" src="https://github.com/user-attachments/assets/06b4e1d1-6ce7-4348-a437-d7943e60fd0a" />

<img width="3000" height="3833" alt="EM-seqVariantCalling_deepvariant_20260716" src="https://github.com/user-attachments/assets/8680b609-3bc5-4315-bffb-3fed468d0ae7" />

1. Nunn A, Otto C, Fasold M, Stadler PF, Langenberger D. Manipulating base quality scores enables variant calling from bisulfite sequencing alignments using conventional bayesian approaches. BMC Genomics. 2022 Jun 28;23(1):477. doi: 10.1186/s12864-022-08691-6. PMID: 35764934; PMCID: PMC9237988.
2. File type graphics: James A. Fellows Yates, Maxime Garcia, Louis Le Nézet & nf-core; under a CC0 license (public domain)
