#!/usr/bin/perl
use strict;
use warnings;
no strict 'refs';

use PerlIO::gzip;
my $usage = "perl $0 IN1.gz IN2.gz IN3.gz IN4.gz ... OUT1.gz OUT2.gz...OUTx.gz
<IN1>:fq
<IN2>:(start pos 0-base /base number before matching with regular expression)5
<IN3>:GGTCTT
<IN4>:TCTGGT
...
<OUT1>:fq
<OUT2>:fq
...
<OUTx>:fq(has no id)";


my ($n,$file,$i,$out,$j,$line1,$line2,$line3,$line4,$temp,$m,$error,$lengthb);
die $usage unless @ARGV >=3;
$n = @ARGV;
$file = ($n - 3)/2;

open IN1,"gzip -dc $ARGV[0] |" or die $!;
#open IN1,"<gzip","$ARGV[0]" or die $!;
for($i=$file + 3 - 1;$i<=$n - 1;$i++)
        {
         $out = "OUT".$i;#$out bu gu ding
         open $out,"| gzip -c > $ARGV[$i].2.fq.gz" or die $!;
#         open $out,">gzip","$ARGV[$i].2.fq.gz" or die $!;
         }
while (<IN1>)
        {
         $j = 0;
         $line1 = $_;
         $line2 = <IN1>;
         $line3 = <IN1>;
         $line4 = <IN1>;
         for($i=3 - 1;$i<=$file + 2 - 1;$i++) # regular expresion of every barcode and the sequence, i is the barcode number
                {
                 $lengthb = length($ARGV[$i]); # $lengthb is the length of the barcode
#                my @b = split(//,$ARGV[$i]); # @b is the sequece of barcode
#                my $seq = substr($line2,$ARGV[$i],$lengthb); # $seq--sequence of input file which is going to compare with barcode sequence
                 $m = 0;
                 $error = 0;
                 while ($m <= $lengthb - 1)
                        {
                         if (substr($ARGV[$i],$m,1) ne substr($line2,$ARGV[1]+$m,1))
                                {
                                 $error ++;
                                }
                         $m ++;
                        }
                 if ($error < 1) # 2 is the max error number
                        {
                         $temp = $i + $file;
                         $out = "OUT".$temp;# $ARGV[$temp] is outfile
                         print $out "$line1$line2$line3$line4";
                         $j = $file + 1;
                        }
                 $j ++;
                 if ($j eq $file)
                        {
                         $temp = $n - 1;
                         $out = "OUT".$temp;
                         print $out "$line1$line2$line3$line4";
                        }
                }

        }
for($i=$file + 3 - 1;$i<=$n - 1;$i++)
        {
         $out = "OUT".$i;
         close $out;
        }
