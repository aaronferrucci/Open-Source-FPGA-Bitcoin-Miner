import avalon_mm_pkg::*;

`timescale 1ns / 1ns
`define MASTER0 tb.fpgaminer_sys_inst_fpgaminer_0_s0_bfm

module test_program;
  task master0_send_command(Request_t req, int address, int writedata = 0);
    begin

      `MASTER0.set_command_request(req);
      `MASTER0.set_command_address(address);

      `MASTER0.set_command_idle(0, 0);
      `MASTER0.set_command_data(writedata, 0);
      `MASTER0.set_command_byte_enable(4'b1111, 0);
      `MASTER0.push_command();
    end
  endtask

  Request_t request;
  integer burstcount;
  integer i;

  fpgaminer_sys_tb tb (
  );

  initial begin
   wait (~tb.fpgaminer_sys_inst_fpgaminer_0_reset_bfm_reset_reset);
    @(posedge tb.fpgaminer_sys_inst_fpgaminer_0_clock_bfm_clk_clk);

    `MASTER0.init(); 

    repeat (5) @(posedge tb.fpgaminer_sys_inst_fpgaminer_0_clock_bfm_clk_clk);

    for (i = 0; i < 8; i = i + 1) begin
      master0_send_command(.req (REQ_WRITE), .address (i * 'h4), .writedata (i));
    end

    repeat (20)
      @(posedge tb.fpgaminer_sys_inst_fpgaminer_0_clock_bfm_clk_clk);

    $stop;
  end

endmodule

