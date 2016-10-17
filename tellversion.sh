version=$(/home/cpan$1/install/bin/perl -v | perl -ne '/.+\((v.+?)\)/ && print $1 || ""')
head=$(cat /home/cpan$1/perl/.git/HEAD)
dirname=$(perl -e 'if ($ARGV[1]=~m|^.+/(.+)|) {$a=$ARGV[0];$b=$1;$a=~s/-/-$b-/;print $a} else {print $ARGV[0]}' "$version" "$head")
echo "$dirname"
