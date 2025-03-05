process downloadRevelio {
    label 'process_single'
    conda 'conda-forge::jq=1.7 conda-forge::wget=1.20.3 conda-forge::unzip=6.0'
    storeDir 'ref_data'

    output:
    path("revelio.py")

    script:
    '''
    wget https://raw.githubusercontent.com/bwlang/revelio/59978f2daff48441e7062963502247b21360cc46/revelio.py
    '''
}
