#!/usr/bin/perl
# -*- CPerl -*-
#

use strict;
use warnings;
use IO::Handle;

my $query = shift @ARGV;
die "no query" unless $query;
my $dbfile = shift @ARGV;
die "no db file" unless $dbfile;

my $fh;
open($fh, "-|", "groonga", $dbfile, "select", "--table", "Fields", "--query", 'body:@'.$query);
binmode($fh, ":utf8");
my $text = "";
while (<$fh>) { $text .= $_; }
close($fh);

print $text;

exit 0;
