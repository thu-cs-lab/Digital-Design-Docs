module add2 (
  input [1:0] a,
  input [1:0] b,
  output [1:0] c
);
  assign c = a + b;
endmodule