/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* top =  1  *)
(* src = "tests/toggle.v:1.1-8.10" *)
module toggle(button, light);
  (* src = "tests/toggle.v:5.2-7.5" *)
  wire _0_;
  (* src = "tests/toggle.v:2.9-2.15" *)
  input button;
  wire button;
  (* src = "tests/toggle.v:3.10-3.15" *)
  output light;
  reg light;
  assign _0_ = ~ (* src = "tests/toggle.v:6.12-6.18" *) light;
  (* src = "tests/toggle.v:5.2-7.5" *)
  always @(posedge button)
    light <= _0_;
endmodule
