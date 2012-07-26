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
use DateTime::Format::Mail;

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

#$date =~ s/^(.*[-+][0-9][0-9][0-9][0-9]).*$/$1/;
my $dtm = DateTime::Format::Mail->new(loose => 1);
my $dt = $dtm->parse_datetime($date);
$date = $dt->epoch;

# call groonga command to append info.
my $json = <<"EOF";
load --table Fields
[
{"_key": "$key", "date": "$date", "from": "$from",
"to": "$to", "subject": "$subject", "newsgroups": "",
"message_id": "$message_id", "body": "$body" },
]
EOF

print $date, "\n";

open($fh, "|groonga $dbname");
binmode($fh, ":utf8");
print $fh $json;
close($fh);

