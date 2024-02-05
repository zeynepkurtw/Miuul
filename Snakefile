'''
This is a snakemake file for Miuul Bioinforamtics Bootcamp projects.
© Copyright 2024 Zeynep Akdeniz
'''
rule all:
    input:
        #"output/tRNA_scan_result.txt",
        #"output/G_intestinalis.tRNA",
        #expand("output/tRNAscan/{sp}.tRNA", sp=["G_muris", "G_intestinalis"]),
        #expand("output/blastn/G_intestinalis/{sp}.blastn",sp=["G_muris", "S_salmonicida"]),
        expand("output/orthofinder/{genome}.fasta", genome=["G_muris_aa", "G_intestinalis_aa", "S_salmonicida_aa"]),

rule tRNAscan:
   input: "resource/genome/G_intestinalis.fasta"
   output:"output/tRNA_scan_result.txt"
   conda: "env/env.yaml"
   shell: """tRNAscan-SE {input} -o {output}"""

rule tRNAscan_stats:
    input:
            genome= "resource/genome/G_intestinalis.fasta"
    output:
            tRNA = "output/G_intestinalis.tRNA",
            stats = "output/G_intestinalis.stats"
    params:
          threads=2
    conda:
         "env/env.yaml"
    script:
         "scripts/2_BioinformaticsTools/tRNAscan_stats.py"

rule tRNAscan_stats_wildcard:
    input:
        genome="resource/genome/{genome}.fasta"
    output:
        tRNA="output/tRNAscan/{genome}.tRNA",
        stats="output/tRNAscan/{genome}.stats"
    params:
        threads=2
    conda:
        "env/env.yaml"
    script:
        "scripts/2_BioinformaticsTools/tRNAscan_stats.py"

rule makeblastdb:
    input:
        "resource/{type}/db/{db}.fasta"
    output:
        "output/{type}/db/{db}.ndb",
        "output/{type}/db/{db}.nhr",
        "output/{type}/db/{db}.nin",
        "output/{type}/db/{db}.not",
        "output/{type}/db/{db}.nsq",
        "output/{type}/db/{db}.ntf",
        "output/{type}/db/{db}.nto"
    params:
        outname="output/{type}/db/{db}"

    shell:
        'makeblastdb -dbtype nucl -in {input} -out {params.outname}'

rule blastn:
    input:
        query = "resource/{type}/query/{query}.fasta",
        db = "output/{type}/db/{db}.ndb"
    output:
          'output/{type}/{db}/{query}.blastn'
    params:
          perc_identity=95,
          outfmt=6,
          num_threads=2,
          max_target_seqs=1,
          max_hsps=1,
          db_prefix="output/{type}/db/{db}"
    conda:
        "env/env.yaml"
    script:
          "scripts/2_BioinformaticsTools/blastn.py"

rule orthofinder:
    input:
        fasta = "resource/orthofinder/{genome}.fasta",
    output:
          directory('output/orthofinder/')
    conda:
        "env/env.yaml"
    script:
          "scripts/2_BioinformaticsTools/orthofinder.py"

rule barrnap:
    input:
        genome = "resource/14_barRNAp/{genome}.fasta"
    output:
        barrnap_gff = "output/barrnap/{genome}_rrna_count.gff"

    conda: "env/hinflata.yaml"

    shell:
        """barrnap --kingdom euk --quiet {input.genome} > {output.barrnap_gff}"""