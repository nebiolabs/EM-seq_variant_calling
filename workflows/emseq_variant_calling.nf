/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

if (!params.bams) {exit 1, 'Please specify the path to your indexed, mark-dupped bams'}
if (!params.fasta) {exit 1, 'Please specify the path to your indexed fasta'}
if (!params.fai) {exit 1, 'Please specify the path to your fasta index'}
if (!params.happy_truth_vcf && params.run_happy) {exit 1, 'Please specify the path to the "truth" vcf you would like to compare using happy'}

bams = Channel.fromPath(params.bams, checkIfExists: true).map{
    bam -> tuple(bam.baseName, bam, bam+'.bai')
}

// Reference genome
fasta = Channel.value(params.fasta)
fai = Channel.value(params.fai)

// Revelio options
index_format = Channel.value(params.index_format) // output format, either bai or csi
tmpdir = Channel.value(params.tmpdir)

// Variant calling inputs
target_bed = Channel.value(params.target_bed) // optional

// Hap.py concordance inputs
happy_truth_vcf = Channel.fromPath(params.happy_truth_vcf,  checkIfExists: true)
happy_truth_tbi = Channel.fromPath(params.happy_truth_vcf+'.tbi',  checkIfExists: true)
happy_bed = Channel.value(params.happy_bed)

// Local Modules:
include {  downloadRevelio  } from '../modules/local/download_revelio.nf'
include {  calcMD  } from '../modules/local/calc_md.nf'
include {  revelio  } from '../modules/local/revelio.nf'
include {  strelka  } from '../modules/local/strelka.nf'
include {  freebayes  } from '../modules/local/freebayes.nf'
include {  happyConcordance as happyConcordanceStrelka; 
           happyConcordance as happyConcordanceFreebayes  } from '../modules/local/happy_concordance.nf'
include {  parseHappyVcf  } from '../modules/local/parse_happy_vcf.nf'

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
    
    //
    // Module: Run strelka to call germline variants
    //
    if (params.run_strelka) {
        strelka (
            revelio.out.masked,
            fasta,
            fai,
            target_bed // call regions (optional)
            )
    
    //
    // Module: Run hap.py to compare variants to a "truth" vcf
    //
        if (params.run_happy) {

            happyConcordanceStrelka(
                strelka.out.vcf,
                happy_bed, // comparison regions (optional)
                fasta,
                fai,
                happy_truth_vcf,
                happy_truth_tbi
            )
    
    //
    // Module: Parse hap.py vcf output to break down SNPs by ref/alt bases.
    //
            parseHappyVcf(
                happyConcordanceStrelka.out.vcf,
                happy_bed // analyze breakdown in called regions if provided
            )
        }

    }

    //
    // Module: Run freebayes to call germline variants
    //
    if (params.run_freebayes) {
        freebayes (
            revelio.out.masked,
            fasta,
            fai,
            target_bed // call regions (optional)
            )
        
    //
    // Module: Run hap.py to compare variants to a "truth" vcf
    //
        if (params.run_happy) {

            happyConcordanceFreebayes(
                freebayes.out.filtered_vcf,
                happy_bed, // comparison regions (optional)
                fasta,
                fai,
                happy_truth_vcf,
                happy_truth_tbi
            )
        }
    }
}

workflow {
    emseq_variant_calling()
}