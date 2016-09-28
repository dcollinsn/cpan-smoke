version=$(/home/cpan$1/install/bin/perl -v | perl -ne '/.+\((v.+?)\)/ && print $1 || ""')
mkdir $version && /home/cpan$1/install/bin/perl -V > ./$version/perl-V && cp /home/cpan$1/reports/* ./$version/
