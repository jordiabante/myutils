#!/usr/bin/perl

use strict;
use List::Util qw(shuffle);

# Arguments
my $min_cov = @ARGV[0];

# Global Variables
my $st_time;
my $current_time;

# Main
$st_time = localtime;
print STDERR "[${st_time}]: Processing coverage file ...\n";
coverage_summary();
$current_time = localtime;
print STDERR "[${current_time}]: Saving summary ...\n";

# Subs
sub coverage_summary
{
    my $sum=0;
    foreach my $line (<STDIN>)
    {   
        chomp($line);
        if( $line =~ /genome/)
        {
            my @entry = split(/\s+/,$line);
            if($entry[1] >= $min_cov)
            {
                $sum+=$entry[4];
            }
        }
    }   
    # Print sum
    print STDOUT "$sum\n";
}

