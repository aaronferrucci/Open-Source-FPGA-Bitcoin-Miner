/*
*
* Copyright (c) 2011 fpgaminer@bitcoin-mining.com
*
*
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
* 
*/


`timescale 1ns/1ps

module fpgaminer_top (osc_clk);



	input osc_clk;

	//// PLL
	wire hash_clk;
	`ifndef SIM
		main_pll pll_blk (.inclk0 (osc_clk), .c0 (hash_clk));
	`else
		assign hash_clk = osc_clk;
	`endif

        fpgaminer_core #(
`ifdef CONFIG_LOOP_LOG2
	.LOOP_LOG2(`CONFIG_LOOP_LOG2)
`else
	.LOOP_LOG2 (0)
`endif
        ) the_core (
          .clk (hash_clk),
          .midstate_vw (midstate_vw),
          .data2_vw (data2_vw),
          .golden_nonce (golden_nonce),
          .nonce (nonce)
        );

	//// Virtual Wire Control
	wire [255:0] midstate_vw, data2_vw;

        wire [31:0] golden_nonce, nonce;

	`ifndef SIM
		virtual_wire # (.PROBE_WIDTH(0), .WIDTH(256), .INSTANCE_ID("STAT")) midstate_vw_blk(.probe(), .source(midstate_vw));
		virtual_wire # (.PROBE_WIDTH(0), .WIDTH(256), .INSTANCE_ID("DAT2")) data2_vw_blk(.probe(), .source(data2_vw));
	`endif


	`ifndef SIM
		virtual_wire # (.PROBE_WIDTH(32), .WIDTH(0), .INSTANCE_ID("GNON")) golden_nonce_vw_blk (.probe(golden_nonce), .source());
		virtual_wire # (.PROBE_WIDTH(32), .WIDTH(0), .INSTANCE_ID("NONC")) nonce_vw_blk (.probe(nonce), .source());
	`endif


	
endmodule

