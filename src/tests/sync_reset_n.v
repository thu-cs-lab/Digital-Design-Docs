module sync_reset_n (
  input clock,
  input reset_n,
  input d,
  output q
);
  reg q_reg;

  always @ (posedge clock) begin
    if (~reset_n) begin
      q_reg <= 1'b0;
    end else begin
      q_reg <= d;
    end
  end

  assign q = q_reg;

endmodule