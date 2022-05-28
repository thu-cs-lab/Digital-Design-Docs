module and2(
  input wire a,
  input wire b, 
  output wire y
);

	always @ (*) begin
		y = a & b;
	end

endmodule
