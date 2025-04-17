process freebayes {
    label 'process_high'
    conda "bioconda::freebayes=1.3.6 bioconda::bcftools=1.21"
    tag "$library"

    input:
    tuple val(library), path(bam), path(bai)
    path(fasta)
    path(fai)
    val(target_bed)

    output:
    tuple val(library), path("*.vcf.gz"), path("*.vcf.gz.tbi"), emit: vcf
    tuple val(library), path("*.flt.vcf.gz"), path("*.flt.vcf.gz.tbi"), emit: filtered_vcf

    script:

    """
    freebayes-parallel <(fasta_generate_regions.py ${fai} 100000) $task.cpus \\
        -f $fasta \\
        $bam \\
        --min-base-quality 1 \\
        > ${library}.vcf

    cat ${library}.vcf | bcftools view -i 'QUAL > $params.freebayes_qual_filter' > ${library}.flt.vcf
    bgzip ${library}.flt.vcf
    tabix ${library}.flt.vcf.gz

    bgzip ${library}.vcf
    tabix ${library}.vcf.gz

    """
}