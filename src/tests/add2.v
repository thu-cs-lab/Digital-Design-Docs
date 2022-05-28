module add2(
  input a_0,
  input a_1,
  input b_0,
  input b_1,
  output c_0,
  output c_1
);

	always @ (*) begin
		{c_1, c_0} = {a_1, a_0} + {b_1, b_0};
	end

endmodule
