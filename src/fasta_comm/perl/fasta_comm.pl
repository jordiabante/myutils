#!/usr/bin/perl

use strict;
use warnings;

# Arguments
my ($fasta_file1,$fasta_file2,$delim,$outfile) = @ARGV;

# Global Variables
my $st_time;
my $current_time;
my $n_entries=0;

# Main
$st_time = localtime;
print STDERR "[${st_time}]: Getting IDs from: ${fasta_file1}\n";
my %ids=get_ids();
$current_time = localtime;
print STDERR "[${current_time}]: Total entries $n_entries\n";
print STDERR "[${current_time}]: Crossing IDs with: ${fasta_file2}\n";
filter_fasta(%ids);
$current_time = localtime;
print STDERR "[${current_time}]: Saving output in: ${outfile}\n";

# Geat IDs from fasta_file1
sub get_ids
{
    my %ids;
    my $entry;
    open (FASTA,$fasta_file1) or die "Can't open fasta file: $!";
    foreach my $line (<FASTA>)
    {   
        chomp($line);
        if( $line =~ m|^>(.*?${delim}).*$|)
        {   
            $ids{$1} = 1;
        }   
    }   
    $n_entries=scalar keys %ids;
    return %ids;
    close FASTA;
}

# Filter IDs in fasta_file2
sub filter_fasta 
{
    # Function input
    my (%ids) = @_;
    # Open target file
    open (FASTA,$fasta_file2) or die "Can't open fasta file: $!";
    # Loop through the second file
    while (<FASTA>) 
    {
        if (m|^>(.*?${delim}).*$|)
        {
            my $id = $1;
            # Remove the end designator from paired end reads
            my $seq = <FASTA>;
            if (exists $ids{$id}) 
            {
                print STDOUT $_,$seq;
            }
        }
        else
        {
            warn "Line '$_' should have been an id line, but wasn't\n";
        }

    }
    close FASTA;

}
