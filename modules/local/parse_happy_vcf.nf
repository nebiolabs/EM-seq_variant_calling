process parseHappyVcf {
    label 'process_single'
    publishDir "$params.outdir/happy/", mode: 'copy'
    tag { library }

    input:
    tuple val(library), path(vcf), path(vcf_index)
    val(happy_bed)
    
    output:
    tuple val(library), path("*snp_mutations.txt")
    
    script:
    // outputs a text file with the Count, Reference allele, Alternate allele, and Type
    // Type can be: Correct, Incorrect, Missed, MissedNoPass
        // Incorrect: a call with a different genotype was made
        // Missed: no call was made for that alt/ref.
        // NotPassed: a correct call was made but it did not pass the default strelka quality filter
    def regions_opt = happy_bed ? 'grep "CONF" |' : ''
    """
    echo "Count Ref Alt Type" > ${library}.happy.snp_mutations.txt

    declare -A types
    types["Correct"]="grep TP | grep -v NoPass"
    types["Incorrect"]="grep FN | grep -v NoPass | grep -v NOCALL"
    types["Missed"]="grep FN | grep -v NoPass | grep NOCALL"
    types["NotPassed"]="grep TP | grep NoPass"

    for type in "\${!types[@]}"; do
        result=\$(zcat ${vcf} | grep "SNP" | ${regions_opt} eval "\${types[\$type]}" 2>/dev/null || true)
        if [[ -n "\$result" ]]; then
            echo "Processing type: \$type"
            echo "\$result" | awk -v FS='\t' -v OFS=' ' -v type="\$type" '{print \$4, \$5, type}' | \
            sort | uniq -c | sed 's/^[ \t]*//' >> ${library}.happy.snp_mutations.txt
        else
            echo "No matches for type: \$type"
        fi
    done

    """
}
// echo "Count Ref Alt Type" > !{library}.happy.snp_mutations.txt

//     if [[ -n "!{happy_bed}" ]]; then
//         regions_opt='grep "CONF" |'
//     else
//         regions_opt=''
//     fi

//     zcat *.vcf.gz | grep "SNP" | $regions_opt grep -v NoPass | grep TP |\
//     awk -v FS='\t' -v OFS=' ' '{print \$4, \$5, "Correct"}' \
//     | sort | uniq -c |sed 's/^[ \\t]*//' >> !{library}.happy.snp_mutations.txt

//     zcat *.vcf.gz | grep "SNP" | $regions_opt grep -v NoPass | grep FN | grep -v NOCALL |\
//     awk -v FS='\t' -v OFS=' ' '{print \$4, \$5, "Incorrect"}' \
//     | sort | uniq -c |sed 's/^[ \\t]*//' >> !{library}.happy.snp_mutations.txt

//     zcat *.vcf.gz | grep "SNP" | $regions_opt grep -v NoPass | grep FN | grep NOCALL |\
//     awk -v FS='\t' -v OFS=' ' '{print \$4, \$5, "Missed"}' \
//     | sort | uniq -c |sed 's/^[ \\t]*//' >> !{library}.happy.snp_mutations.txt

//     zcat *.vcf.gz | grep "SNP" | $regions_opt grep NoPass | grep TP |\
//     awk -v FS='\t' -v OFS=' ' '{print \$4, \$5, "Missed"}' \
//     | sort | uniq -c |sed 's/^[ \\t]*//' >> !{library}.happy.snp_mutations.txt