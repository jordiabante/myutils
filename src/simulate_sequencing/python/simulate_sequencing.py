#!/usr/bin/env python

import sys
import re
import numpy as np
from datetime import datetime
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet import IUPAC


####################################################################################################
# Functions
####################################################################################################
# Function: read-in data
def read_fasta(infile):
    fasta_dic = {}
    aux_dic = SeqIO.to_dict(SeqIO.parse(infile,'fasta'))
    for key in aux_dic.keys():
        fasta_dic[key] = str(aux_dic[key].seq)
    return fasta_dic

# Function: sample FASTA
def sample_fasta(fasta_dic,n_reads,read_length):
    # Seed for reproducibility
    np.random.seed(1)
    # Choose entry at random
    ran_entries = np.random.choice(fasta_dic.keys(),size=n_reads); #print ran_entries
    # Choose fragment size at random
    ran_sizes = np.random.negative_binomial(n=150, p=0.5, size=n_reads); #print ran_sizes
    # Generate reads
    pair1 = []
    pair2 = []
    for i in range(0,n_reads):
        # Limit of the start position
        limit = len(fasta_dic[ran_entries[i]]) - max(ran_sizes[i],read_length) - 1
        start = np.random.randint(0, limit)
        end = start + read_length
        # Left pair
        seq1 = Seq(fasta_dic[ran_entries[i]][start:end], IUPAC.unambiguous_dna)
        # Right pair
        start = start + ran_sizes[i] - read_length
        end = start + read_length
        seq2 = Seq(fasta_dic[ran_entries[i]][start:end], IUPAC.unambiguous_dna)
        seq2 = seq2.reverse_complement()
        # Mutate left (C to T mutations through Bernoulli iid)
        ran_mut = np.random.choice(2, size=len(seq1), p=[0.5, 0.5])
        seq = ""
        for j in range(len(seq1)):
            if (seq1[j] == 'C') & (ran_mut[j] == 1):
                seq += 'T'
            else:
                seq += seq1[j]
        seq1 = Seq(seq, IUPAC.unambiguous_dna)
        ran_mut = np.random.choice(2, size=len(seq2), p=[0.5, 0.5])
        seq = ""
        # Mutate right (C to T mutations through Bernoulli iid)
        for j in range(len(seq2)):
            if (seq2[j] == 'C') & (ran_mut[j] == 1):
                seq += 'T'
            else:
                seq += seq2[j]
        seq2 = Seq(seq, IUPAC.unambiguous_dna)
        # Append to respective pair
        pair1.append(SeqRecord(seq1, id = 'EASX:X:X:X:X:%i:%i' % (i,i), description = '1:Y:0:NNNNNN'))
        pair2.append(SeqRecord(seq2, id = 'EASX:X:X:X:X:%i:%i' % (i,i), description = '2:Y:0:NNNNNN'))
        # Add quality score (mean=(pn/1-p)) and max PHRED is 93
        qual1 = np.random.negative_binomial(n=35, p=0.5, size=len(seq1))
        qual1 = np.minimum(qual1,93*np.ones(len(seq1)))
        pair1[i].letter_annotations["phred_quality"] = list(qual1)
        qual2 = np.random.negative_binomial(n=35, p=0.5, size=len(seq2))
        qual2 = np.minimum(qual1, 93 * np.ones(len(seq2)))
        pair2[i].letter_annotations["phred_quality"] = list(qual2)
        # Print for debugging
        # print(pair1[i].upper().format("fastq"))
        # print(pair2[i].upper().format("fastq"))
    # Return pairs
    return pair1,pair2


# Main function
def main():
    # I/Os
    infile = sys.argv[1]
    outdir = sys.argv[2]
    prefix = sys.argv[3]
    n_reads = int(sys.argv[4])
    read_length = int(sys.argv[5])

    # Read FASTA file into dic (should be optimized for large FASTA files)
    print "[{}]: Reading FASTA ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    fasta_dic = read_fasta(infile)

    # Randomly sample genome
    print "[{}]: Sampling FASTA ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    pair1, pair2 = sample_fasta(fasta_dic,n_reads,read_length)

    # Save to file
    print "[{}]: Saving FASTQ files ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    with open(outdir + '/' + prefix + '_R1.fastq', "w") as output_handle:
        SeqIO.write(pair1, output_handle, "fastq")
    with open(outdir + '/' + prefix + '_R2.fastq', "w") as output_handle:
        SeqIO.write(pair2, output_handle, "fastq")

####################################################################################################
main()
