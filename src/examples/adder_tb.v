`timescale 1ns/1ps
module add2_tb ();
  reg [1:0] a;
  reg [1:0] b;
  wire [1:0] c;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, add2_tb);

    a <= 2'b01;
    b <= 2'b10;
    #1;
    $finish;
  end

  add2 inst (
    .a(a),
    .b(b),
    .c(c)
  );
endmodule