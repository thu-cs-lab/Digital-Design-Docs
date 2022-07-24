/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* top =  1  *)
(* src = "examples/rr_arbiter.v:101.1-159.10" *)
module rr_arbiter(clock, reset, request, valid, user);
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  wire _08_;
  wire _09_;
  wire _10_;
  wire _11_;
  wire _12_;
  wire _13_;
  wire _14_;
  wire _15_;
  wire _16_;
  reg _17_;
  reg _18_;
  reg _19_;
  wire _20_;
  wire _21_;
  wire _22_;
  wire _23_;
  wire _24_;
  wire _25_;
  wire _26_;
  wire _27_;
  wire _28_;
  wire _29_;
  wire _30_;
  wire _31_;
  wire _32_;
  wire _33_;
  wire _34_;
  (* src = "examples/rr_arbiter.v:113.13-113.39" *)
  wire _35_;
  (* src = "examples/rr_arbiter.v:113.13-113.39" *)
  wire _36_;
  (* src = "examples/rr_arbiter.v:105.15-105.22" *)
  wire _37_;
  (* src = "examples/rr_arbiter.v:105.15-105.22" *)
  wire _38_;
  (* src = "examples/rr_arbiter.v:105.15-105.22" *)
  wire _39_;
  (* src = "examples/rr_arbiter.v:105.15-105.22" *)
  wire _40_;
  (* src = "examples/rr_arbiter.v:103.9-103.14" *)
  wire _41_;
  (* src = "examples/rr_arbiter.v:107.16-107.20" *)
  wire _42_;
  (* src = "examples/rr_arbiter.v:107.16-107.20" *)
  wire _43_;
  (* src = "examples/rr_arbiter.v:109.13-109.21" *)
  wire _44_;
  (* src = "examples/rr_arbiter.v:109.13-109.21" *)
  wire _45_;
  (* src = "examples/rr_arbiter.v:106.10-106.15" *)
  wire _46_;
  wire _47_;
  wire _48_;
  wire _49_;
  wire _50_;
  wire _51_;
  (* src = "examples/rr_arbiter.v:102.9-102.14" *)
  input clock;
  wire clock;
  (* src = "examples/rr_arbiter.v:113.13-113.39" *)
  wire [1:0] priority_encoder_user_comb;
  (* src = "examples/rr_arbiter.v:105.15-105.22" *)
  input [3:0] request;
  wire [3:0] request;
  (* src = "examples/rr_arbiter.v:103.9-103.14" *)
  input reset;
  wire reset;
  (* src = "examples/rr_arbiter.v:107.16-107.20" *)
  output [1:0] user;
  wire [1:0] user;
  (* src = "examples/rr_arbiter.v:112.13-112.22" *)
  wire [1:0] user_comb;
  (* src = "examples/rr_arbiter.v:109.13-109.21" *)
  wire [1:0] user_reg;
  (* src = "examples/rr_arbiter.v:106.10-106.15" *)
  output valid;
  wire valid;
  (* src = "examples/rr_arbiter.v:110.7-110.16" *)
  wire valid_reg;
  always @(posedge clock)
    _17_ <= _14_;
  always @(posedge clock)
    _18_ <= _15_;
  always @(posedge clock)
    _19_ <= _16_;
  assign _20_ = ~_46_;
  assign _21_ = ~_41_;
  assign _22_ = _18_ ? _40_ : _39_;
  assign _23_ = _18_ ? _38_ : _37_;
  assign _24_ = _17_ ? _22_ : _23_;
  assign _25_ = ~(_19_ & _24_);
  assign _26_ = ~(_20_ | _25_);
  assign _27_ = ~(_18_ & _26_);
  assign _28_ = _46_ & _25_;
  assign _29_ = ~(_46_ & _25_);
  assign _30_ = ~(_35_ & _28_);
  assign _42_ = ~(_27_ & _30_);
  assign _31_ = ~(_17_ & _26_);
  assign _32_ = ~(_36_ & _28_);
  assign _43_ = ~(_31_ & _32_);
  assign _33_ = _29_ ? _17_ : _36_;
  assign _14_ = _21_ & _33_;
  assign _34_ = _29_ ? _18_ : _35_;
  assign _15_ = _21_ & _34_;
  assign _16_ = _46_ & _21_;
  (* module_not_derived = 32'd1 *)
  (* src = "examples/rr_arbiter.v:115.23-120.4" *)
  rr_priority_encoder rr_priority_encoder_inst (
    .last_user(user_reg),
    .request(request),
    .user(priority_encoder_user_comb),
    .valid(valid)
  );
  assign user_comb = user;
  assign _44_ = _18_;
  assign _45_ = _17_;
  assign user_reg[1] = _45_;
  assign user_reg[0] = _44_;
  assign _46_ = valid;
  assign _41_ = reset;
  assign _36_ = priority_encoder_user_comb[1];
  assign _35_ = priority_encoder_user_comb[0];
  assign _37_ = request[0];
  assign _38_ = request[1];
  assign _39_ = request[2];
  assign _40_ = request[3];
  assign user[0] = _42_;
  assign user[1] = _43_;
endmodule

(* src = "examples/rr_arbiter.v:1.1-99.10" *)
module rr_priority_encoder(request, last_user, valid, user);
  wire _000_;
  wire _001_;
  wire _002_;
  wire _003_;
  wire _004_;
  wire _005_;
  wire _006_;
  wire _007_;
  wire _008_;
  wire _009_;
  wire _010_;
  wire _011_;
  wire _012_;
  wire _013_;
  wire _014_;
  wire _015_;
  wire _016_;
  wire _017_;
  wire _018_;
  wire _019_;
  wire _020_;
  wire _021_;
  wire _022_;
  wire _023_;
  wire _024_;
  wire _025_;
  wire _026_;
  wire _027_;
  wire _028_;
  wire _029_;
  wire _030_;
  wire _031_;
  wire _032_;
  wire _033_;
  wire _034_;
  wire _035_;
  wire _036_;
  wire _037_;
  wire _038_;
  wire _039_;
  wire _040_;
  wire _041_;
  wire _042_;
  wire _043_;
  wire _044_;
  wire _045_;
  wire _046_;
  wire _047_;
  wire _048_;
  wire _049_;
  wire _050_;
  wire _051_;
  wire _052_;
  wire _053_;
  (* src = "examples/rr_arbiter.v:3.15-3.24" *)
  wire _054_;
  (* src = "examples/rr_arbiter.v:3.15-3.24" *)
  wire _055_;
  wire _056_;
  wire _057_;
  wire _058_;
  wire _059_;
  wire _060_;
  wire _061_;
  wire _062_;
  wire _063_;
  wire _064_;
  wire _065_;
  wire _066_;
  wire _067_;
  wire _068_;
  wire _069_;
  wire _070_;
  wire _071_;
  wire _072_;
  wire _073_;
  wire _074_;
  wire _075_;
  wire _076_;
  wire _077_;
  wire _078_;
  wire _079_;
  wire _080_;
  (* src = "examples/rr_arbiter.v:2.15-2.22" *)
  wire _081_;
  (* src = "examples/rr_arbiter.v:2.15-2.22" *)
  wire _082_;
  (* src = "examples/rr_arbiter.v:2.15-2.22" *)
  wire _083_;
  (* src = "examples/rr_arbiter.v:2.15-2.22" *)
  wire _084_;
  (* src = "examples/rr_arbiter.v:5.16-5.20" *)
  wire _085_;
  (* src = "examples/rr_arbiter.v:5.16-5.20" *)
  wire _086_;
  (* src = "examples/rr_arbiter.v:4.10-4.15" *)
  wire _087_;
  (* src = "examples/rr_arbiter.v:3.15-3.24" *)
  input [1:0] last_user;
  wire [1:0] last_user;
  (* src = "examples/rr_arbiter.v:2.15-2.22" *)
  input [3:0] request;
  wire [3:0] request;
  (* src = "examples/rr_arbiter.v:5.16-5.20" *)
  output [1:0] user;
  wire [1:0] user;
  (* src = "examples/rr_arbiter.v:8.13-8.22" *)
  wire [1:0] user_comb;
  (* src = "examples/rr_arbiter.v:4.10-4.15" *)
  output valid;
  wire valid;
  (* src = "examples/rr_arbiter.v:7.7-7.17" *)
  wire valid_comb;
  assign _056_ = ~_083_;
  assign _057_ = ~_082_;
  assign _058_ = ~_054_;
  assign _059_ = ~_081_;
  assign _060_ = ~(_083_ | _084_);
  assign _061_ = ~(_082_ | _081_);
  assign _062_ = _055_ & _058_;
  assign _063_ = _055_ | _054_;
  assign _064_ = ~(_061_ & _063_);
  assign _065_ = _082_ & _058_;
  assign _066_ = _055_ | _065_;
  assign _067_ = ~(_084_ & _062_);
  assign _068_ = _066_ & _067_;
  assign _069_ = _064_ & _068_;
  assign _086_ = ~(_060_ | _069_);
  assign _070_ = _082_ & _059_;
  assign _071_ = _084_ | _070_;
  assign _072_ = ~(_083_ | _055_);
  assign _073_ = _054_ ? _072_ : _055_;
  assign _074_ = ~(_071_ & _073_);
  assign _075_ = ~(_056_ & _084_);
  assign _076_ = _057_ | _062_;
  assign _077_ = ~(_075_ & _076_);
  assign _078_ = ~(_055_ & _059_);
  assign _079_ = ~(_054_ & _078_);
  assign _080_ = ~(_077_ & _079_);
  assign _085_ = ~(_074_ & _080_);
  assign _087_ = ~(_060_ & _061_);
  assign user_comb = user;
  assign valid_comb = valid;
  assign _083_ = request[2];
  assign _082_ = request[1];
  assign user[1] = _086_;
  assign _055_ = last_user[1];
  assign _054_ = last_user[0];
  assign _084_ = request[3];
  assign _081_ = request[0];
  assign user[0] = _085_;
  assign valid = _087_;
endmodule
