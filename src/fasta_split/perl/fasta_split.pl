#!/usr/bin/env perl
# ------------------------------------------------------------------------------
##The MIT License (MIT)
##
##Copyright (c) 2016 Jordi Abante
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
# ------------------------------------------------------------------------------

# Libraries
use strict;

# Read arguments
my $scriptname=$0;              # Get script name
my $n_seqs=@ARGV[0];            # Number of sequences in fasta file
my $n_files=@ARGV[1];           # Number of files
my $outprefix=@ARGV[2];         # Output files prefix

# Handlers
my $FASTA;                      # Fasta file handler

# Variables
my $n_per_file;                 # Number of sequences per file
my $n=0;                        # Current number of sequences
my $file_id=1;                  # Current file ID
my $outfile;                    # Current ouput file

# Hashes
my %fasta_hash=();              # Hash containing sequence info of each sample

################################ Main #########################################

# Compute sequeces for file
$n_per_file=int($n_seqs/$n_files);
# New file
$outfile="${outprefix}_${file_id}.fa";
# Open output file
open(OUT,">$outfile") or die "Can't open file '${outfile}' $!";

# Read in STDIN
while(my $line=<STDIN>)
{
    chomp($line);
    # Increment counter if fasta entry
    if( $line =~ />/)
    {   
        $n++;
    }
    # Check current number of sequences in file
    if($n eq $n_per_file+1)
    {
        # Close handler
        close OUT;
        # Update variables
        $n=1;
        $file_id++;
        # New file
        $outfile="${outprefix}_${file_id}.fa";
        # Open output file
        open(OUT,">$outfile") or die "Can't open file '${outfile}' $!";
        # Print line
        print OUT "$line\n";
    }
    else
    {
        # Print line
        print OUT "$line\n";
    }
}   

##############################################################################
