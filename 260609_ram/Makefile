VCS_OPTS = -full64 -sverilog
VCS_OPTS += -debug_access+all
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -kdb -lca
VCS_OPTS += -timescale=1ns/1ps
VCS_OUTPUT = -o simv
VCS_SRC_FILE = ./rtl/ram.sv ./tb/tb_ram.sv
VCS_INCDIR = +incdir+tb +incdir+rtl

SIMV_OPTS = +UVM_TESTNAME=ram_test 
SIMV_OPTS += +UVM_VERBOSITY=UVM_MEDIUM
SIMV_OPTS += +ntb_random_seed=1234

compile:
	vcs $(VCS_OPTS) $(VCS_INCDIR) $(VCS_OUTPUT) $(VCS_SRC_FILE)
sim: compile
	./simv $(SIMV_OPTS)
