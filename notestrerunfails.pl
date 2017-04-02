use strict;
use warnings;

my $id1 = $ARGV[0] || die "Needs two args";
my $id2 = $ARGV[1] || die "Needs two args";

my $outlist = `perl smokediff.pl $id1 $id2`;

my @reports = split("\n", $outlist);

foreach my $lines (@reports) {
	if ($lines =~ m{/home/cpan(\d)/reports/(fail|unknown|na|pass)\..+?\d\.rpt}) {
		my $id = $1;
                my $grade = $2;
		my $report = $&;
                next if $grade eq 'pass';
		open(my $fh, '<', $report) or die "Can't open < $report: $!";
		my $line = <$fh>;
		until ($line =~ /X-Test-Reporter-Distfile/) {
			$line = <$fh>;
		}
		close($fh);
                my $envvar = '';
		if ($line =~ /X-Test-Reporter-Distfile: (.+)/) {
			my $dist = $1;
                        $envvar .= 'AUTOMATED_TESTING=1 ';
                        $envvar .= 'PERL_MM_USE_DEFAULT=1 ';
                        $envvar .= 'PERL_EXTUTILS_AUTOINSTALL=1 ';
			my $cmd = "sudo -u cpan$id $envvar /home/cpan$id/install/bin/perl -MCPAN -e '\$CPAN::Config->{test_report} = 0; \$ENV{q(PERL_USE_UNSAFE_INC)} = 1; notest(q(install), q($dist))'";
                        $ENV{AUTOMATED_TESTING} = 1;
                        $ENV{PERL_MM_USE_DEFAULT} = 1;
                        $ENV{PERL_EXTUTILS_AUTOINSTALL} = 1;
			system($cmd);
		} else {
			print "Error: No X-Test-Reporter-Distfile line in $report\n";
		}
	}
}

#sudo -u cpan2 PERL_CR_SMOKER_RUNONCE=1 /home/cpan2/install/bin/perl -MCPAN::Reporter::Smoker -e 'start(install => 1, force_trust => 1, restart_delay => 1500000, list => [q(FLAZAN/Crypt-SMimeEngine-0.06.tar.gz)])'

