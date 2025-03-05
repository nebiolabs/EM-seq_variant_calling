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

// Modules:
include {  downloadRevelio  } from '../modules/local/download_revelio.nf'
include {  calcMD  } from '../modules/local/calc_md.nf'

workflow emseq_variant_calling {
    
     downloadRevelio()
     calcMD(
        bams,
        fasta,
        index_format
     )

}

workflow {
    emseq_variant_calling()
}