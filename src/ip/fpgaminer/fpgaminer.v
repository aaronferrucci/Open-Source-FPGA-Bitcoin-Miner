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
//  D: 256-bit read/write data2_vw.  Writes to the first 7 32-bit values are to
//  shadow register; write to the 8th register (0x1C) updates all 8 32-bit segments.
//  M: 256-bit read/write midstate_vw.  Writes to the first 7 32-bit values are to
//  shadow register; write to the 8th register (0x1C) updates all 8 32-bit segments.
//  G: golden_nonce output from fpgaminer_core.  read-only.
//  N: nonce output from fpgaminer_core.  read-only.

module fpgaminer(
  input clk,
  input reset,

  input [4:0] address,
  input write,
  input [3:0] byteenable,
  input [31:0] writedata,

  input read,
  output reg [31:0] readdata

);

  // Full-width data2_vw signal (core input)
  wire [255:0] data2_vw;
  fpgaminer_reg256 #(.BASE_ADDRESS (0)) the_data2_vw(
    .clk (clk),
    .reset (reset),
    .address (address),
    .byteenable (byteenable),
    .write (write),
    .value (data2_vw)
  );

  wire [255:0] midstate_vw;
  fpgaminer_reg256 #(.BASE_ADDRESS ('h20) ) the_midstate_vw(
    .clk (clk),
    .reset (reset),
    .address (address),
    .byteenable (byteenable),
    .write (write),
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
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      readdata <= '0;
    end
    else begin
      int i;
      readdata <= 'x;
      for (i = 0; i < 8; i = i + 1) begin
        if (read & (address == i)) begin
          readdata <=    data2_vw[32 * (i + 1) - 1 : 32 * i];
        end
        if (read & ((address + 8) == i)) begin
          readdata <= midstate_vw[32 * (i + 1) - 1 : 32 * i];
        end
      end
      if (read & (address == 'h10)) begin
        readdata <= golden_nonce;
      end
      if (read & (address == 'h18)) begin
        readdata <= nonce;
      end
    end
  end

endmodule


module fpgaminer_reg256 #(
    // Byte address of the base location of the 8 registers.
    parameter [6:0] BASE_ADDRESS = 0
  ) (
    input clk,
    input reset,
    input [4:0] address,
    input [3:0] byteenable,
    input write,
    output [255:0] value
);

  // Translate to slave-word-aligned address.
  localparam [4:0] BASE = BASE_ADDRESS / 4;

  reg [223:0] shadow;
  // Full-width data2_vw signal (core input)
  reg [255:0] value;

  int i, j, b;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      shadow <= '0;
      value <= '0;
    end
    else begin
      // Address/byteenable decoding, for shadow register writes.
      for (i = BASE; i < BASE + 'h7; i = i + 1) begin
        for (j = 0, b = 1; j < 4; j = j + 1, b = b << 1) begin
          if (write && (b & byteenable) & (address == i)) begin
            shadow[i * 32 + (j + 1) * 8  - 1: i * 32 + j * 8] <= writedata[(j + 1) * 8: j * 8]
          end
        end
      end

      // On write of the 8th register, transfer all shadow registers over.
      if (write && (|byteenable) && (address == BASE + 'h7)) begin
        value[223:0] <= shadow;
      end

      // Address/byteenable decoding for the top (8th) 32-bit value register.
      for (j = 0, b = 1; j < 4; j = j + 1, b = b << 1) begin
        if (write && (b & byteenable) & (address == 'h7)) begin
          value[7 * 32 + (j + 1) * 8 - 1 : 7*32 + j * 8] <= writedata[(j + 1) * 8: j * 8]
        end
      end
    end
  end
endmodule

