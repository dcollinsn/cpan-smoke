use strict;
use warnings;
use DateTime;
use Term::ANSIColor qw(:constants);

while (1) {
    `reset`;
    my $now = DateTime->now(time_zone => 'America/New_York');

    foreach my $i (1..4) {
        my $user = 'cpan'.$i;
        my $ps = `ps -F -U $user`;

        if ($ps =~ /CPAN::Reporter::Smoker/) {
            my $count = `ls /home/cpan$i/reports/ | wc -l`;
            if ($ps =~ /(\d{2}):(\d{2})\s+pts.\d+\s+[\d:]{8}.+install\( '(.+?)'/) {
                my $then = DateTime->now(time_zone => 'America/New_York');
                $then->set(hour => $1, minute => $2);
                if ($now->subtract_datetime($then)->in_units('minutes') > 5) {
                    print REVERSE;
                }
                printf "$user running [%5d], [$1:$2] $3".RESET."\n", $count;
            }
        } else {
            print "$user not running\n";
        }
    }
    sleep 5;
}

