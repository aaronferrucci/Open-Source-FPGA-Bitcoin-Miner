
all: compile run

compile:
	vsim -c -do "source msim_setup.tcl; ld; vlog -sv fpgaminer_sys_tb/simulation/test_program.sv; vlog -mfcu fpgaminer_sys_tb/simulation/fpgaminer_sys_tb.v -sv fpgaminer_sys_tb/simulation/bind.sv -cuname top; quit -code 0"

run:
	vsim -do "vsim test_program; do wave.do"

clean:
	rm -rf work
	rm -f vsim.wlf
	rm -f transcript
	rm -f wlft*
	rm -f fpgaminer_sys_tb.html
	rm -f fpgaminer_sys_tb/simulation/fpgaminer_sys_tb.v
	rm -rf fpgaminer_sys_tb/simulation/submodules
