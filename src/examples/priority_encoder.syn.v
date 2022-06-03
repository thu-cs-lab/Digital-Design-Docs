/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* src = "examples/priority_encoder.v:1.1-38.10" *)
module priority_encoder(request, valid, user);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  (* src = "examples/priority_encoder.v:2.15-2.22" *)
  input [3:0] request;
  wire [3:0] request;
  (* src = "examples/priority_encoder.v:4.16-4.20" *)
  output [1:0] user;
  wire [1:0] user;
  (* src = "examples/priority_encoder.v:7.13-7.22" *)
  wire [1:0] user_comb;
  (* src = "examples/priority_encoder.v:3.10-3.15" *)
  output valid;
  wire valid;
  assign _04_ = ~request[2];
  assign _05_ = ~(request[3] | request[2]);
  assign _00_ = request[3] | request[2];
  assign _01_ = ~(request[0] | request[1]);
  assign valid = ~(_05_ & _01_);
  assign _02_ = request[3] & _04_;
  assign _03_ = ~(request[1] | _02_);
  assign user[0] = ~(request[0] | _03_);
  assign user[1] = _00_ & _01_;
  assign user_comb = user;
endmodule
