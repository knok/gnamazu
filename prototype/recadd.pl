#!/usr/bin/perl
# -*- CPerl -*-
#

use strict;
use warnings;
use IO::Handle;
use Encode::Guess qw/7bit-jis euc-jp shiftjis utf8/;
use File::Find;
use Data::Dumper;
use File::MMagic;
use Email::MIME;
use DateTime::Format::Mail;

package Namazu::Magic;

my $magic = File::MMagic->new();

sub getmail {
  my $filename = shift @_;
  open(my $fh, "<", $filename);
  return undef unless $fh;
  return undef unless $magic->checktype_filehandle($fh) eq "message/rfc822";
  $fh->seek(0, 0);
  my $mail = Namazu::Mail->new();
  $mail->readfile($filename, $fh);
  if ($mail->{error}) {
    undef $mail;
    return undef;
  }
  return $mail;
}

package Namazu::Mail;

my $fmt = DateTime::Format::Mail->new(loose => 1);

sub new {
  my $class = shift @_;
  my $this = bless {}, $class;
  return $this;
}

sub readfile {
  my $this = shift @_;
  my $filename = shift @_;
  my $fh = shift @_;
  if (!$fh) {
    open(my $fh, "<", $filename);
  }
  if (!$fh) {
    $this->{error} = 1;
    return;
  }
  my $text = "";
  while (<$fh>) { $text .= $_; }
  $fh->close();
  my $decoder = Encode::Guess->guess($text);
  if ((ref $decoder) =~ /^Encode/) {
    $text = $decoder->decode($text);
  }
  my $email = Email::MIME->new($text);
  my $header = $this->{header} = $email->{header};
  $this->{url} = $this->{key} = escapedq($filename);
  if ($header->header('date')) {
    $this->{date} = $fmt->parse_datetime($header->header('date'))->epoch;
  }
  $this->{from} = escapedq($header->header('from'));
  $this->{to} = escapedq($header->header('to'));
  $this->{subject} = escapedq($header->header('subject'));
  $this->{newsgroups} = "";
  $this->{message_id} = escapedq($header->header('message-id'));
  $this->{body} = escapedq($email->body);
  $this->{error} = 0;

  return;
}

sub tojson {
  my $this = shift @_;
  my $json = <<"EOF";
    {
        "_key": "$this->{key}",
        "body": "$this->{body}",
        "date": "$this->{date}",
        "from": "$this->{from}",
        "message_id": "$this->{message_id}",
        "newsgroups": "",
        "subject": "$this->{subject}",
        "to": "$this->{to}",
        "url": "$this->{url}"
    }
EOF
  return $json;
}

sub escapedq {
  my $r = shift @_;
  return "" unless defined $r;
  $r =~ s/"/\\"/g;
  return $r;
}

package Namazu::FindDir;

my $aryref;

sub new {
  my $class = shift @_;
  my $this = bless {}, $class;
  return $this;
}

sub finddir {
  my $this = shift @_;
  my $dir = shift @_;
  undef $aryref;
  $aryref = [];

  File::Find::finddepth( {wanted => \&append, no_chdir => 1}, $dir );
  $this->{files} = $aryref;
  $this->{counts} = $#{$aryref};
}

sub append {
  if (-f $_) {
    push @$aryref, $_;
  }
}

package Namazu::Register;

sub new {
  my $class = shift @_;
  my $this = bless {}, $class;
  $this->{db} = shift @_;
  return $this;
}

sub register {
  my $this = shift @_;
  my $mail = shift @_;
  my $json = $mail->tojson;
  print STDOUT <<"EOF";
groonga $this->{db}
load --table Fields
[
$json
]
EOF
}

package main;

my $x = Namazu::FindDir->new();
$x->finddir("/home/knok/Mail");

my @ary;
for (my $i = 0; $i <= $x->{counts}; $i ++) {
  my $z = Namazu::Magic::getmail($x->{files}->[$i]);
  push @ary, $z if defined $z;
}

my $reg = Namazu::Register->new("../Namazu/NMZ.db");
$reg->register($ary[0]);
