/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (!params.bams) {exit 1, 'Please specify the path to your indexed, mark-dupped bams'}
if (!params.fasta) {exit 1, 'Please specify the path to your indexed fasta'}
if (!params.fai) {exit 1, 'Please specify the path to your fasta index'}

bams = Channel.fromPath(params.bams, checkIfExists: true).map{
    bam -> tuple(bam.baseName, bam, bam+'.bai')
}

fasta = Channel.value(params.fasta)
fai = Channel.value(params.fai)

index_format = Channel.value(params.index_format)
tmpdir = Channel.value(params.tmpdir)

// Local Modules:
include {  downloadRevelio  } from '../modules/local/download_revelio.nf'
include {  calcMD  } from '../modules/local/calc_md.nf'
include {  revelio  } from '../modules/local/revelio.nf'

workflow emseq_variant_calling {
    
    //
    // Module: Download revelio from forked version
    //
     downloadRevelio()
     
    //
    // Module: Calculate MD tags
    //
     calcMD (
        bams,
        fasta,
        index_format
        )

    //
    // Module: Run Revelio to mask possibly converted bases by setting BQ to 0
    //
     revelio (
        calcMD.out.calcmd_bam,
        downloadRevelio.out,
        tmpdir
        )

}

workflow {
    emseq_variant_calling()
}