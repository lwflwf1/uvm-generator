#! /usr/bin/perl -w
if(@ARGV < 2) {
    die "not enough argument\n";
}
my $src = "my_case".$ARGV[0];
my @dst;
my ($a, $b);
foreach (@ARGV[1..$#ARGV]) {
    if(($a, $b) = ($_ =~ /(\d+)..(\d+)/ )) {
        foreach($a..$b) { push @dst, $_; }
    }
    else { push @dst, $_;}
}
foreach (@dst) {
    my $dst = "my_case".$_;
    mkdir "./tc/$dst";
    system "cp -a ./tc/$src/$src.sv ./tc/$dst/$dst.sv";
    system "cp -a ./tc/$src/$src.cfg ./tc/$dst/$dst.cfg";
    my $now = join "-", ((localtime)[5]+1900, ((localtime)[4]+1, (localtime)[3]));
    system "perl -p -i -e \"s/$src/$dst/gi;s/(create time.*?:).*/\\1 $now/\" ./tc/$dst/$dst.sv";
    system "perl -p -i -e \"s/$src/$dst/gi;s/(create time.*?:).*/\\1 $now/\" ./tc/$dst/$dst.cfg";
    print "generate $dst\n";
}

