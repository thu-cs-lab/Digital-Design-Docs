/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* top =  1  *)
(* src = "examples/adder.v:1.1-7.10" *)
module add2(a, b, c);
  wire _00_;
  wire _01_;
  (* src = "examples/adder.v:2.15-2.16" *)
  wire _02_;
  (* src = "examples/adder.v:2.15-2.16" *)
  wire _03_;
  (* src = "examples/adder.v:3.15-3.16" *)
  wire _04_;
  (* src = "examples/adder.v:3.15-3.16" *)
  wire _05_;
  (* src = "examples/adder.v:4.16-4.17" *)
  wire _06_;
  (* src = "examples/adder.v:4.16-4.17" *)
  wire _07_;
  wire _08_;
  wire _09_;
  (* src = "examples/adder.v:2.15-2.16" *)
  input [1:0] a;
  wire [1:0] a;
  (* src = "examples/adder.v:3.15-3.16" *)
  input [1:0] b;
  wire [1:0] b;
  (* src = "examples/adder.v:4.16-4.17" *)
  output [1:0] c;
  wire [1:0] c;
  assign _08_ = _04_ & _02_;
  assign _09_ = _05_ ^ _03_;
  assign _07_ = _08_ ^ _09_;
  assign _06_ = _04_ ^ _02_;
  assign _05_ = b[1];
  assign _03_ = a[1];
  assign _04_ = b[0];
  assign _02_ = a[0];
  assign c[1] = _07_;
  assign c[0] = _06_;
endmodule
