use strict;
use warnings;

my $id1 = $ARGV[0] || die "Needs two args";
my $id2 = $ARGV[1] || die "Needs two args";

my $patha = ($id1 =~ /\D/) ? "./$id1/" : "/home/cpan$id1/reports/";
my $pathb = ($id2 =~ /\D/) ? "./$id2/" : "/home/cpan$id2/reports/";

my @a = glob $patha.'*';
my @b = glob $pathb.'*';
my %a;
my %b;
my @avarlist;
my @bvarlist;

foreach my $a (@a) {
    if ($a =~ m|$patha(\w+?)\.(.+?)\.x86_64.+\.(\d+)\.(\d+)\.rpt|) {
        my $grade = $1;
        my $pkg = $2;
        my $time = $3;
        if (exists $a{$pkg}) {
            push @avarlist, $pkg;
        }
        next if (exists $a{$pkg} && $a{$pkg}->[0] eq 'pass');
        $a{$pkg} = [$grade, $a, $time];
    }
}

foreach my $b (@b) {
    if ($b =~ m|$pathb(\w+?)\.(.+?)\.x86_64.+\.(\d+)\.(\d+)\.rpt|) {
        my $grade = $1;
        my $pkg = $2;
        my $time = $3;
        if (exists $b{$pkg}) {
            push @bvarlist, $pkg;
        }
        next if (exists $b{$pkg} && $b{$pkg}->[0] eq 'pass');
        $b{$pkg} = [$grade, $b, $time];
    }
}


foreach my $a (@avarlist) {
    delete $a{$a};
}

foreach my $b (@bvarlist) {
    delete $b{$b};
}

my $count = 0;
my $diff = 0;

foreach my $a (sort {$a{$a}->[2] <=> $a{$b}->[2]} keys %a) {
    my $grade = $a{$a}->[0];
    my $report = $a{$a}->[1];

    if (exists $b{$a}) {
        $count++;
        my $bgrade = $b{$a}->[0];
        my $breport = $b{$a}->[1];
        if ($grade ne $bgrade) {
            $diff++;
            print "Detected diff in distribution $a: $grade vs $bgrade\n";
            print "  $report\n";
            print "  $breport\n";
            print '-'x60 ."\n";
        }
    }
}

print scalar(@a) . ":" . scalar(@b) .": " . "$diff / $count\n";

