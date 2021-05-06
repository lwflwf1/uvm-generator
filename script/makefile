# export LD_LIBRARY_PATH := ${LD_LIBRARY_PATH}:/app/synopsys/verdi1403/share/PLI/VCS/LINUX64
export NOVAS_HOME := /app/synopsys/verdi1403

TOP = topfile
SOURCE = NONE
FSDB_NUM = 
CORNER = 
COV  = off
DUMP = on
SIMMODE = RTL
CASE = my_case1
# SIMMODE = RTL or PRESIM or POSTSIM

SCAN = 0
FP_FILE = ./syn/input/*.fp

FUNC_SDC = ./syn/script/$(TOP).func.sdc
RTL = ./rel/$(TOP).v
FP_FILE = ./syn/input/icc2dct
# ============================== initial VCS_option========================= #
VCS_OPT = -debug_pp -R -full64 +plusarg_save +v2k -sverilog  +no_notifier +vc +UVM_OBJECTION_TRACE +define+UVM_NO_DEPRECATED +UVM_PHASE_TRACE

ifeq	($(DUMP),on)
VCS_OPT += +define+DUMP
# VCS_OPT += +FSDB=./fsdb/$(SIMMODE)$(FSDB_NUM).fsdb
# VCS_OPT += +DUMP
VCS_OPT += -P $(VERDI_HOME)/share/PLI/VCS/LINUX64/novas.tab \
$(VERDI_HOME)/share/PLI/VCS/LINUX64/pli.a
endif

#VCS_OPT += -ntb_opts uvm
# ==========================VCS coverage collection option================= #
ifeq	($(COV),on)
VCS_OPT += -cm_name $(SIMMODE)
VCS_OPT += -cm_hier ./cfg/hier_file.conf
VCS_OPT += -cm line+cond+fsm
VCS_OPT += -cm_line contassign
VCS_OPT += -cm_cond allops+event+anywidth
VCS_OPT += -cm_ignorepragmas
VCS_OPT += -cm_noconst 
endif

# ==========================select simfile================================ #
ifeq	($(SIMMODE),PRESIM)
SIMFILE = -f simfile/simfile_presim.f
VCS_OPT += +define+PRESIM +notimingcheck
LOG = log/vcs_presim.log
else
ifeq	($(SIMMODE),POSTSIM)
SIMFILE = -f simfile/simfile_postsim.f
VCS_OPT += +define+POSTSIM +neg_tchk -negdelay +define+$(CORNER) +overlap
LOG = log/vcs_postsim.log
else
SIMFILE = -f simfile/simfile_rtl.f
VCS_OPT += +notimingcheck
LOG = log/vcs_rtlsim.log
endif
endif

# ==========================DC option=========================== #
CMD = -x "set FUNC_SDC  ./syn/input/$(TOP).func.sdc;\
	  	  set RTL ./syn/input/$(TOP).v;\
		  set TOP $(TOP); \
		  set SCAN $(SCAN); \
		  set FP_FILE $(FP_FILE)"
# ==========================target============================== #
help:
	@echo "help:"
	@echo "make nlint:start nlint to check the code in simfile"
	@echo "make vcs:start simulation"
	@echo "make cov:creat the report of cover"
	@echo "make verdi:start verdi to observe the wave"
	@echo "make link:link the source code in a file"
	@echo "make clean:clean the temp file"
	@echo "make new:creat a new workspace"
	@echo "make clearprj:remove all files except makefile"

nlint:
	nLint -95 -2001 -rs ./nLint/my_nLint.rs -out ./log/nLint.log ./rtl/*.v

vcs:
	vcs $(VCS_OPT) ./tsk/test.v $(SIMFILE) |tee $(LOG)

uvm:
	vcs $(VCS_OPT) +UVM_TESTNAME=$(CASE) -ntb_opts uvm -timescale-1ns/1ps $(SIMFILE) |tee ./log/uvm_report.log

cov:
	urg -dir simv.vdb

verdi:
	verdi -sv -ssf ./fsdb/test_000.fsdb $(SIMFILE) > verdi.log 
	# verdi -sv -ssf ./fsdb/$(SIMMODE)$($FSDB_NUM).fsdb ./tsk/test.v $(SIMFILE) > verdi.log 
	@echo "(>.<)"

dc:
	sed 's/\(^`define.*SIM\)/\/\/\1/' -i ./syn/input/$(TOP).v
	dc_shell-xg-t -topo -no_gui $(CMD) -f ./syn/script/dc.tcl | tee ./log/$(TOP)_dc.log

fm:
	fm_shell -x "set TOP	$(TOP)" -f ./formality/fm_dct.tcl | tee ./log/fm_dct.log

link:
	cat `more ./rel/rtl.lis` > ./rel/$(TOP).v
	nLint -2001 -rs ./nLint/my_nLint.rs -out ./log/rel_nLint.log rel/$(TOP).v
	cp ./rel/$(TOP).v ./syn/input/
new:
	@echo "hello,designer"
	mkdir testbench
	mkdir rtl
	mkdir log
	mkdir fsdb
	mkdir tsk
	mkdir simfile
	mkdir rel
	mkdir nLint
	mkdir formality
	mkdir syn
	mkdir syn/input
	mkdir syn/script
	mkdir syn/output
	touch ./simfile/simfile_rtl.f
	touch ./simfile/simfile_presim.f
	touch ./simfile/simfile_postsim.f
	touch ./rel/rtl.lis
	touch ./tsk/test.v
ifneq	($(SOURCE),NONE)
	cp -rf $(SOURCE)/*.v ./rtl/
	cp -rf $(SOURCE)/*.sv ./testbench/
endif
	cp -rf ./*.tcl ./syn/script/

clean:
	rm -f ./log/*.log
	rm -f ./fsdb/*.fsdb
	rm -f ./rel/$(TOP).v

clearprj:
	mkdir ../makefile_save
	mv ./makefile ../makefile_save/
	rm -rf ./* 
	mv ../makefile_save/makefile ./
	rm -rf ../makefile_save
	@echo "good bye,designer"

test:
	@echo $(VERDI_HOME)