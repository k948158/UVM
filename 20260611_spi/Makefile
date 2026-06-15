VCS_OPTS = -full64 -sverilog
VCS_OPTS += -debug_access+all
VCS_OPTS += -cm line+cond+fsm+tgl+branch+assert
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -kdb -lca
VCS_OPTS += -timescale=1ns/1ps
VCS_OUTPUT = -o simv
VCS_SRC_FILE = ./rtl/spi_master.sv ./rtl/spi_slave.sv ./rtl/spi_loopback.sv ./tb/spi_if.sv ./tb/spi_pkg.sv ./tb/tb_spi_loopback.sv
VCS_INCDIR = +incdir+tb +incdir+rtl

TEST = spi_test
SEED ?= 1
INFO_LEVEL ?= UVM_MEDIUM

SIMV_OPTS = +UVM_TESTNAME=$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=$(SEED)
SIMV_OPTS += -cm line+cond+fsm+tgl+branch+assert
SIMV_OPTS += -cm_dir coverage.vdb
SIMV_OPTS += -cm_name sim1

.PHONY: all compile simv urg verdi verdi_cov clean

all: simv

compile:
	vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_OUTPUT) $(VCS_SRC_FILE)

simv: compile
	./simv $(SIMV_OPTS)

verdi:
	verdi -ssf spi_loopback.fsdb -nologo &

urg:
	urg -dir coverage.vdb -report urgReport

verdi_cov:
	verdi -cov -covdir coverage.vdb -ssf spi_loopback.fsdb -nologo &

clean:
	rm -rf simv* csrc *.log *.key *.h *.fsdb coverage.vdb urgReport novas* verdiLog
