# 调试相关

## SignalTap

!!! note "注意时钟"

    在使用 SignalTap 采样信号时，对于不同的时钟域必须使用不同的时钟。


在 SignalTap 中，可以从多个来源选择信号。通常，`Pre-Synthesis` 中的结构保留最为完整，而 `Post-Fit` 中已经是优化后的网表，可能丢失部分信号（或者名称被修改）。

如果 SignalTap 始终无法找到/采样某些信号，可以考虑将对应信号标记为 `dont_touch` 以防止 EDA 工具优化。不同语言中用法如下：

=== "Verilog / SystemVerilog"

    ```verilog
    (* dont_touch = "true" *) wire sig1;
    assign sig1 = in1 & in2;
    assign out1 = sig1 & in2;
    ```

=== "VHDL"

    ```vhdl
    signal sig1 : std_logic
    attribute dont_touch : string;
    attribute dont_touch of sig1 : signal is "true";
    ....
    ....
    sig1 <= in1 and in2;
    out1 <= sig1 and in3;
    ```

=== "Chisel"

    ```scala
    import chisel3.dontTouch
    class MyModule extends Module {
      val io = IO(new Bundle {
        val in = Input(UInt(8.W))
        val out = Output(UInt(8.W))
      })
      val wire = dontTouch(Wire(UInt(8.W)))
      wire := io.in
      io.out := wire
    }
    ```

