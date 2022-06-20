module button (
  input button,
  output light
);
  reg light_reg;

  always_ff @ (posedge button) begin
    light_reg <= ~light_reg;
  end

  assign light = light_reg;

endmodule