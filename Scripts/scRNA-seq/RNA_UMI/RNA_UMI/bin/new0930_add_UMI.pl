#!/usr/bin/perl -w
use strict;
use PerlIO::gzip;

my $usage = "perl $0 IN1.R1.fq.gz IN2.R2.fq.gz OUT1.UMI.fq.gz
<IN1>:R1
<IN2>:R2
<OUT1>:UMI";

die $usage unless @ARGV==3;

open IN_1,"gzip -dc $ARGV[0] |" or die $!;
open IN_2,"gzip -dc $ARGV[1] |" or die $!;
#open OUT_1,"|gzip -c >$ARGV[2]" or die $!;
open OUT_1,">:gzip","$ARGV[2]" or die $!;

    #---------------------------read in the reads information-----------------------#

while (1) {

    #-get the reads and corresponding information in each 4 lines
    
    my $line1_1 = <IN_1>;
    my $line1_2 = <IN_1>;
    my $line1_3 = <IN_1>;
    my $line1_4 = <IN_1>;
    
    my $line2_1 = <IN_2>;
    my $line2_2 = <IN_2>;
    my $line2_3 = <IN_2>;
    my $line2_4 = <IN_2>;
    
    #check the end of the file
    
    last unless (defined($line1_1) and defined($line2_1));
    chomp ($line1_1,$line1_2,$line1_3,$line1_4,$line2_1,$line2_2,$line2_3,$line2_4);
    
    #count the total reads number && get the length of the first read
    
    my $seq_UMI = grep_UMI($line2_2);
    $line1_1 = "\@$seq_UMI\_$line1_1";


            print OUT_1 "$line1_1\n$line1_2\n$line1_3\n$line1_4\n";
}

sub grep_UMI {
    my ($seq) = @_;
    return substr($seq, 8, 8);
}

close IN_1;
close IN_2;
close OUT_1;

