process fetchDeepvariantCheckpoint {
    label 'process_single'
    tag "${model_type}"
    conda 'conda-forge::wget=1.20.3'
    storeDir "${projectDir}/ref_data/deepvariant_checkpoints"
    //
    // Pulls the EM-seq DeepVariant fine-tuned model for the requested --model_type (only WGS and WES) from
    // Zenodo (doi.org/10.5281/zenodo.21416823) and stages it as a checkpoint directory
    //   WGS -> wgs.checkpoint.260717.{data-*,index}
    //   WES -> target_capture.checkpoint.260717.{data-*,index}
    //
    // The output dir contains the checkpoint (.index/.data-*) plus model.example_info.json.
    // DV 1.10.0 inference resolves it by directory: get_model_example_info_json() looks in
    // os.path.dirname(--customized_model) for 'model.example_info.json'

    input:
    val(model_type)

    output:
    tuple val(model_type), path("${label}"), val(prefix), emit: checkpoint

    script:
    def spec = [ WGS: ['wgs',            'wgs.checkpoint.260717'],
                 WES: ['target_capture', 'target_capture.checkpoint.260717'] ][model_type]
    if (!spec)
        error "No EM-seq Zenodo checkpoint for model_type '${model_type}' (only WGS and WES)."
    label  = spec[0]
    prefix = spec[1]
    def base = 'https://zenodo.org/records/21416823/files'
    """
    mkdir -p ${label}

    wget -q -O ${label}/${prefix}.data-00000-of-00001 "${base}/${prefix}.data-00000-of-00001?download=1"
    wget -q -O ${label}/${prefix}.index               "${base}/${prefix}.index?download=1"
    wget -q -O ${label}/model.example_info.json        "${base}/model.example_info.json?download=1"
    """
}

workflow resolveDeepvariantCheckpoint {
    main:
    def mt    = params.deepvariant_model_type
    def valid = ['WGS', 'WES', 'PACBIO', 'ONT_R104', 'HYBRID_PACBIO_ILLUMINA']
    if (!mt)
        error "Please set --deepvariant_model_type (one of: ${valid.join(', ')})."
    if (!(mt in valid))
        error "deepvariant_model_type must be one of ${valid.join(', ')}, got '${mt}'."
    if (params.deepvariant_custom_model && !(mt in ['WGS', 'WES']))
        error "deepvariant_custom_model is only available for WGS and WES — " +
              "model_type '${mt}' has no custom model."

    if (params.run_deepvariant == false) {
        ch_checkpoint = Channel.value([[], '', mt])
    } else if (params.deepvariant_checkpoint) {
        ch_checkpoint = Channel.value([ file(params.deepvariant_checkpoint).parent,
                                        file(params.deepvariant_checkpoint).name,
                                        mt ])
    } else if (params.deepvariant_custom_model) {
        ch_checkpoint = fetchDeepvariantCheckpoint(Channel.value(mt))
            .checkpoint.map { m, dir, prefix -> [dir, prefix, mt] }
    } else {
        ch_checkpoint = Channel.value([[], '', mt])
    }

    emit:
    checkpoint = ch_checkpoint
}
