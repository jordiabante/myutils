#!/usr/bin/perl

use strict;
use List::Util qw(shuffle);

# Arguments
my $N = @ARGV[0];
my $perc = @ARGV[1];

# Global Variables
my $Nout=0;
my $pos=0;
my $i=0;
my $total=0;
my @sorted=();
my $st_time;
my $current_time;

# Main
$st_time = localtime;
print STDERR "[${st_time}]: Generating random IDs\n";
generate_array();
$current_time = localtime;
print STDERR "[${current_time}]: Sampling from FASTA file\n";
read_fasta();


# Subs
sub read_fasta
{
    my $entry;
    foreach my $line (<STDIN>)
    {   
        chomp($line);
        if( $line =~ />/)
        {   
            $entry=substr($line,1); # Get rid of leading ">" character
            $pos++;
        }   
        elsif($pos == $sorted[$i])
        {   
            print ">$entry\n$line\n";
            $total++;
            $i++;
        }   
        if($total == $Nout)
        {
            $current_time = localtime;
            print STDERR "[${current_time}]: Saving output\n";
            exit 0
        }
    }   
}

# Sub to generate random number series
sub generate_array
{
    my @tmp = shuffle 1..${N};
    $Nout=$N * $perc;
    my @random=@tmp[0..$Nout-1];    
    @sorted = sort { $a <=> $b } @random;
#    foreach (@sorted)
#    {
#        print STDERR "$_\n";
#    }
}
