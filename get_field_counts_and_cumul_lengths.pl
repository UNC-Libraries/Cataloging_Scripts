#!/usr/bin/perl
#
# Summary: Takes tab delimited text file (with bnum, item id (barcode), and enumeration/chronology)
#          as input and outputs MARC-XML file of bibliographic records, as per
#          HathiTrust specifications
#
# Usage: perl marc-xml_builder.pl [input file] [output file]
#
# Author: Kristina Spurgin (2015-07-29 - )
#
# Dependencies:
#    /htdocs/connects/afton_iii_iiidba_perl.inc
#
# Important usage notes:
# UTF8 is the biggest factor in this script.  in addition to the use utf8
# declaration at the head of the script, we must also explicitly set the mode of
# any output to utf8.

#***********************************************************************************
# Declarations
#***********************************************************************************

use DBI;
use  DBD::Oracle;
use utf8;
use locale;
use Net::SSH2;
use List::Util qw(first);
use File::Basename;
use Getopt::Long; #allows for use of testing mode, http://perldoc.perl.org/Getopt/Long.html

# set character encoding for stdout to utf8
binmode(STDOUT, ":utf8");

#************************************************************************************
# Set up environment and make sure it is clean
#************************************************************************************
$ENV{'PATH'} = '/bin:/usr/sbin';
delete @ENV{'ENV', 'BASH_ENV'};
$ENV{'NLS_LANG'} = 'AMERICAN_AMERICA.AL32UTF8';

my($dbh, $sth, $sql);

$input = '/htdocs/connects/afton_iii_iiidba_perl.inc';
open (INFILE, "<$input") || die &mail_error("Can't open hidden db connect file\n");

while (<INFILE>) {
    chomp;
    @pair = split("=", $_);
    $mycnf{$pair[0]} = $pair[1];
}

close(INFILE);

my $host = $mycnf{"host"};
my $sid = $mycnf{"sid"};
my $username = $mycnf{"user"};
my $password = $mycnf{"password"};

# untaint all of the db connection variables
if ($host =~ /^([-\@\w.]+)$/) {
    $host=$1;
} else {
    die "Bad data in $host";
}

if ($sid =~ /^([-\@\w.]+)$/) {
    $sid=$1;
} else {
    die "Bad data in $sid";
}

if ($username =~ /^([-\@\w.]+)$/) {
    $username=$1;
} else {
    die "Bad data in $username";
}


$dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid", $username, $password)
    or die &mail_error("Unable to connect: $DBI::errstr");

# So we don't have to check every DBI call we set RaiseError.
$dbh->{RaiseError} = 1;

#**************************************
# Get your files in order...
#**************************************
#set bnum list
$bnum_file = $ARGV[0];

# open file to write output
# the single most crucial part of this script is to specify the output format as utf8
my $out_path = $ARGV[1];
open(OUTFILE, ">:utf8", "$out_path") or die &mail_error("Couldn't open $out_path for output: $!\n");

my($out_path_file, $out_path_dir, $out_path_ext) = fileparse($out_path);

my $warn_path = "$out_path_dir/errors.txt";
open (WARN, ">:utf8", "$warn_path") or die &mail_error("Couldn't open $warn_path for output: $!\n");

my $warning_ct = 0;

# 3rd parameter is list of fields to count and compile the combined length of in format:
# 505,856,520
my $field_list = $ARGV[2];
my @fields = split(/,/, $field_list);
my $headers = "bnum";

foreach (@fields) {
    $headers .= "\t$_ ct\t$_ len";
}

print OUTFILE "$headers\n";

open (INFILE, "<$bnum_file") || die &mail_error("Can't open bnum file: $bnum_file\n");

RECORD: while (<INFILE>) {
    chomp;
    my $bnum = $_;
    my $line = "$bnum";

    foreach (@fields) {
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        # Do field count
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        my $sth = $dbh->prepare(<<SQL);
  select count (rec_data)
  from
    var_fields2
  where
    rec_key = '$bnum'
    and marc_tag = '$_'
SQL

        $sth->execute();
        my $field_ct;
        $sth->bind_columns( undef, \$field_ct);

        while ($sth->fetch()) {
            $line .= "\t$field_ct";
        }

        # close statement handle, database handle, and output file.
        $sth->finish();

        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        # Compile cumulative field length
        # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        my $sth = $dbh->prepare(<<SQL);
  select length (rec_data)
  from
    var_fields2
  where
    rec_key = '$bnum'
    and marc_tag = '$_'
SQL

        $sth->execute();
        my $cumulative_field_len = 0;
        my $field_len;
        $sth->bind_columns( undef, \$field_len);

        while ($sth->fetch()) {
            $cumulative_field_len += $field_len;
        }
            $line .= "\t$cumulative_field_len";
        # close statement handle, database handle, and output file.
        $sth->finish();

    }
    $line .= "\n";
    print OUTFILE $line;
}


close(INFILE);

$dbh->disconnect();

close(OUTFILE);
close(WARNFILE);

if ( $warning_ct > 0 ) {
    print "Bibliographic metadata compilation failed with $warning_ct errors.\n";
}


# Gets rid of white space...
sub trim{
    $incoming = $_[0];
    $incoming =~ s/^\s+//g;
    $incoming =~ s/\s+$//g;
    return $incoming;
}

sub mail_error(){
    $message_addendum = $_[0];
    $message .= $message_addendum;
    $message .= "Compiled bib file not written\n\n";
    print $message;
    exit;
}
exit;
