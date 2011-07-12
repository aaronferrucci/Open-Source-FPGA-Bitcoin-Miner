// This component exposes two 256-bit registers and two 32-bit registers
// which connect to fpgaminer_core.
//
// Address map:
//      0        4        8         C         10         14         18         1C
// D[31:0] D[63:32] D[95:64] D[127:96] D[159:128] D[191:160] D[223:192] D[255:224] 
//     20       24       28        2C         30         34         38         3C
// M[31:0] M[63:32] M[95:64] M[127:96] M[159:128] M[191:160] M[223:192] M[255:224] 
//     40       44       48        4C         50         54         58         5C
//      G       --       --        --         --         --         --         --
//     60       64       68        6C         70         74         78         7C
//      N       --       --        --         --         --         --         --
//
//  D: 256-bit read/write data2_vw.  
//  M: 256-bit read/write midstate_vw.
//  G: golden_nonce output from fpgaminer_core.  read-only.
//  N: nonce output from fpgaminer_core.  read-only.
//  --: don't care; make no assumptions about the value read at these locations.

module fpgaminer(
  input clk,
  input reset,

  input [1:0] address, // word-aligned address
  input write,
  input [31:0] byteenable,
  input [255:0] writedata,

  input read,
  output reg [255:0] readdata
);

  wire select_data2_vw = (address == 2'b00);
  wire [255:0] data2_vw;
  fpgaminer_reg256 the_data2_vw(
    .clk (clk),
    .reset (reset),
    .byteenable (byteenable),
    .writedata (writedata),
    .write (write & select_data2_vw),
    .value (data2_vw)
  );

  wire select_midstate_vw = (address == 2'b01);
  wire [255:0] midstate_vw;
  fpgaminer_reg256 the_midstate_vw(
    .clk (clk),
    .reset (reset),
    .byteenable (byteenable),
    .writedata (writedata),
    .write (write & select_midstate_vw),
    .value (midstate_vw)
  );

  wire [31:0] golden_nonce;
  wire [31:0] nonce;

  fpgaminer_core #(
`ifdef CONFIG_LOOP_LOG2
  .LOOP_LOG2(`CONFIG_LOOP_LOG2)
`else
  .LOOP_LOG2 (0)
`endif
  ) the_core (
    .clk (clk),
    .midstate_vw (midstate_vw),
    .data2_vw (data2_vw),
    .golden_nonce (golden_nonce),
    .nonce (nonce)
  );

  // readdata mux
  always @(posedge clk) begin
    if (address == 2'b00) readdata <= data2_vw;
    if (address == 2'b01) readdata <= midstate_vw;
    if (address == 2'b10) readdata <= {{(256-32) {1'bx}}, golden_nonce};
    if (address == 2'b11) readdata <= {{(256-32) {1'bx}}, nonce};
  end

endmodule

module fpgaminer_reg256 (
  input clk,
  input reset,
  input [31:0] byteenable,
  input [255:0] writedata,
  input write,
  output reg [255:0] value
);

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : value_assignment
      always @(posedge clk or posedge reset) begin
        if (reset) begin
          value[(i + 1) * 8 - 1:i * 8] <= '0;
        end
        else if (write & byteenable[i]) begin
          value[(i + 1) * 8 - 1:i * 8] <= writedata[(i + 1) * 8 - 1:i * 8];
        end
      end
    end
  endgenerate

endmodule

