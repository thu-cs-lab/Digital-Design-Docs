module timer_tb ();
  reg clock;
  reg reset;
  wire [3:0] timer;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, timer_tb);

    reset <= 1'b0;
    clock <= 1'b1;

    #10;

    reset <= 1'b1;

    #10;

    reset <= 1'b0;

    #1000;
    $finish;
  end

  always #10 clock = ~clock;

  timer inst (
    .clock(clock),
    .reset(reset),
    .timer(timer)
  );
endmodule