generate: create_tb generate_tb generate_simscript
create_tb:
	ip-generate \
          --project-directory=. \
          --output-directory=. \
          --report-file=sopcinfo:fpgaminer_sys.sopcinfo \
          --report-file=html:fpgaminer_sys.html \
          --system-info=DEVICE_FAMILY="Cyclone IV GX" \
          --component-file=fpgaminer_sys.qsys

generate_tb:
	ip-generate \
          --project-directory=./fpgaminer_sys/testbench/ \
          --output-directory=./fpgaminer_sys/testbench/fpgaminer_sys_tb/simulation/ \
          --file-set=SIM_VERILOG \
          --report-file=html:./fpgaminer_sys/testbench/fpgaminer_sys_tb.html \
          --system-info=DEVICE_FAMILY="Cyclone IV GX" \
          --component-file=./fpgaminer_sys/testbench/fpgaminer_sys_tb.qsys \
          --report-file=csv:./fpgaminer_sys_tb.csv \
          --report-file=spd:./fpgaminer_sys_tb.spd

generate_simscript:
	sim-script-gen \
          --spd=./fpgaminer_sys_tb.spd \
          --output-directory=./fpgaminer_sys/testbench/
          

