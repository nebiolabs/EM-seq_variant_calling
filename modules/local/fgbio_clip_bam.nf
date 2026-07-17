process fgbioClipBam {
    cpus 6
    memory '100 GB'
    conda "bioconda::fgbio=3.1.2 bioconda::samtools=1.19"
    publishDir "${params.outdir}/clipped_bams/", mode: 'symlink'
    tag { sample_id }

    input:
    tuple val(sample_id), path(bam), path(bai)

    output:
    tuple val(sample_id), path("${sample_id}.clipped.bam"), path("${sample_id}.clipped.bam.bai")

    script:
    """
    export _JAVA_OPTIONS="-Xmx90g"
    samtools sort -n -u -@ ${task.cpus} ${bam} | \\
        fgbio ClipBam \\
        --input /dev/stdin \\
        --output /dev/stdout \\
        --ref ${params.fasta} \\
        --clip-overlapping-reads true \\
        --clipping-mode Hard \\
        --sort-order Coordinate | \\
    samtools view -b -@ ${task.cpus} -o ${sample_id}.clipped.bam

    samtools index ${sample_id}.clipped.bam
    """
}
