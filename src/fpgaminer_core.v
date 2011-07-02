module fpgaminer_core #( 
    // The LOOP_LOG2 parameter determines how unrolled the SHA-256
    // calculations are. For example, a setting of 1 will completely
    // unroll the calculations, resulting in 128 rounds and a large, fast
    // design.
    //
    // A setting of 2 will result in 64 rounds, with half the size and
    // half the speed. 3 will be 32 rounds, with 1/4th the size and speed.
    // And so on.
    //
    // Valid range: [0, 5]
    parameter LOOP_LOG2
  )
  (
    input clk,

    input [255:0] midstate_vw,
    input [255:0] data2_vw,
    output reg [31:0] golden_nonce,
    output reg [31:0] nonce

);
	// No need to adjust this parameter
	localparam [5:0] LOOP = (6'd1 << LOOP_LOG2);
	// "-1" parameter to simplify masking below, and avoid a warning.
	localparam [5:0] LOOPMINUS1 = LOOP[5:0] - 6'd1;


	// The nonce will always be larger at the time we discover a valid
	// hash. This is its offset from the nonce that gave rise to the valid
	// hash (except when LOOP_LOG2 == 0 or 1, where the offset is 131 or
	// 66 respectively).
	localparam [31:0] GOLDEN_NONCE_OFFSET = (32'd1 << (7 - LOOP_LOG2)) + 32'd1;

	//// 
	reg [255:0] state = 0;
	reg [511:0] data = 0;

	//// Hashers
	wire [255:0] hash, hash2;
	reg [5:0] cnt = 6'd0;
	reg feedback = 1'b0;

	sha256_transform #(.LOOP(LOOP)) uut (
		.clk(clk),
		.feedback(feedback),
		.cnt(cnt),
		.rx_state(state),
		.rx_input(data),
		.tx_hash(hash)
	);
	sha256_transform #(.LOOP(LOOP)) uut2 (
		.clk(clk),
		.feedback(feedback),
		.cnt(cnt),
		.rx_state(256'h5be0cd191f83d9ab9b05688c510e527fa54ff53a3c6ef372bb67ae856a09e667),
		.rx_input({256'h0000010000000000000000000000000000000000000000000000000080000000, hash}),
		.tx_hash(hash2)
	);

	//// Control Unit
	reg is_golden_ticket = 1'b0;
	reg feedback_d1 = 1'b1;
	wire [5:0] cnt_next;
	wire [31:0] nonce_next;
	wire feedback_next;
	`ifndef SIM
		wire reset;
		assign reset = 1'b0;
	`else
		reg reset = 1'b0;	// NOTE: Reset is not currently used in the actual FPGA; for simulation only.
	`endif

	assign cnt_next =  reset ? 6'd0 : (cnt + 6'd1) & LOOPMINUS1[5:0];
	// On the first count (cnt==0), load data from previous stage (no feedback)
	// on 1..LOOP-1, take feedback from current stage
	// This reduces the throughput by a factor of (LOOP), but also reduces the design size by the same amount
	assign feedback_next = (LOOP == 1) ? 1'b0 : (cnt_next != {(LOOP_LOG2){1'b0}});
	assign nonce_next =
		reset ? 32'd0 :
		feedback_next ? nonce : (nonce + 32'd1);

        reg [256:0] midstate_buf;
        reg [256:0] data_buf;

	always @ (posedge clk)
	begin
		`ifdef SIM
			//midstate_buf <= 256'h2b3f81261b3cfd001db436cfd4c8f3f9c7450c9a0d049bee71cba0ea2619c0b5;
			//data_buf <= 256'h00000000000000000000000080000000_00000000_39f3001b6b7b8d4dc14bfc31;
			//nonce <= 30411740;
		`else
			midstate_buf <= midstate_vw;
			data_buf <= data2_vw;
		`endif

		cnt <= cnt_next;
		feedback <= feedback_next;
		feedback_d1 <= feedback;

		// Give new data to the hasher
		state <= midstate_buf;
		data <= {384'h000002800000000000000000000000000000000000000000000000000000000000000000000000000000000080000000, nonce_next, data_buf[95:0]};
		nonce <= nonce_next;


		// Check to see if the last hash generated is valid.
		is_golden_ticket <= (hash2[255:224] == 32'h00000000) && !feedback_d1;
		if(is_golden_ticket)
		begin
			// TODO: Find a more compact calculation for this
			if (LOOP == 1)
				golden_nonce <= nonce - 32'd131;
			else if (LOOP == 2)
				golden_nonce <= nonce - 32'd66;
			else
				golden_nonce <= nonce - GOLDEN_NONCE_OFFSET;
		end
`ifdef SIM
		if (!feedback_d1)
			$display ("nonce: %8x\nhash2: %64x\n", nonce, hash2);
`endif
	end

endmodule

