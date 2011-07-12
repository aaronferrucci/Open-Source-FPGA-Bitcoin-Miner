onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider BFMs
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_clk_bfm_clk_clk
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_reset_bfm_reset_reset
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_address
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_burstcount
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_byteenable
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_debugaccess
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_read
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_readdata
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_readdatavalid
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_waitrequest
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_write
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst_mm_bridge_0_s0_bfm_m0_writedata
add wave -noupdate -divider fpgaminer_0
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst/fpgaminer_0/data2_vw
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst/fpgaminer_0/golden_nonce
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst/fpgaminer_0/midstate_vw
add wave -noupdate -radix hexadecimal /test_program/tb/fpgaminer_sys_inst/fpgaminer_0/nonce
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1275951 ps} 0}
configure wave -namecolwidth 460
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1098295 ps} {1346350 ps}
