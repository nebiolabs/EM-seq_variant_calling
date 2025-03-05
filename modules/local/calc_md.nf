process calcMD {
    label 'process_low'
    conda 'bioconda::samtools=1.21'

    input:
    tuple val(library), path(bam), path(index)
    path(genome)
    val(index_format)

    output:
    tuple val(library), path("*.calcmd.bam"), path("*.calcmd.bam.${index_format}"), emit: calcmd_bam

    script:
    """
    samtools calmd -Q -u ${bam} ${genome} | samtools view -@ ${task.cpus} -b --write-index -o ${library}.calcmd.bam##idx##${library}.calcmd.bam.${index_format}
    """
}
