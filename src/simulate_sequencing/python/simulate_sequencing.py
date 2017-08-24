#!/usr/bin/env python

########################################################################################################################
# Dependencies
########################################################################################################################
import sys
import re
import gzip
import numpy as np
from datetime import datetime
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.Alphabet import IUPAC


########################################################################################################################
# Functions
########################################################################################################################
# Function: read-in data
def read_fasta(infile):
    fasta_dic = {}
    aux_dic = SeqIO.to_dict(SeqIO.parse(infile,'fasta'))
    for key in aux_dic.keys():
        fasta_dic[key] = str(aux_dic[key].seq)
    return fasta_dic

# Function: sample FASTA
def sample_fasta(fasta_dic,n_reads,read_length,frag_size,seed):
    ####################################################################################################################
    # Refer to the manual in:
    #   http://resources.qiagenbioinformatics.com/manuals/bisulfite-sequencing/
    # for details on OT and OB.
    ####################################################################################################################
    # Seed for reproducibility
    np.random.seed(seed)
    # Choose entry at random
    ran_entries = np.random.choice(fasta_dic.keys(),size=n_reads); #print ran_entries
    # Choose fragment size at random (later capped with read_length)
    ran_sizes = np.random.negative_binomial(n=frag_size,p=0.5,size=n_reads); #print ran_sizes
    # Choose OT (0) or OB (1) at random for all reads
    ot_or_ob = np.random.choice(2,size=n_reads); #print ot_or_ob
    # Generate reads
    pair1 = []; pair2 = []
    for i in range(0,n_reads):
        # Limit of the start position of fragment and impose minimum size equal to read length
        limit = len(fasta_dic[ran_entries[i]]) - max(ran_sizes[i], read_length) - 1
        start = np.random.randint(0, limit)
        end = start + max(ran_sizes[i],read_length)
        fragment = Seq(fasta_dic[ran_entries[i]][start:end], IUPAC.unambiguous_dna)
        # Choose OT (0) or OB (1)
        if ot_or_ob[i]==1:
            fragment = fragment.reverse_complement()
        # Mutate fragment (C to T mutations Bernoulli iid)
        ran_mut = np.random.choice(2, size=len(fragment), p=[0.5, 0.5])
        seq = ""
        for j in range(len(fragment)):
            if (fragment[j] == 'C') & (ran_mut[j] == 1):
                seq += 'T'
            else:
                seq += fragment[j]
        fragment = seq
        # Read 1: left to right on OT or OB. Since we have taken reverse complement, start will be 0 and end will be
        # read length in both cases
        seq1 = Seq(fragment[0:read_length], IUPAC.unambiguous_dna)
        # Read 2: on OT or OB, start at the end minus read length, extend until fragment end, and reverse complement
        # sequence obtained to simulate ctOT or ctOB
        seq2 = Seq(fragment[(len(fragment)-read_length):len(fragment)], IUPAC.unambiguous_dna).reverse_complement()
            # print len(fragment),fragment; print len(seq1),seq1; print len(seq2),seq2
        # Append to respective pair
        pair1.append(SeqRecord(seq1, id = 'EASX:X:X:X:X:%i:%i' % (i,i), description = '1:Y:0:NNNNNN'))
        pair2.append(SeqRecord(seq2, id = 'EASX:X:X:X:X:%i:%i' % (i,i), description = '2:Y:0:NNNNNN'))
        # Add quality score (mean=(pn/1-p)=35) and max PHRED is 93
        qual1 = np.random.negative_binomial(n=35, p=0.5, size=len(seq1))
        qual1 = np.minimum(qual1, 93 * np.ones(len(seq1)))
        pair1[i].letter_annotations["phred_quality"] = list(qual1)
        qual2 = np.random.negative_binomial(n=35, p=0.5, size=len(seq2))
        qual2 = np.minimum(qual1, 93 * np.ones(len(seq2)))
        pair2[i].letter_annotations["phred_quality"] = list(qual2)
        # Print for debugging
        # print(pair1[i].upper().format("fastq")); print(pair2[i].upper().format("fastq"))
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
    frag_size = int(sys.argv[6])
    seed = int(sys.argv[7])

    # Read FASTA file into dic (should be optimized for large FASTA files)
    print "[{}]: Reading FASTA ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    fasta_dic = read_fasta(infile)

    # Randomly sample genome
    print "[{}]: Sampling FASTA ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    pair1, pair2 = sample_fasta(fasta_dic,n_reads,read_length,frag_size,seed)

    # Save to file
    print "[{}]: Saving & compressing FASTQ files ...".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
    with gzip.open(outdir + '/' + prefix + '_R1.fastq.gz', "w") as output_handle:
        SeqIO.write(pair1, output_handle, "fastq")
    with gzip.open(outdir + '/' + prefix + '_R2.fastq.gz', "w") as output_handle:
        SeqIO.write(pair2, output_handle, "fastq")

    # Done
    print "[{}]: Done.".format(datetime.now().strftime('%Y-%m-%d %H:%M:%S'))
########################################################################################################################
main()
