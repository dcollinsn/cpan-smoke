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

print <<"EOM";
<html>
<p>
This is a CPAN Smoke summary. Two versions of Perl were installed, many
CPAN distributions were tested, and the results were compared. For this
report, the control version is $aver, and the
experimental version is $bver.
</p>

<p>
A perl -V for each version is located at the bottom of this message.
</p>

EOM


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

print <<"EOM";
<h2>
Summary
</h2>

<p>
The control sumbitted $areps reports of $adists distributions.
The experimental submitted $breps reports of $bdists distributions.
Differences in the above numbers are due to distributions with
intermittent failures, described below.
</p>

<p>
This table shows the number of distributions with the indicated set
of grades.
</p>

<pre>
Control            Experiment
EOM
printf('%12s %8s %8s %8s %8s'."\n", "", "PASS", "FAIL", "UNKNOWN", "NA");
my $tk = $counthash{'pass'};
printf('%12s %8d %8d %8d %8d'."\n", "PASS", $tk->{'pass'}//0, $tk->{'fail'}//0,
    $tk->{'unknown'}//0, $tk->{'na'}//0);
$tk = $counthash{'fail'};
printf('%12s %8d %8d %8d %8d'."\n", "FAIL", $tk->{'pass'}//0, $tk->{'fail'}//0,
    $tk->{'unknown'}//0, $tk->{'na'}//0);
$tk = $counthash{'unknown'};
printf('%12s %8d %8d %8d %8d'."\n", "UNKNOWN", $tk->{'pass'}//0, $tk->{'fail'}//0,
    $tk->{'unknown'}//0, $tk->{'na'}//0);
$tk = $counthash{'na'};
printf('%12s %8d %8d %8d %8d'."\n", "NA", $tk->{'pass'}//0, $tk->{'fail'}//0,
    $tk->{'unknown'}//0, $tk->{'na'}//0);
print "\n</pre>\n";

print <<"EOM";
<h2>
Variable Behavior
</h2>

<p>
Some distributions exhibit intermittent failures. This is common for
distributions with timing-sensitive tests, but can also reveal bugs
in the distribution. For example, some distributions check for other
processes already running that distribution's tests, which fails
with parallel smokers, as we have here. Much more common are dists
which use hardcoded temporary filenames, which causes permissions
conflicts when two different user accounts run their tests.
</p>

<p>
The control detected $avarcount distributions with variable behavior.
</p>
<p>
Theexperimental detected $bvarcount distributions with variable behavior.
</p>

<p>
These distributions have been ignored in the statistics and in the diff
report below. However, one test report of each grade has been saved and
may be uploaded to the metabase.
</p>

EOM

print "<p>Here is a list of those distributions for the control:</p>\n\n<ul>\n";
print join("\n", map {"<li>".$_."</li>"} @avarlist);
print "\n</ul>\n\n";
print "<p>Here is a list of those distributions for the experiment:</p>\n\n<ul>\n";
print join("\n", map {"<li>".$_."</li>"} @bvarlist);
print "\n</ul>\n\n";

print <<"EOM";
<h2>
Detected Differences
</h2>

<p>
Finally, here is the list of modules with differing behavior between
the control and the experiment. Of special interest should be modules
with the "pass vs fail" signature.
</p>

<pre>
EOM

foreach my $a (sort {$a{$a}->[2] <=> $a{$b}->[2]} keys %a) {
    my $grade = $a{$a}->[0];
    my $report = $a{$a}->[1];

    if (exists $b{$a}) {
        my $bgrade = $b{$a}->[0];
        my $breport = $b{$a}->[1];
        if ($grade ne $bgrade) {
            $diff++;
            print "Detected diff in distribution $a: $grade vs $bgrade\n";
            if ($report =~ /((?:pass|fail|unknown|na).+rpt)/) {
                print "  <a href='p5p/$1'>$report</a>\n";
            } else {
                print "  $report\n";
            }
            if ($breport =~ /((?:pass|fail|unknown|na).+rpt)/) {
                print "  <a href='p5p/$1'>$breport</a>\n";
            } else {
                print "  $breport\n";
            }
            my $commentsfile = "$aver-$bver/$a";
            if (-e $commentsfile) {
                print "  Comment: ".`cat $commentsfile`;
            } elsif (-e "generic-comments/$a") {
                print "  Comment: ".`cat generic-comments/$a`;
            } else {
                print "  // Commentsfile $commentsfile empty\n";
            }
            print "\n"
        }
    }
}

print <<"EOM";
</pre>

<h2>
Control perl -V
</h2>

<pre>
$aV
</pre>

<h2>
Experimental perl -V
</h2>

<pre>
$bV
</pre>
EOM




















