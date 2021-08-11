#!/usr/bin/perl
use strict;
use warnings;

my $usage = "perl $0 <IN1> <IN2> <OUT>
<IN1> sample.2.fq.gz, readsnumber1<readsnumber2
<IN2> *_1.undef.TACTCT.fq.gz
<OUT> sample.1.fq.gz";
die $usage unless @ARGV==3;
my (%hash,$b,$c,$d);
#use PerlIO::gzip;
open OUT,"| gzip -c > $ARGV[2]" or die $!;
open IN1,"gzip -dc $ARGV[0] |" or die $!;
while (<IN1>)
	{
	 chomp;
	 my $line1 = $_;
	 chomp(my $line2=<IN1>);
	 chomp(my $line3=<IN1>);
	 chomp(my $line4=<IN1>);
	 my @a = split /\s+/,$line1;
	 $hash{$a[0]} = 1;
	}
close IN1;

open IN2,"gzip -dc $ARGV[1] |" or die $!;
while (<IN2>)
	{
	 chomp;
	 my @a = split;
	 $b = <IN2>;
	 $c = <IN2>;
	 $d = <IN2>;
	 next if (not exists $hash{$a[0]});
	 if (exists $hash{$a[0]})
		{
		 print OUT "$_\n$b$c$d";
		}
	}
close IN2;
