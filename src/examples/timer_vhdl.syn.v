/* Generated by Yosys 0.16+6 (git sha1 e0ba32423, clang 11.0.1-2 -fPIC -Os) */

module timer(clock, reset, timer);
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
  (* force_downto = 32'd1 *)
  (* src = "/usr/local/bin/../share/yosys/techmap.v:270.23-270.24" *)
  wire [3:0] _038_;
  (* force_downto = 32'd1 *)
  (* src = "/usr/local/bin/../share/yosys/techmap.v:270.26-270.27" *)
  wire [3:0] _039_;
  (* force_downto = 32'd1 *)
  (* src = "/usr/local/bin/../share/yosys/techmap.v:270.23-270.24" *)
  wire [19:0] _040_;
  (* force_downto = 32'd1 *)
  (* src = "/usr/local/bin/../share/yosys/techmap.v:270.26-270.27" *)
  wire [19:0] _041_;
  input clock;
  wire clock;
  reg [19:0] counter_reg;
  input reset;
  wire reset;
  output [3:0] timer;
  wire [3:0] timer;
  reg [3:0] timer_reg;
  assign _040_[0] = ~counter_reg[0];
  assign _008_ = ~counter_reg[6];
  assign _009_ = ~counter_reg[11];
  assign _010_ = ~reset;
  assign _038_[0] = ~timer_reg[0];
  assign _011_ = counter_reg[0] & counter_reg[1];
  assign _012_ = counter_reg[2] & _011_;
  assign _013_ = counter_reg[3] & _012_;
  assign _014_ = counter_reg[4] & _013_;
  assign _015_ = counter_reg[5] & _014_;
  assign _016_ = _008_ & _015_;
  assign _017_ = counter_reg[17] & counter_reg[18];
  assign _018_ = ~(counter_reg[7] | counter_reg[8]);
  assign _019_ = counter_reg[9] & _009_;
  assign _020_ = _018_ & _019_;
  assign _021_ = _017_ & _020_;
  assign _022_ = counter_reg[14] & counter_reg[16];
  assign _023_ = counter_reg[19] & _022_;
  assign _024_ = ~(counter_reg[10] | counter_reg[13]);
  assign _025_ = ~(counter_reg[12] | counter_reg[15]);
  assign _026_ = _024_ & _025_;
  assign _027_ = _023_ & _026_;
  assign _028_ = _021_ & _027_;
  assign _001_ = ~(_016_ & _028_);
  assign _000_ = ~(_010_ & _001_);
  assign _029_ = timer_reg[0] & timer_reg[1];
  assign _039_[1] = timer_reg[0] ^ timer_reg[1];
  assign _030_ = timer_reg[2] & _029_;
  assign _039_[2] = timer_reg[2] ^ _029_;
  assign _039_[3] = timer_reg[3] ^ _030_;
  assign _041_[1] = counter_reg[0] ^ counter_reg[1];
  assign _041_[2] = counter_reg[2] ^ _011_;
  assign _041_[3] = counter_reg[3] ^ _012_;
  assign _041_[4] = counter_reg[4] ^ _013_;
  assign _041_[5] = counter_reg[5] ^ _014_;
  assign _041_[6] = counter_reg[6] ^ _015_;
  assign _031_ = counter_reg[6] & _015_;
  assign _032_ = counter_reg[7] & _031_;
  assign _041_[7] = counter_reg[7] ^ _031_;
  assign _033_ = counter_reg[8] & _032_;
  assign _041_[8] = counter_reg[8] ^ _032_;
  assign _034_ = counter_reg[9] & _033_;
  assign _041_[9] = counter_reg[9] ^ _033_;
  assign _035_ = counter_reg[10] & _034_;
  assign _041_[10] = counter_reg[10] ^ _034_;
  assign _036_ = counter_reg[11] & _035_;
  assign _041_[11] = counter_reg[11] ^ _035_;
  assign _037_ = counter_reg[12] & _036_;
  assign _041_[12] = counter_reg[12] ^ _036_;
  assign _002_ = counter_reg[13] & _037_;
  assign _041_[13] = counter_reg[13] ^ _037_;
  assign _003_ = counter_reg[14] & _002_;
  assign _041_[14] = counter_reg[14] ^ _002_;
  assign _004_ = counter_reg[15] & _003_;
  assign _041_[15] = counter_reg[15] ^ _003_;
  assign _005_ = counter_reg[16] & _004_;
  assign _041_[16] = counter_reg[16] ^ _004_;
  assign _006_ = counter_reg[17] & _005_;
  assign _041_[17] = counter_reg[17] ^ _005_;
  assign _007_ = _017_ & _005_;
  assign _041_[18] = counter_reg[18] ^ _006_;
  assign _041_[19] = counter_reg[19] ^ _007_;
  always @(posedge clock)
    if (_000_) counter_reg[0] <= 1'h0;
    else counter_reg[0] <= _040_[0];
  always @(posedge clock)
    if (_000_) counter_reg[1] <= 1'h0;
    else counter_reg[1] <= _041_[1];
  always @(posedge clock)
    if (_000_) counter_reg[2] <= 1'h0;
    else counter_reg[2] <= _041_[2];
  always @(posedge clock)
    if (_000_) counter_reg[3] <= 1'h0;
    else counter_reg[3] <= _041_[3];
  always @(posedge clock)
    if (_000_) counter_reg[4] <= 1'h0;
    else counter_reg[4] <= _041_[4];
  always @(posedge clock)
    if (_000_) counter_reg[5] <= 1'h0;
    else counter_reg[5] <= _041_[5];
  always @(posedge clock)
    if (_000_) counter_reg[6] <= 1'h0;
    else counter_reg[6] <= _041_[6];
  always @(posedge clock)
    if (_000_) counter_reg[7] <= 1'h0;
    else counter_reg[7] <= _041_[7];
  always @(posedge clock)
    if (_000_) counter_reg[8] <= 1'h0;
    else counter_reg[8] <= _041_[8];
  always @(posedge clock)
    if (_000_) counter_reg[9] <= 1'h0;
    else counter_reg[9] <= _041_[9];
  always @(posedge clock)
    if (_000_) counter_reg[10] <= 1'h0;
    else counter_reg[10] <= _041_[10];
  always @(posedge clock)
    if (_000_) counter_reg[11] <= 1'h0;
    else counter_reg[11] <= _041_[11];
  always @(posedge clock)
    if (_000_) counter_reg[12] <= 1'h0;
    else counter_reg[12] <= _041_[12];
  always @(posedge clock)
    if (_000_) counter_reg[13] <= 1'h0;
    else counter_reg[13] <= _041_[13];
  always @(posedge clock)
    if (_000_) counter_reg[14] <= 1'h0;
    else counter_reg[14] <= _041_[14];
  always @(posedge clock)
    if (_000_) counter_reg[15] <= 1'h0;
    else counter_reg[15] <= _041_[15];
  always @(posedge clock)
    if (_000_) counter_reg[16] <= 1'h0;
    else counter_reg[16] <= _041_[16];
  always @(posedge clock)
    if (_000_) counter_reg[17] <= 1'h0;
    else counter_reg[17] <= _041_[17];
  always @(posedge clock)
    if (_000_) counter_reg[18] <= 1'h0;
    else counter_reg[18] <= _041_[18];
  always @(posedge clock)
    if (_000_) counter_reg[19] <= 1'h0;
    else counter_reg[19] <= _041_[19];
  always @(posedge clock)
    if (reset) timer_reg[0] <= 1'h0;
    else if (!_001_) timer_reg[0] <= _038_[0];
  always @(posedge clock)
    if (reset) timer_reg[1] <= 1'h0;
    else if (!_001_) timer_reg[1] <= _039_[1];
  always @(posedge clock)
    if (reset) timer_reg[2] <= 1'h0;
    else if (!_001_) timer_reg[2] <= _039_[2];
  always @(posedge clock)
    if (reset) timer_reg[3] <= 1'h0;
    else if (!_001_) timer_reg[3] <= _039_[3];
  assign _038_[3:1] = timer_reg[3:1];
  assign _039_[0] = _038_[0];
  assign _040_[19:1] = counter_reg[19:1];
  assign _041_[0] = _040_[0];
  assign timer = timer_reg;
endmodule
