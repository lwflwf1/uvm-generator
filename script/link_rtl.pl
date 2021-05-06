#! /usr/bin/perl -w
my $rtl_path = '/home/wyc/Project/To_Vrf/rtl';
my $rtl;
foreach (glob "$rtl_path/*") {
    $rtl = (split /\//, $_)[-1];
    symlink "$rtl_path/$rtl", "./rtl/$rtl" or die "can not link:$!\n";
}
