# 调试相关

## SignalTap/ILA 集成逻辑分析仪

无论是 Intel 的 FPGA，还是 Xilinx 的 FPGA，都支持在 FPGA 内部进行“调试”：实际上，就是在 FPGA 内部内嵌一个逻辑分析仪，不断地对内部信号进行采样，保存下来，传输到电脑上进行展示。这个功能，在 Quartus 中叫做 SignalTap，在 Vivado 中叫做 ILA（Integrated Logic Analyzer）。

为了让 Quartus/Vivado 插入逻辑分析仪，需要设置如下的内容：

1. 采样的时钟来自于 FPGA 内部的哪个时钟信号
2. 使用上述时钟采样哪些信号

!!! note "注意时钟"

    因为逻辑分析仪的原理是用指定的时钟不断地采样 FPGA 内部信号，所以在使用 SignalTap/ILA 采样信号时，被采样的信号与所使用的时钟要对应，通常情况下不同的时钟域必须使用不同的时钟。

在 SignalTap/ILA 中，可以从多个来源选择要采样的信号。通常，`Pre-Synthesis` 中的结构保留最为完整，而 `Post-Fit` 中已经是优化后的网表，可能丢失部分信号（或者名称被修改）。

如果 SignalTap/ILA 始终无法找到/采样某些信号，可以考虑将对应信号标记为 `dont_touch` 以防止 EDA 工具优化。不同语言中用法如下：

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


!!! warning "不要滥用"

    `dont_touch` 会导致综合器放弃大量优化。如非必要，不要轻易使用。

