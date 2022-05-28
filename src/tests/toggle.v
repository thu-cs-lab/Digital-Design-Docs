module toggle (
  input button,
  output light
);
	always @(posedge button) begin
		light <= ~light;
	end
endmodule