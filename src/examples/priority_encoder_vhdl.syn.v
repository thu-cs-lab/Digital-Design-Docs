/* Generated by Yosys 0.16+6 (git sha1 e0ba32423, clang 11.0.1-2 -fPIC -Os) */

module priority_encoder(request, valid, user);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  input [3:0] request;
  wire [3:0] request;
  output [1:0] user;
  wire [1:0] user;
  output valid;
  wire valid;
  assign _04_ = ~request[2];
  assign _05_ = ~(request[2] | request[3]);
  assign _00_ = request[2] | request[3];
  assign _01_ = ~(request[1] | request[0]);
  assign user[1] = _00_ & _01_;
  assign valid = ~(_05_ & _01_);
  assign _02_ = _04_ & request[3];
  assign _03_ = ~(request[1] | _02_);
  assign user[0] = ~(request[0] | _03_);
endmodule
