module timer (
  input clock,
  input reset,
  output [3:0] timer
);

  reg [3:0] timer_reg;
  reg [19:0] counter_reg;

  // sequential
  always @ (posedge clock) begin
    if (reset) begin
      timer_reg <= 4'b0;
      counter_reg <= 20'b0;
    end else begin
      if (counter_reg == 20'd999999) begin
        timer_reg <= timer_reg + 4'b1;
        counter_reg <= 20'b0;
      end else begin
        counter_reg <= counter_reg + 20'b1;
      end
    end
  end

  // combinatorial
  assign timer = timer_reg;

endmodule