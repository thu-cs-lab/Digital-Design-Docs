module debouncer (
  input clock,
  input reset,
  input button,
  output button_debounced
);
  reg last_button_reg;
  reg [15:0] counter_reg;
  reg button_debounced_reg;

  always @ (posedge clock) begin
    if (reset) begin
      last_button_reg <= 1'b0;
      counter_reg <= 16'b0;
      button_debounced_reg <= 1'b0;
    end else begin
      last_button_reg <= button;

      if (button == last_button_reg) begin
        if (counter_reg == 16'd10000) begin
          button_debounced_reg <= last_button_reg;
        end else begin
          counter_reg <= counter_reg + 16'b1;
        end
      end else begin
        counter_reg <= 16'b0;
      end
    end
  end

  assign button_debounced = button_debounced_reg;
endmodule

module counter (
  input clock,
  input reset,
  input button_debounced,
  output [3:0] ones,
  output [3:0] tens
);

  reg [3:0] ones_reg;
  reg [3:0] tens_reg;
  reg button_debounced_reg;

  always @ (posedge clock) begin
    if (reset) begin
      ones_reg <= 4'b0;
      tens_reg <= 4'b0;
      button_debounced_reg <= 1'b0;
    end else begin
      button_debounced_reg <= button_debounced;

      if (button_debounced && !button_debounced_reg) begin
        if (ones_reg == 4'd9) begin
          ones_reg <= 4'b0;
          tens_reg <= tens_reg + 4'b1;
        end else begin
          ones_reg <= ones_reg + 4'b1;
        end
      end
    end
  end

  assign ones = ones_reg;
  assign tens = tens_reg;

endmodule

module counter_top (
  input clock,
  input reset,
  input button,
  output [3:0] ones,
  output [3:0] tens
);

  wire button_debounced;

  debouncer debouncer_component (
    .clock(clock),
    .reset(reset),
    .button(button),
    .button_debounced(button_debounced)
  );

  counter counter_component (
    .clock(clock),
    .reset(reset),
    .button_debounced(button_debounced),
    .ones(ones),
    .tens(tens)
  );

endmodule