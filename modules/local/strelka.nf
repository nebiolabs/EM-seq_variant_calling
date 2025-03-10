process strelka {
    label 'process_high'
    conda "bioconda::strelka=2.9.10 conda-forge::python=2.7.15 bioconda::htslib=1.9"
    tag "$library"

    input:
    tuple val(library), path(bam), path(bai)
    path(fasta)
    path(fai)
    val(target_bed)

    output:
    tuple val(library), path("*.strelka_vcf.gz"), path("*.strelka_vcf.gz.tbi"), emit: vcf

    script:

    """
    if [ -f ${target_bed} ]; then
        ln -s ${target_bed} target.bed
        bgzip -c target.bed > target.bed.gz
        tabix -p bed "target.bed.gz"
        target_regions_opt="--callRegions target.bed.gz "
    fi

    configureStrelkaGermlineWorkflow.py \
    --bam "${bam}" \
    --referenceFasta "${fasta}" \
    \$target_regions_opt \
    --runDir strelka 
    # execution on a single local machine with N parallel jobs, sge integration does not work on our cluster
    strelka/runWorkflow.py -m local -j ${task.cpus}

    cp strelka/results/variants/variants.vcf.gz ${library}.strelka_vcf.gz
    cp strelka/results/variants/variants.vcf.gz.tbi ${library}.strelka_vcf.gz.tbi

    """
}