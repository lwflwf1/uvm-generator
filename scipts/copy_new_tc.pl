#! /usr/bin/perl -w
if(@ARGV != 2) {
    die "wrong argument\n";
}
my $src = "my_case".$ARGV[0];
my $dst = "my_case".$ARGV[1];
mkdir "./tc/$dst";
system "cp -a ./tc/$src/$src.sv ./tc/$dst/$dst.sv";
system "cp -a ./tc/$src/$src.cfg ./tc/$dst/$dst.cfg";
my $now = localtime;
system "perl -p -i -e \"s/$src/$dst/gi;s/(create time.*?)\\w.*/\\1$now/\" ./tc/$dst/$dst.sv";
system "perl -p -i -e \"s/$src/$dst/gi;s/(create time.*?)\\w.*/\\1$now/\" ./tc/$dst/$dst.cfg";









# print "start to run perl !! parameter cnt is $#ARGV \n";
# if($#ARGV < 0){
#     die;
# }
# $src_case_num = $ARGV[0];
# $dst_case_num = $ARGV[1];
# print "source      tc number is $src_case_num, \n";
# print "destination tc number is $dst_case_num, \n";
# $src_tc_name = "my_case"."$src_case_num";
# $dst_tc_name = "my_case"."$dst_case_num";
# print "source      tc name is $src_tc_name, \n";
# print "destination tc name is $dst_tc_name, \n";
# #if(!exists($src_tc_name)){
# #    die;
# #}
# #else {
# #    system("cp -rf $src_tc_name $dst_tc_name ");
# #
# #}
# system("rm -rf $dst_tc_name");
# system("cp -rf $src_tc_name $dst_tc_name ");
# system("ls  ");
# chdir $dst_tc_name ;
# $new_dir = `pwd`;
# print "new dir is $new_dir \n";
# print "before change file name and key words : \n" ;
# system("ls ");
# $src_cfg_name = "$src_tc_name".".cfg";
# $src_sv_name  = "$src_tc_name".".sv";
# $dst_cfg_name = "$dst_tc_name".".cfg";
# $dst_sv_name  = "$dst_tc_name".".sv";
# system("mv $src_cfg_name $dst_cfg_name ");
# system("mv $src_sv_name $dst_sv_name ");

# #system("perl -pi -e \"s/my_case2_1/my_case10_2/gi\" $dst_sv_name");

# system("perl -pi -e \"s\/$src_tc_name\/$dst_tc_name\/gi\" $dst_cfg_name");
# system("perl -pi -e \"s\/$src_tc_name\/$dst_tc_name\/gi\" $dst_sv_name");
# print "new tc files like this: \n";
# system("ls ;");
# system("gvim  $dst_sv_name ;gvim $dst_cfg_name");


