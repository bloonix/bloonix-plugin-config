#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case);

my $prefix = "/usr/local";
my $o_confdir = "/etc";
my $o_perl = "/usr/bin/perl";
my $o_perl_prefix = "/usr/local";
my $o_perl_installdirs = "site";
my $o_without_perl = 0;
my $help = undef;

if (!-e "Makefile") {
    print "Execute me from the source directory!\n";
    exit 1;
}

GetOptions(
    "prefix=s" => \$prefix,
    "confdir=s" => \$o_confdir,
    "perl=s" => \$o_perl,
    "perl-prefix=s" => \$o_perl_prefix,
    "perl-installdirs=s" => \$o_perl_installdirs,
    "without-perl" => \$o_without_perl,
    "h|help" => \$help
);

if ($help) {
    print "Usage: perl Configure.PL [ OPTIONS ]\n\n";
    print "Configure options:\n\n";
    print "  --prefix DIR\n";
    print "  --confdir DIR (default: $o_confdir)\n";
    print "  --perl PERL EXECUTABLE (default: $o_perl)\n";
    print "  --perl-prefix DIR (default: $o_perl_prefix)\n";
    print "  --perl-installdirs INSTALLDIRS (default: $o_perl_installdirs)\n";
    print "  --help (print the help)\n\n";
    exit 0;
}

open my $fh, ">", "Makefile.config" or die "Unable to overwrite Makefile - $!";

print "Writing Makefile.config ...\n";

print $fh <<EOF;
# Base paths
PREFIX=\$(DESTDIR)$prefix
CONFDIR=\$(DESTDIR)$o_confdir
PERL=$o_perl
PERL_PREFIX=\$(DESTDIR)$o_perl_prefix
PERL_INSTALLDIRS=$o_perl_installdirs
WITHOUT_PERL=$o_without_perl
EOF

close $fh;

print "Done.\n";
