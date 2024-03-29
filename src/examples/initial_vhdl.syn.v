/* Generated by Yosys 0.17+94 (git sha1 d1b2beab1, clang 11.0.1-2 -fPIC -Os) */

module initial_reg(clock, reset, d, q);
  input clock;
  wire clock;
  input d;
  wire d;
  output q;
  reg q = 1'h0;
  wire r;
  input reset;
  wire reset;
  always @(posedge clock)
    if (reset) q <= 1'h0;
    else q <= d;
  assign r = q;
endmodule
