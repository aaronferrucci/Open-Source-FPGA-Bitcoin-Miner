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
//  --: don't care; make no assumptions about the value read at these locations.

module fpgaminer(
  input clk,
  input reset,

  input [4:0] address, // word-aligned address
  input write,
  input [3:0] byteenable,
  input [31:0] writedata,

  input read,
  output reg [31:0] readdata

);

  // Address decode
  wire select_data2_vw = (address[4:3] == 2'b00);

  wire [255:0] data2_vw;
  fpgaminer_reg256 the_data2_vw(
    .clk (clk),
    .reset (reset),
    .address (address[2:0]),
    .byteenable (byteenable),
    .writedata (writedata),
    .write (write & select_data2_vw),
    .value (data2_vw)
  );

  wire select_midstate_vw = (address[4:3] == 2'b01);
  wire [255:0] midstate_vw;
  fpgaminer_reg256 the_midstate_vw(
    .clk (clk),
    .reset (reset),
    .address (address[2:0]),
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
  wire [31:0] readdata_data2_vw;
  wire [31:0] readdata_midstate_vw;
  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : readdata_assignment
      assign readdata_data2_vw    = data2_vw[32 * (i + 1) - 1 : 32 * i];
      assign readdata_midstate_vw = midstate_vw[32 * (i + 1) - 1 : 32 * i];
    end
  endgenerate

  always @(posedge clk) begin
    if (address[4:3] == 2'b00) readdata <= readdata_data2_vw;
    if (address[4:3] == 2'b01) readdata <= readdata_midstate_vw;
    if (address[4:3] == 2'b10) readdata <= golden_nonce;
    if (address[4:3] == 2'b11) readdata <= nonce;
  end

endmodule

module fpgaminer_reg256 (
  input clk,
  input reset,
  input [2:0] address,
  input [3:0] byteenable,
  input [31:0] writedata,
  input write,
  output [255:0] readdata
);
  reg [31:0] shadow [0:6];
  reg [31:0] mem [0:7];

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      shadow[0] <= '0;
      shadow[1] <= '0;
      shadow[2] <= '0;
      shadow[3] <= '0;
      shadow[4] <= '0;
      shadow[5] <= '0;
      shadow[6] <= '0;
    end
    else if (write & (address < 'h7)) begin
      if (byteenable[0])
        shadow[address][7:0] <= writedata[7:0];
      if (byteenable[1])
        shadow[address][15:8] <= writedata[15:8];
      if (byteenable[2])
        shadow[address][23:16] <= writedata[23:16];
      if (byteenable[3])
        shadow[address][31:24] <= writedata[31:24];
    end
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      mem[0] <= '0;
      mem[1] <= '0;
      mem[2] <= '0;
      mem[3] <= '0;
      mem[4] <= '0;
      mem[5] <= '0;
      mem[6] <= '0;
      mem[7] <= '0;
    end
    else if (write & (address == 'h7)) begin
      if (|byteenable) begin
        mem[0] <= shadow[0];
        mem[1] <= shadow[1];
        mem[2] <= shadow[2];
        mem[3] <= shadow[3];
        mem[4] <= shadow[4];
        mem[5] <= shadow[5];
        mem[6] <= shadow[6];
      end
      if (byteenable[0])
        mem[7][7:0] <= writedata[7:0];
      if (byteenable[1])
        mem[7][15:8] <= writedata[15:8];
      if (byteenable[2])
        mem[7][23:16] <= writedata[23:16];
      if (byteenable[3])
        mem[7][31:24] <= writedata[31:24];
    end
  end

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin : readdata_assignment
      assign readdata[(i + 1) * 32 - 1:i * 32] = mem[i];
    end
  endgenerate

endmodule


// module fpgaminer_reg256 #(
//     // Byte address of the base location of the 8 registers.
//     parameter [6:0] BASE_ADDRESS = 0
//   ) (
//     input clk,
//     input reset,
//     input [4:0] address,
//     input [3:0] byteenable,
//     input write,
//     output reg [255:0] value
// );
// 
//   // Translate to slave-word-aligned address.
//   localparam [4:0] BASE = BASE_ADDRESS / 4;
// 
//   reg [223:0] shadow;
// 
//   genvar i, j, b;
//   generate 
//     for (i = BASE; i < BASE + 'h7; i = i + 1) begin
//       for (j = 0, b = 1; j < 4; j = j + 1, b = b << 1) begin
//         always @(posedge clk or posedge reset) begin
//           if (reset) begin
//             shadow <= '0;
//             value <= '0;
//           end
//           else begin
//             // Address/byteenable decoding, for shadow register writes.
//             if (write && (b & byteenable) & (address == i)) begin
//               shadow[i * 32 + (j + 1) * 8  - 1: i * 32 + j * 8] <= writedata[(j + 1) * 8: j * 8];
//             end
// 
//             // On write of the 8th register, transfer all shadow registers over.
//             if (write && (|byteenable) && (address == BASE + 'h7)) begin
//               value[223:0] <= shadow;
//             end
// 
//             // Address/byteenable decoding for the top (8th) 32-bit value register.
//             for (j = 0, b = 1; j < 4; j = j + 1, b = b << 1) begin
//               if (write && (b & byteenable) & (address == 'h7)) begin
//                 value[7 * 32 + (j + 1) * 8 - 1 : 7*32 + j * 8] <= writedata[(j + 1) * 8: j * 8];
//               end
//             end
//           end // !reset
//         end // always
//       end // for j 
//     end // for i
//   endgenerate
// endmodule
// 
