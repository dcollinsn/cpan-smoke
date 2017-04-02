use strict;
use warnings;

my $id1 = $ARGV[0] || die "Needs two args";
my $id2 = $ARGV[1] || die "Needs two args";

my $patha = ($id1 =~ /\D/) ? "./$id1/" : "/home/cpan$id1/reports/";
my $pathb = ($id2 =~ /\D/) ? "./$id2/" : "/home/cpan$id2/reports/";

my $aV;
my $bV;
my $aver;
my $bver;

if ($id1 =~ /\D/) {
    $aV = `cat ./$id1/perl-V`;
    $aver = $id1;
} else {
    $aV = `/home/cpan$id1/install/bin/perl -V`;
    $aver = `./tellversion.sh $id1`;
    chomp $aver;
#    if ($aV =~ /\bRC(\d)\b/) {
#        $aver .= "-RC$1";
#    }
}

if ($id2 =~ /\D/) {
    $bV = `cat ./$id2/perl-V`;
    $bver = $id2;
} else {
    $bV = `/home/cpan$id2/install/bin/perl -V`;
    $bver = `./tellversion.sh $id2`;
    chomp $bver;
#    if ($bV =~ /\bRC(\d)\b/) {
#        $bver .= "-RC$1";
#    }
}


my @a = glob $patha.'*';
my @b = glob $pathb.'*';
my %a;
my %b;

my $avarcount = 0;
my @avarlist;
my $bvarcount = 0;
my @bvarlist;

foreach my $a (@a) {
    if ($a =~ m|$patha(\w+?)\.(.+?)\.x86_64.+\.(\d+)\.(\d+)\.rpt|) {
        my $grade = $1;
        my $pkg = $2;
        my $time = $3;
        if (exists $a{$pkg}) {
            $avarcount++;
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
            $bvarcount++;
            push @bvarlist, $pkg;
        }
        next if (exists $b{$pkg} && $b{$pkg}->[0] eq 'pass');
        $b{$pkg} = [$grade, $b, $time];
    }
}

my $areps = scalar(@a);
my $adists = scalar(keys %a);
my $breps = scalar(@b);
my $bdists = scalar(keys %b);

foreach my $a (@avarlist) {
    if ($a{$a}->[0] eq 'pass') {
        delete $a{$a};
    }
}

foreach my $b (@bvarlist) {
    if ($b{$b}->[0] eq 'pass') {
        delete $b{$b};
    }
}

my $count = 0;
my $diff = 0;

my %counthash;

foreach my $a (keys %a) {
    my $agrade = $a{$a}->[0];
    next unless exists $b{$a};
    my $bgrade = $b{$a}->[0];
    $counthash{$agrade}->{$bgrade}++;
    $count++;
}

my $tk = $counthash{'pass'};
$tk = $counthash{'fail'};
$tk = $counthash{'unknown'};
$tk = $counthash{'na'};

foreach my $a (sort {$a{$a}->[2] <=> $a{$b}->[2]} keys %a) {
    my $grade = $a{$a}->[0];
    my $report = $a{$a}->[1];

    if (exists $b{$a}) {
        my $bgrade = $b{$a}->[0];
        my $breport = $b{$a}->[1];
        if ($grade ne $bgrade) {
            $diff++;
            print "$a\n" unless $bgrade eq 'pass';
        }
    }
}



















