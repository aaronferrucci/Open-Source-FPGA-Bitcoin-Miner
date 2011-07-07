General approach:
1) create a Qsys system containing the fpgaminer IP component, with all
interfaces exported
2) Generate a testbench (generation tab: "create simulation model: none; create
testbench Qsys system: standard, create testbench simulation model: verilog;
create hdl design files for synthesis: unchecked")
3) generate (creates one warning, "TB_Gen: clockRate is less than 1MHz; setting
to 50MHz".  This is ok)
4) cd fpgaminer_sys/testbench
5) "make"
6) in the modelsim console, "run 2us"

