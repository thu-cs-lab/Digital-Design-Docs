/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* src = "examples/initial.v:1.1-27.10" *)
module initial_reg(clock, reset, d, q);
  (* src = "examples/initial.v:2.8-2.13" *)
  input clock;
  wire clock;
  (* src = "examples/initial.v:4.8-4.9" *)
  input d;
  wire d;
  (* src = "examples/initial.v:5.9-5.10" *)
  output q;
  wire q;
  (* src = "examples/initial.v:8.6-8.7" *)
  wire r;
  (* src = "examples/initial.v:3.8-3.13" *)
  input reset;
  wire reset;
  assign q = 1'h0;
  assign r = 1'h0;
endmodule
