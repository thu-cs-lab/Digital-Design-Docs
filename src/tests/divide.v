module divide (
  input [6:0] counter,
  output [3:0] tens,
  output [3:0] ones
);

  assign ones = counter % 10;
  assign tens = counter / 10;

endmodule