version=$(/home/cpan$1/install/bin/perl -v | perl -ne '/.+\((v.+?)\)/ && print $1 || ""')
head=$(cat /home/cpan$1/perl/.git/HEAD)
rc=$(/home/cpan$1/install/bin/perl -V | perl -ne 'if (/\b(RC\d)\b/) {print $1}')
dirname=$(perl -e 'if ($ARGV[1]=~m|^.+/(.+)|) {$a=$ARGV[0];$b=$1;$a=~s/-/-$b-/;print $a} else {$a=$ARGV[0];$a=~s/-/-blead-/;print $a} if ($ARGV[2]) {print "-$ARGV[2]"}' "$version" "$head" "$rc")
echo "$dirname"
