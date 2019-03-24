#!/usr/bin/env bash

# ----------------------------------------
# File            : fas-to-vcf.sh
# Author          : Tony Fung
# Date            : March 21, 2019
# Description     : Batch convert FAS files to VCF files
# Requirements    : samtools 1.9, bcftools 1.9, bwa 0.7.12
# Input           : 1 reference file, 1 case-sensitive format of sequence files, up to 7 sequence id's
# Command         : bash fas-to-vcf.sh ref.fasta fastq ERR221622 ERR221661 ERR221662 ERR221663
# Output          : up to 7 VCF files
# ----------------------------------------

if [ $# -lt 3 ]
then
  echo "Usage: bash $0 <ref_file> <format_of_sequence_files> <sequence_id> [<sequence_id_2> <sequence_id_3> etc.]";
  exit;
fi

for arg
do

  if [ $arg == $1 ]
  then
    ref_file="../$1";
  elif [ $arg == $2 ]
  then
    file_format=$2;
  else
    seq_id=$arg;
    fas_file_1="${seq_id}_1.$file_format";
    fas_file_2="${seq_id}_2.$file_format";

    pwd;
    cd $seq_id;
    pwd;

    # Index nucleotide file:
    bwa index $ref_file;

    # Align:
    bwa mem $ref_file $fas_file_1  $fas_file_2 > $seq_id.sam

    # BAM output:
    samtools view -b $seq_id.sam > $seq_id.bam

    # Sort & index BAM file:
    samtools sort $seq_id.bam -o $seq_id.sorted.bam
    samtools index $seq_id.sorted.bam

    # Generate VCF file:
    # -u is deprecated, use bcftools mpileup instead
    # samtools mpileup -uf $ref_file $seq_id.sorted.bam > $seq_id.mpileup
    bcftools mpileup -f $ref_file $seq_id.sorted.bam > $seq_id.mpileup
    bcftools call -c -v $seq_id.mpileup > $seq_id.raw.vcf

    cd ..;
    pwd;
  fi

done
