use strict;
use warnings;

my @ready = glob '/home/dcollins/var/cpansmoker/sync/*';
my @done = glob '/home/dcollins/var/cpansmoker/done/*';

my %complete;
my $count = 0;

foreach my $done (@done) {
	if ($done =~ m|/home/dcollins/var/cpansmoker/done/(.+)|) {
		my $key = $1;
		$complete{$key}++;
	}
}

foreach my $ready (@ready) {
	if ($ready =~ m|/home/dcollins/var/cpansmoker/sync/(.+)|) {
		my $key = $1;
		if ($complete{$key}) {
			`rm $ready`;
		} else {
			$count++;
		}
	}
}

print "Finished! Run the following command to send $count reports:\nperl send_tr_reports.pl --cpan-uid=dcollins\n";

