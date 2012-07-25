#!/usr/bin/perl
#
# -*- CPerl -*-
#

use strict;
use warnings;
#use utf8;
use Encode::Guess qw/7bit-jis euc-jp shiftjis utf8/;
use Data::Dumper;
use IO::File;
use Email::MIME;

my $filename = shift @ARGV;
die "no filename" unless $filename;

my $fh;
open($fh, "< $filename");
my $text = '';
while (<$fh>) { $text .= $_; }
close($fh);
$text = Encode::decode("Guess", $text);
my $email = Email::MIME->new($text);
print Dumper($email);

exit 0;

