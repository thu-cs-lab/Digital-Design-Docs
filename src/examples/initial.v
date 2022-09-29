module initial_reg (
	input clock,
	input reset,
	input d,
	output q
);

	reg r;

	//initial r = 1'b0;
	//initial begin
		//r = 1'b0;
	//end

	always @ (posedge clock) begin
		if (reset) begin
			r <= 1'b0;
		end else begin
			r <= d;
		end
	end

	//assign q = r;
	initial q = 1'b0;
	assign q = r;

endmodule