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

    clock <= 1'b0;

    #10;

    clock <= 1'b1;

    #10;

    clock <= 1'b0;

    #10;

  end

  timer inst (
    .clock(clock),
    .reset(reset),
    .timer(timer)
  );
endmodule