process happyConcordance {
    label 'process_high'
    conda "bioconda::hap.py=0.3.15"
    publishDir "$params.outdir/happy/", mode: 'copy'
    tag { library }

    input:
    tuple val(library), path(vcf), path(tbi)
    val(truth_bed)
    path(fasta)
    path(fasta_index)
    each path(truth_vcf)
    each path(truth_tbi)
    
    
    output:
    tuple val(library), path("*summary.csv"), emit: summary
    tuple val(library), path("*extended.csv"), emit: extended_summary
    tuple val(library), path("*happy.vcf.gz"), path("*happy.vcf.gz.tbi"), emit: vcf
    
    script:
    def truth_bed_opt = truth_bed ? "-f $truth_bed" : ''
    """

        hap.py  \\
        ${truth_vcf} \\
        ${vcf} \\
        ${truth_bed_opt} \\
        --threads 12 \\
        -r ${fasta} \\
        --write-vcf \\
        -o ${library}_vs_${truth_vcf.baseName}.happy

    """
}