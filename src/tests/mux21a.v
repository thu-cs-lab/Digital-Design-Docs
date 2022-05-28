module mux21a(
  input wire a,
  input wire b, 
  input wire s, 
  output wire y
);

	always @ (*) begin
		y = (b & s) | (a & (~s));
	end
endmodule
