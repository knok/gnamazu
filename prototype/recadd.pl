#!/usr/bin/perl
# -*- CPerl -*-
#

use strict;
use warnings;
use IO::Handle;
use Encode::Guess qw/7bit-jis euc-jp shiftjis utf8/;
use File::Find;

package Namazu::Mail;

sub new {
  my $class = shift @_;
  my $this = bless {}, $class;
  return $this;
}

sub readfile {
  my $this = shift @_;
  my $filename = shift @_;
  open(my $fh, "<", $filename);
  if (!$fh) {
    $this->{error} = 1;
    return;
  }
  my $text = "";
  while (<$fh>) { $text .= $_; }
  $fh->close();
  $text = Encode::decode("Guess", $text);
  my $email = $this->{email} = Email::MIME->new($text);
  my $header = $this->{header} = $email->{'header'};
  $this->{key} = escapedq($filename);
  $this->{date} = $header->header('date');
  $this->{from} = escapedq($header->header('from'));
  $this->{to} = escapedq($header->header('to'));
  $this->{subject} = escapedq($header->header('subject'));
  $this->{newsgroups} = "";
  $this->{message_id} = escapedq($header->header('message-id'));
  $this->{body} = escapedq($email->body);
  $this->{error} = 0;

  return;
}

sub escapedq {
  my ($r) = @_;
  $r =~ s/"/\\"/g;
}

package Namazu::RecDir;

sub new {
  my $class = shift @_;
  my $this = bless {}, $class;
  return $this;
}

sub finddir {
  my $this = shift @_;
  my $dir = shift @_;
  my $aryref = [];

  finddepth( {wanted => append($aryref), no_chdir => 1}, $dir );
  $this->{files} = $aryref;
}

sub append {
  my ($aryref) = @_;
  if (-f $_) {
    push @$aryref, $_;
  }
}

