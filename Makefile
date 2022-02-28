PHONY: all
.DELETE_ON_ERROR:
TOPMOD  := cpu
TOPFILE := hdl/$(TOPMOD).vhd
PROCFILES := hdl/regfile.vhd
VHDFILES := $(PROCFILES) $(TOPFILE)
SIMMOD := $(TOPMOD)_tb
TBFILE := tb/$(SIMMOD).vhd
SIMFILE := $(TOPMOD)_sim.ghk 

all: $(SIMFILE)

#PATH := /home/user/ulx3s_workspace/install/bin:$(PATH)

## 
.PHONY: clean
clean:
	rm -rf $(BINFILE)
	rm -rf $(TOPMOD).json ulx3s_out.config ulx3s.bit *.cf
	rm -rf $(SIMFILE)
	rm -rf *.log
	rm -f *.o
	rm -f $(SIMMOD)

$(SIMFILE): $(ADDFILES) $(TBFILE)
	# ghdl -a -fsynopsys $^
	ghdl -a $^

ulx3s.bit: ulx3s_out.config
	ecppack -v --compress --freq 62.0 ulx3s_out.config ulx3s.bit

ulx3s_out.config: $(TOPMOD).json
	nextpnr-ecp5 -l "pnr.log" -v --45k --json $(TOPMOD).json --package CABGA381 --lpf ulx3s_v20.lpf --textcfg ulx3s_out.config 

$(TOPMOD).json: 
	yosys -m ghdl -l "sys.log" -p 'ghdl $(VHDFILES) -e $(TOPMOD); hierarchy -top $(TOPMOD); synth_ecp5 -json $(TOPMOD).json'
	# yosys -m ghdl -l "sys.log" -p 'ghdl -fsynopsys $(VHDFILES) -e $(TOPMOD); hierarchy -top top; synth_ecp5 -json $(TOPMOD).json'
	# yosys -mghdl -l "sys.log" synth.ys

sim:
	ghdl -a --std=08 $(VHDFILES) $(TBFILE)
	ghdl -e --std=08 $(SIMMOD)
	ghdl -r --std=08 $(SIMMOD) --vcd=$(SIMFILE)

prog: ulx3s.bit
	fujprog $^
