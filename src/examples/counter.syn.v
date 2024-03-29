/* Generated by Yosys 0.16+41 (git sha1 29c0a5958, clang 11.0.1-2 -fPIC -Os) */

(* src = "examples/counter.v:34.1-68.10" *)
module counter(clock, reset, button_debounced, ones, tens);
  wire _000_;
  (* src = "examples/counter.v:54.11-54.52" *)
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
  (* src = "examples/counter.v:37.9-37.25" *)
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
  reg _026_;
  reg _027_;
  reg _028_;
  reg _029_;
  reg _030_;
  reg _031_;
  reg _032_;
  reg _033_;
  reg _034_;
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
  wire _054_;
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
  (* src = "examples/counter.v:42.13-42.21" *)
  wire _065_;
  (* src = "examples/counter.v:42.13-42.21" *)
  wire _066_;
  (* src = "examples/counter.v:42.13-42.21" *)
  wire _067_;
  (* src = "examples/counter.v:42.13-42.21" *)
  wire _068_;
  (* src = "examples/counter.v:36.9-36.14" *)
  wire _069_;
  (* src = "examples/counter.v:43.13-43.21" *)
  wire _070_;
  (* src = "examples/counter.v:43.13-43.21" *)
  wire _071_;
  (* src = "examples/counter.v:43.13-43.21" *)
  wire _072_;
  (* src = "examples/counter.v:43.13-43.21" *)
  wire _073_;
  (* force_downto = 32'd1 *)
  (* src = "examples/counter.v:57.23-57.38|/home/jiegec/prefix/yosys/bin/../share/yosys/techmap.v:270.23-270.24" *)
  wire [3:0] _074_;
  (* force_downto = 32'd1 *)
  (* src = "examples/counter.v:57.23-57.38|/home/jiegec/prefix/yosys/bin/../share/yosys/techmap.v:270.26-270.27" *)
  wire [3:0] _075_;
  wire _076_;
  wire _077_;
  wire _078_;
  wire _079_;
  wire _080_;
  wire _081_;
  wire _082_;
  wire _083_;
  wire _084_;
  wire _085_;
  wire _086_;
  wire _087_;
  wire _088_;
  wire _089_;
  wire _090_;
  wire _091_;
  wire _092_;
  (* src = "examples/counter.v:37.9-37.25" *)
  input button_debounced;
  wire button_debounced;
  (* src = "examples/counter.v:44.7-44.27" *)
  wire button_debounced_reg;
  (* src = "examples/counter.v:35.9-35.14" *)
  input clock;
  wire clock;
  (* src = "examples/counter.v:38.16-38.20" *)
  output [3:0] ones;
  wire [3:0] ones;
  (* src = "examples/counter.v:42.13-42.21" *)
  wire [3:0] ones_reg;
  (* src = "examples/counter.v:36.9-36.14" *)
  input reset;
  wire reset;
  (* src = "examples/counter.v:39.16-39.20" *)
  output [3:0] tens;
  wire [3:0] tens;
  (* src = "examples/counter.v:43.13-43.21" *)
  wire [3:0] tens_reg;
  always @(posedge clock)
    _026_ <= _017_;
  always @(posedge clock)
    _027_ <= _018_;
  always @(posedge clock)
    _028_ <= _019_;
  always @(posedge clock)
    _029_ <= _020_;
  always @(posedge clock)
    _030_ <= _021_;
  always @(posedge clock)
    _031_ <= _022_;
  always @(posedge clock)
    _032_ <= _023_;
  always @(posedge clock)
    _033_ <= _024_;
  always @(posedge clock)
    _034_ <= _025_;
  assign _035_ = ~_069_;
  assign _036_ = ~_030_;
  assign _037_ = ~_032_;
  assign _038_ = ~_034_;
  assign _039_ = ~(_036_ | _031_);
  assign _040_ = _016_ & _038_;
  assign _041_ = _033_ & _040_;
  assign _042_ = _037_ & _041_;
  assign _043_ = _039_ & _042_;
  assign _044_ = _029_ & _043_;
  assign _045_ = _028_ & _044_;
  assign _046_ = ~(_027_ & _045_);
  assign _047_ = _026_ ^ _046_;
  assign _017_ = ~(_069_ | _047_);
  assign _048_ = _027_ | _045_;
  assign _049_ = _035_ & _048_;
  assign _018_ = _046_ & _049_;
  assign _050_ = _028_ | _044_;
  assign _051_ = ~(_035_ & _050_);
  assign _019_ = ~(_045_ | _051_);
  assign _052_ = _029_ | _043_;
  assign _053_ = ~(_035_ & _052_);
  assign _020_ = ~(_044_ | _053_);
  assign _054_ = _032_ & _041_;
  assign _055_ = ~(_031_ & _054_);
  assign _056_ = ~(_069_ | _043_);
  assign _057_ = _036_ ^ _055_;
  assign _021_ = _056_ & _057_;
  assign _058_ = _031_ | _054_;
  assign _059_ = _035_ & _058_;
  assign _022_ = _055_ & _059_;
  assign _060_ = ~(_069_ | _041_);
  assign _061_ = ~(_032_ & _060_);
  assign _062_ = ~(_069_ | _039_);
  assign _063_ = ~(_042_ & _062_);
  assign _023_ = ~(_061_ & _063_);
  assign _064_ = _033_ | _040_;
  assign _024_ = _060_ & _064_;
  assign _025_ = _035_ & _016_;
  assign _074_[3:1] = tens_reg[3:1];
  assign _075_[0] = _074_[0];
  assign ones = ones_reg;
  assign tens = tens_reg;
  assign _065_ = _033_;
  assign _066_ = _032_;
  assign _067_ = _031_;
  assign _068_ = _030_;
  assign _070_ = _029_;
  assign _071_ = _028_;
  assign _072_ = _027_;
  assign _073_ = _026_;
  assign tens_reg[3] = _073_;
  assign tens_reg[2] = _072_;
  assign tens_reg[1] = _071_;
  assign tens_reg[0] = _070_;
  assign ones_reg[3] = _068_;
  assign ones_reg[2] = _067_;
  assign ones_reg[1] = _066_;
  assign ones_reg[0] = _065_;
  assign _069_ = reset;
  assign _016_ = button_debounced;
endmodule

(* top =  1  *)
(* src = "examples/counter.v:70.1-95.10" *)
module counter_top(clock, reset, button, ones, tens);
  (* src = "examples/counter.v:73.9-73.15" *)
  input button;
  wire button;
  (* src = "examples/counter.v:78.8-78.24" *)
  wire button_debounced;
  (* src = "examples/counter.v:71.9-71.14" *)
  input clock;
  wire clock;
  (* src = "examples/counter.v:74.16-74.20" *)
  output [3:0] ones;
  wire [3:0] ones;
  (* src = "examples/counter.v:72.9-72.14" *)
  input reset;
  wire reset;
  (* src = "examples/counter.v:75.16-75.20" *)
  output [3:0] tens;
  wire [3:0] tens;
  (* module_not_derived = 32'd1 *)
  (* src = "examples/counter.v:87.11-93.4" *)
  counter counter_component (
    .button_debounced(button_debounced),
    .clock(clock),
    .ones(ones),
    .reset(reset),
    .tens(tens)
  );
  (* module_not_derived = 32'd1 *)
  (* src = "examples/counter.v:80.13-85.4" *)
  debouncer debouncer_component (
    .button(button),
    .button_debounced(button_debounced),
    .clock(clock),
    .reset(reset)
  );
endmodule

(* src = "examples/counter.v:1.1-32.10" *)
module debouncer(clock, reset, button, button_debounced);
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
  (* src = "examples/counter.v:4.9-4.15" *)
  wire _039_;
  (* src = "examples/counter.v:9.7-9.27" *)
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
  wire _054_;
  wire _055_;
  wire _056_;
  wire _057_;
  wire _058_;
  reg _059_;
  reg _060_;
  reg _061_;
  reg _062_;
  reg _063_;
  reg _064_;
  reg _065_;
  reg _066_;
  reg _067_;
  reg _068_;
  reg _069_;
  reg _070_;
  reg _071_;
  reg _072_;
  reg _073_;
  reg _074_;
  reg _075_;
  reg _076_;
  wire _077_;
  wire _078_;
  wire _079_;
  wire _080_;
  wire _081_;
  wire _082_;
  wire _083_;
  wire _084_;
  wire _085_;
  wire _086_;
  wire _087_;
  wire _088_;
  wire _089_;
  wire _090_;
  wire _091_;
  wire _092_;
  wire _093_;
  wire _094_;
  wire _095_;
  wire _096_;
  wire _097_;
  wire _098_;
  wire _099_;
  wire _100_;
  wire _101_;
  wire _102_;
  wire _103_;
  wire _104_;
  wire _105_;
  wire _106_;
  wire _107_;
  wire _108_;
  wire _109_;
  wire _110_;
  wire _111_;
  wire _112_;
  wire _113_;
  wire _114_;
  wire _115_;
  wire _116_;
  wire _117_;
  wire _118_;
  wire _119_;
  wire _120_;
  wire _121_;
  wire _122_;
  wire _123_;
  wire _124_;
  wire _125_;
  wire _126_;
  wire _127_;
  wire _128_;
  wire _129_;
  wire _130_;
  wire _131_;
  wire _132_;
  wire _133_;
  wire _134_;
  wire _135_;
  wire _136_;
  wire _137_;
  wire _138_;
  wire _139_;
  wire _140_;
  wire _141_;
  wire _142_;
  wire _143_;
  (* src = "examples/counter.v:3.9-3.14" *)
  wire _144_;
  (* force_downto = 32'd1 *)
  (* src = "examples/counter.v:23.26-23.45|/home/jiegec/prefix/yosys/bin/../share/yosys/techmap.v:270.23-270.24" *)
  wire [15:0] _145_;
  (* force_downto = 32'd1 *)
  (* src = "examples/counter.v:23.26-23.45|/home/jiegec/prefix/yosys/bin/../share/yosys/techmap.v:270.26-270.27" *)
  wire [15:0] _146_;
  wire _147_;
  wire _148_;
  wire _149_;
  wire _150_;
  wire _151_;
  wire _152_;
  wire _153_;
  wire _154_;
  wire _155_;
  wire _156_;
  wire _157_;
  wire _158_;
  wire _159_;
  wire _160_;
  wire _161_;
  wire _162_;
  wire _163_;
  wire _164_;
  wire _165_;
  wire _166_;
  wire _167_;
  wire _168_;
  wire _169_;
  wire _170_;
  wire _171_;
  wire _172_;
  wire _173_;
  wire _174_;
  wire _175_;
  wire _176_;
  wire _177_;
  wire _178_;
  wire _179_;
  wire _180_;
  wire _181_;
  (* src = "examples/counter.v:4.9-4.15" *)
  input button;
  wire button;
  (* src = "examples/counter.v:5.10-5.26" *)
  output button_debounced;
  wire button_debounced;
  (* src = "examples/counter.v:9.7-9.27" *)
  wire button_debounced_reg;
  (* src = "examples/counter.v:2.9-2.14" *)
  input clock;
  wire clock;
  (* src = "examples/counter.v:8.14-8.25" *)
  wire [15:0] counter_reg;
  (* src = "examples/counter.v:7.7-7.22" *)
  wire last_button_reg;
  (* src = "examples/counter.v:3.9-3.14" *)
  input reset;
  wire reset;
  always @(posedge clock)
    _059_ <= _041_;
  always @(posedge clock)
    _060_ <= _042_;
  always @(posedge clock)
    _061_ <= _043_;
  always @(posedge clock)
    _062_ <= _044_;
  always @(posedge clock)
    _063_ <= _045_;
  always @(posedge clock)
    _064_ <= _046_;
  always @(posedge clock)
    _065_ <= _047_;
  always @(posedge clock)
    _066_ <= _048_;
  always @(posedge clock)
    _067_ <= _049_;
  always @(posedge clock)
    _068_ <= _050_;
  always @(posedge clock)
    _069_ <= _051_;
  always @(posedge clock)
    _070_ <= _052_;
  always @(posedge clock)
    _071_ <= _053_;
  always @(posedge clock)
    _072_ <= _054_;
  always @(posedge clock)
    _073_ <= _055_;
  always @(posedge clock)
    _074_ <= _056_;
  always @(posedge clock)
    _075_ <= _057_;
  always @(posedge clock)
    _076_ <= _058_;
  assign _104_ = ~_144_;
  assign _105_ = ~_073_;
  assign _106_ = ~_075_;
  assign _107_ = ~(_104_ & _059_);
  assign _108_ = ~(_039_ | _076_);
  assign _109_ = _039_ ^ _076_;
  assign _110_ = ~(_144_ | _109_);
  assign _111_ = ~(_063_ | _064_);
  assign _112_ = _062_ & _065_;
  assign _113_ = _111_ & _112_;
  assign _114_ = ~(_074_ | _075_);
  assign _115_ = ~(_060_ | _061_);
  assign _116_ = _114_ & _115_;
  assign _117_ = _113_ & _116_;
  assign _118_ = ~(_070_ | _072_);
  assign _119_ = _071_ & _105_;
  assign _120_ = _118_ & _119_;
  assign _121_ = _066_ & _067_;
  assign _122_ = ~(_068_ | _069_);
  assign _123_ = _121_ & _122_;
  assign _124_ = _120_ & _123_;
  assign _125_ = _117_ & _124_;
  assign _126_ = ~(_110_ & _125_);
  assign _127_ = ~(_107_ & _126_);
  assign _128_ = ~(_108_ & _125_);
  assign _041_ = _127_ & _128_;
  assign _129_ = _074_ & _075_;
  assign _130_ = _073_ & _129_;
  assign _131_ = _072_ & _130_;
  assign _132_ = _071_ & _131_;
  assign _133_ = _070_ & _132_;
  assign _134_ = _069_ & _133_;
  assign _135_ = _068_ & _134_;
  assign _136_ = _067_ & _135_;
  assign _137_ = _066_ & _136_;
  assign _138_ = _065_ & _137_;
  assign _139_ = _064_ & _138_;
  assign _140_ = _063_ & _139_;
  assign _141_ = _062_ & _140_;
  assign _142_ = _061_ & _141_;
  assign _143_ = _060_ ^ _142_;
  assign _042_ = _110_ & _143_;
  assign _077_ = _061_ | _141_;
  assign _078_ = ~(_110_ & _077_);
  assign _043_ = ~(_142_ | _078_);
  assign _079_ = _062_ | _140_;
  assign _080_ = ~(_110_ & _079_);
  assign _044_ = ~(_141_ | _080_);
  assign _081_ = _063_ | _139_;
  assign _082_ = ~(_110_ & _081_);
  assign _045_ = ~(_140_ | _082_);
  assign _083_ = _064_ | _138_;
  assign _084_ = ~(_110_ & _083_);
  assign _046_ = ~(_139_ | _084_);
  assign _085_ = _065_ | _137_;
  assign _086_ = ~(_110_ & _085_);
  assign _047_ = ~(_138_ | _086_);
  assign _087_ = _066_ | _136_;
  assign _088_ = ~(_110_ & _087_);
  assign _048_ = ~(_137_ | _088_);
  assign _089_ = _067_ | _135_;
  assign _090_ = ~(_110_ & _089_);
  assign _049_ = ~(_136_ | _090_);
  assign _091_ = _068_ | _134_;
  assign _092_ = ~(_110_ & _091_);
  assign _050_ = ~(_135_ | _092_);
  assign _093_ = _069_ | _133_;
  assign _094_ = ~(_110_ & _093_);
  assign _051_ = ~(_134_ | _094_);
  assign _095_ = _070_ | _132_;
  assign _096_ = ~(_110_ & _095_);
  assign _052_ = ~(_133_ | _096_);
  assign _097_ = _071_ | _131_;
  assign _098_ = ~(_110_ & _097_);
  assign _053_ = ~(_132_ | _098_);
  assign _099_ = _072_ | _130_;
  assign _100_ = ~(_110_ & _099_);
  assign _054_ = ~(_131_ | _100_);
  assign _101_ = _073_ ^ _129_;
  assign _055_ = _110_ & _101_;
  assign _102_ = ~(_114_ | _129_);
  assign _056_ = _110_ & _102_;
  assign _103_ = ~(_106_ & _110_);
  assign _057_ = ~(_125_ | _103_);
  assign _058_ = _104_ & _039_;
  assign _145_[15:1] = counter_reg[15:1];
  assign _146_[0] = _145_[0];
  assign button_debounced = button_debounced_reg;
  assign _040_ = _059_;
  assign button_debounced_reg = _040_;
  assign _144_ = reset;
  assign _039_ = button;
endmodule
