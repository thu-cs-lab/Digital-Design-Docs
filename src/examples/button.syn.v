/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* top =  1  *)
(* src = "examples/button.v:1.1-13.10" *)
module button(button, light);
  (* src = "examples/button.v:7.3-9.6" *)
  wire _0_;
  (* src = "examples/button.v:7.3-9.6" *)
  wire _1_;
  (* src = "examples/button.v:5.7-5.16" *)
  wire _2_;
  (* src = "examples/button.v:2.9-2.15" *)
  input button;
  wire button;
  (* src = "examples/button.v:3.10-3.15" *)
  output light;
  wire light;
  (* src = "examples/button.v:5.7-5.16" *)
  reg light_reg;
  assign _1_ = ~_2_;
  (* src = "examples/button.v:7.3-9.6" *)
  always @(posedge button)
    light_reg <= _0_;
  assign light = light_reg;
  assign _2_ = light_reg;
  assign _0_ = _1_;
endmodule
