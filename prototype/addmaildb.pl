#!/usr/bin/perl
# -*- CPerl -*-
#

use strict;
use warnings;
#use utf8;
use Encode::Guess qw/7bit-jis euc-jp shiftjis utf8/;
use Data::Dumper;
use IO::File;
use Email::MIME;

my $dbname = shift @ARGV;
die "no dbname" unless $dbname;
my $filename = shift @ARGV;
die "no filename" unless $filename;

my $fh;
open($fh, "< $filename");
my $text;
while (<$fh>) { $text .= $_; }
close($fh);
$text = Encode::decode("Guess", $text);
my $email = Email::MIME->new($text);
my $header = $email->{'header'};
my $key = $filename;
my $date = $header->header('date');
my $from = $header->header('from');
my $to = $header->header('to');
my $subject = $header->header('subject');
my $newsgroups = "";
my $message_id = $header->header('message-id');
my $body = $email->body;

foreach my $k ($key, $date, $from, $to, $subject, $message_id, $body) {
  print $k . "\n";
}
