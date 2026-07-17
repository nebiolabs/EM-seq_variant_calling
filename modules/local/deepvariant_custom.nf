process deepvariantCustom {
    label 'process_high'
    tag "$library"
    container "docker.io/google/deepvariant:1.10.0"
    publishDir "${params.outdir}/deepvariantCustom", mode: params.publish_dir_mode
    // For running a custom model the checkpoint directory must contain:
    //   - checkpoint files (.index, .data-*)
    //   - model.example_info.json  (required by DV 1.10.0 )

    input:
    tuple val(library), path(bam), path(bai)
    path(fasta)
    path(fai)
    tuple path(checkpoint_dir), val(checkpoint_name), val(model_type)

    output:
    tuple val(library), path("${library}.deepvariant.vcf.gz"),
          path("${library}.deepvariant.vcf.gz.tbi"), emit: vcf

    script:
    def custom_model_opt = checkpoint_name
        ? "--customized_model ${checkpoint_dir}/${checkpoint_name} --disable_small_model"
        : ''
    """
    export TMPDIR=/tmp

    run_deepvariant \\
        --model_type ${model_type} \\
        ${custom_model_opt} \\
        --ref ${fasta} \\
        --reads ${bam} \\
        --output_vcf ${library}.deepvariant.vcf.gz \\
        --num_shards ${task.cpus} \\

    """
}
