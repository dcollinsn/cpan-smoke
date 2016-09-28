use strict;
use warnings;

foreach my $i (1..4) {
    my $user = 'cpan'.$i;
    my $ps = `ps -F -U $user`;

    if ($ps =~ /CPAN::Reporter::Smoker/) {
        print "$user running";
        my $count = `ls /home/cpan$i/reports/ | wc -l`;
        printf(' [%5d]', $count);
        if ($ps =~ /(\d{2}:\d{2})\s+pts.\d+\s+[\d:]{8}.+install\( '(.+?)'/) {
            print ", [$1] $2";
        }
    } else {
        print "$user not running";
    }
    print "\n";
}

