#!/usr/bin/perl
use warnings;

$ENV{LD_LIBRARY_PATH} = "$ENV{LD_LIBRARY_PATH}".":/app/synopsys/verdi1403/share/PLI/VCS/LINUX64";
# $ENV{NOVAS_HOME} = "/app/synopsys/verdi1403";
my $verdi_home = $ENV{VERDI_HOME};

my @cases;
my $dump_off = 0;
my $cov = 0;
my $seed = time;
my $vcs = "-debug_pp -R -full64 +plusarg_save +v2k -sverilog  +no_notifier +vc ";
my $verdi_opt;
my %case_fail;
my $topname = glob './tb/*top.sv';

sub main {
    foreach (@ARGV) {
        if (/case(\d+)(..)?(\d+)?/) { 
            if(!(defined($2) or defined($3))) { push @cases, $_; }
            else { foreach ($1..$3) {push @cases, "my_case".$_;} }
        }
        elsif (/dump_off/) { $dump_off = 1; }
        elsif (/cov/) { $cov = 1; }
        elsif (/verdi/) {$verdi_opt = 1;}
        elsif (/help/) { &help; return; } 
        elsif (/seed/) {
            s/seed=//;
            $seed = $_;
        }
        else {die "invalid argument:'$_'\n";}
    }
    if (!@cases) {die "case not set!\n";}
    if (defined($verdi_opt)) { &verdi; return; }

    foreach $case (@cases) {
        my $log = "./log/$case.log";
        my $vcs_opt = $vcs."-ntb_opts uvm +UVM_TESTNAME=$case +UVM_OBJECTION_TRACE +define+UVM_NO_DEPRECATED +UVM_PHASE_TRACE -timescale=1ns/1ps +ntb_random_seed=$seed -l $log ";
        open my $casecfg, "<", "./tc/$case/$case.cfg" or die "open file $case.cfg:$!\n";
        while(<$casecfg>) {
            if (/vcs options/) {
                if (defined($line = readline $casecfg)) {
                    chomp $line;
                    $vcs_opt .= $line." ";
                }
            }
        }
        close $casecfg;

        if ($dump_off == 0) {
            $vcs_opt .= " +define+DUMP -LDFLAGS -rdynamic -P $verdi_home/share/PLI/VCS/LINUX64/novas.tab $verdi_home/share/PLI/VCS/LINUX64/pli.a ";
            rename $topname, $topname.".bak";
            open my $topfileorigin, '<', $topname.".bak" or die "open file $topname:$!\n";
            open my $topfile, '>', $topname or die "open file $topname:$!\n";
            while(<$topfileorigin>) {
                s/test_fsdb/$case/;
                print $topfile $_;
            }
            close $topfile;
            close $topfileorigin;
        } 

        if ($cov == 1) {
            $vcs_opt .= "-cm_name RTL -cm_log ./log/cm.log ";
            # $vcs_opt .= "-cm_hier ./cfg/hier_file.conf ";
            $vcs_opt .= "-cm line+cond+fsm+assert ";
            $vcs_opt .= "-cm_line contassign ";
            $vcs_opt .= "-cm_cond allops+event+anywidth ";
            $vcs_opt .= "-cm_ignorepragmas -cm_noconst ";
            $vcs_opt .= "-cm_dir ./cov/$case ";
        }

        $vcs_opt .= "-f ./filelist/filelist.f ./tc/$case/$case.sv ";
        $vcs_opt .= "+notimingcheck ";

        system "vcs $vcs_opt";
        print "\n/*------------------------------------------------------------*/\n";
        print "    finish test $case\n";
        print "/*------------------------------------------------------------*/\n";
    
        if ($dump_off == 0) {
            unlink $topname;
            rename $topname.".bak", $topname;
        }
        my $logfile;
        open $logfile, "<", $log or die "can not open $logfile:$!\n";
        $case_fail{$case} = "pass"; 
        while (<$logfile>) {
            if (/uvm_(?:error|fatal)\s*:\s*(\d+)/i and ($1 > 0)) {
                $case_fail{$case} = "fail";
                last;
            }
        }
        close $logfile;
    }
    my ($key, $value);
    print "\n/*------------------------------------------------------------*/\n";
    while (($key, $value) = each %case_fail) {print "$key: $value\n";}
    print "/*------------------------------------------------------------*/\n";

}

sub verdi {
    my $case = $cases[0];
    $verdi_opt = "-2012 -f ./filelist/filelist.f -nologo -ssf ./fsdb/$case*.fsdb -logdir ./verdilog -logfile -guiConf ./verdilog/novas.conf -veriSimType VCS -rcFile ./verdilog/novas.rc";
    system "verdi $verdi_opt &";
}

sub help {
    print "usage example:\n\t";
    print "simulation:\n\t";
    print "./scripts/sim.pl my_case1                        //run my_case1, dump on, cov off\n\t";
    print "./scripts/sim.pl my_case1 dump_off               //run my_case1, dump off, cov off\n\t";
    print "./scripts/sim.pl my_case1 dump_off cov           //run my_case1, dump off, cov on\n\t";
    print "./scripts/sim.pl my_case1 dump_off cov seed=10   //run my_case1, dump off, cov on, seed=10\n\t";
    print "the four arguments can be in any order\n\n\t";
    print "verdi:\n\t";
    print "./scripts/sim.pl my_case1 verdi\n\t";
    print "the two arguments can be in any order\n";
}

main;
