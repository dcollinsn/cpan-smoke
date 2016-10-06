use strict;
use warnings;

my $id1 = $ARGV[0] || die "Needs two args";
my $id2 = $ARGV[1] || die "Needs two args";

my $outlist = `perl smokediff.pl $id1 $id2`;

my @reports = split('-'x60, $outlist);

foreach my $lines (@reports) {
	if ($lines =~ m|/home/cpan(\d)/reports/fail\..+?\d\.rpt|) {
		my $id = $1;
		my $report = $&;
		open(my $fh, '<', $report) or die "Can't open < $report: $!";
		my $line = <$fh>;
		until ($line =~ /X-Test-Reporter-Distfile/) {
			$line = <$fh>;
		}
		close($fh);
		if ($line =~ /X-Test-Reporter-Distfile: (.+)/) {
			my $dist = $1;
			my $cmd = "sudo -u cpan$id PERL_CR_SMOKER_RUNONCE=1 /home/cpan$id/install/bin/perl -MCPAN -e '\$CPAN::Config->{test_report} = 1; install(q($dist))'";
			system($cmd);
		} else {
			print "Error: No X-Test-Reporter-Distfile line in $report\n";
		}
	}
}

#sudo -u cpan2 PERL_CR_SMOKER_RUNONCE=1 /home/cpan2/install/bin/perl -MCPAN::Reporter::Smoker -e 'start(install => 1, force_trust => 1, restart_delay => 1500000, list => [q(FLAZAN/Crypt-SMimeEngine-0.06.tar.gz)])'

