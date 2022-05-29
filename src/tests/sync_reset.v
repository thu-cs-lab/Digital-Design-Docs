module sync_reset (
  input clock,
  input reset,
  input d,
  output q
);
  reg q_reg;

  always @ (posedge clock) begin
    if (reset) begin
      q_reg <= 1'b0;
    end else begin
      q_reg <= d;
    end
  end

  assign q = q_reg;

endmodule