process revelio {
    label 'process_extra_high'
    conda 'bioconda::pysam=0.23.0 conda-forge::python=3.12 bioconda::samtools=1.21'
    tag "$library"

    input:
    tuple val(library), path(bam), path(bam_index)
    path(revelio)
    path(tmpdir)

    output:
    tuple val(library), path("*.masked.bam"), path("*.masked.bam.bai"), emit: masked

    script:
    """   
    python ${revelio} -Q -t /tmp -T ${task.cpus} ${bam} ${library}.masked.bam
    samtools index -@ ${task.cpus} "${library}.masked.bam"
    """
}