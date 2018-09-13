package main;

use strict;
use warnings;
use feature qw/ say /;

sub cp2nodes {
    my ( $file, $verbose ) = @_;

    return -1 unless -e $file;

    my $TMPDIR = qq[/tmp];    # $ENV{TMPDIR} was too long and noisy

    my @ns = 0 .. 20;
    my @nodes = map { qq[$TMPDIR/node$_/] } @ns;

    @nodes = grep { -d $_ } @nodes;

    my $cwd = cwd();
    chdir $TMPDIR;
    @nodes = glob("node*");

    for my $node (@nodes) {
        my $extern = qq[$node/extern/];
        my $src    = qq[$file];
        my $dest   = qq[$TMPDIR/$extern];
        if ( -d $extern || mkdir($extern) ) {
            my $cmd = qq[rsync -q $src $dest];
            print qq[\$ $cmd\n] if $verbose;
            system $cmd;
        }
    }

    chdir $cwd;
    return 1;
}

1;
