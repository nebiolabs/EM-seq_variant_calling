process deepvariantCustom {
    label 'process_high'
    tag "$library"
    container "docker.io/google/deepvariant:1.10.0"
    publishDir "${params.outdir}/deepvariantCustom", mode: params.publish_dir_mode
    //
    // Runs run_deepvariant, optionally with a fine-tuned checkpoint.
    //
    // When params.deepvariant_checkpoint is set, uses that checkpoint with
    // --customized_model and --disable_small_model (required in DV 1.10.0).
    // When null, runs with the standard built-in WGS model.
    //
    // The checkpoint directory must contain:
    //   - checkpoint files (.index, .data-*)
    //   - model.example_info.json  (required by DV 1.10.0 inference)

    input:
    tuple val(library), path(bam), path(bai)
    path(fasta)
    path(fai)
    path(checkpoint_dir)   // staged dir with .index/.data-*/model.example_info.json; pass [] when unused
    val(checkpoint_name)   // checkpoint prefix e.g. "checkpoint-16896-0.97789-1"; pass '' when unused

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
        --model_type WGS \\
        ${custom_model_opt} \\
        --ref ${fasta} \\
        --reads ${bam} \\
        --output_vcf ${library}.deepvariant.vcf.gz \\
        --num_shards ${task.cpus} \\

    """
}
