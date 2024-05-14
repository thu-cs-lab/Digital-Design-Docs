# 调试相关

## ILA 集成逻辑分析仪

Xilinx 的 FPGA，支持在 FPGA 内部进行“调试”：实际上，就是在 FPGA 内部内嵌一个逻辑分析仪，不断地对内部信号进行采样，保存下来，传输到电脑上进行展示。这个功能，在 Vivado 中叫做 ILA（Integrated Logic Analyzer）。

为了让 Vivado 插入集成逻辑分析仪，需要进行如下步骤：

1.（可选）修改代码，在想要调试的信号上添加 (* mark_debug = "true" *) 标记
2. 点击 Run Synthesis 进行综合
3. 综合完成后然后点击 Open Synthesized Design
4. 点击 Setup Debug，Vivado 会显示你已经配置了 ILA 调试或者标记了 mark_debug 的信号
5. 从中选择要观察的信号，如果没有 mark_debug，也可以手动搜索并添加信号，注意信号综合后，名称可能和源码不完全一致
6. 给每个要观察的信号，设置采样的时钟域，建议选择该信号所在时钟域的时钟
7. 按照提示完成配置，完成配置后，点击保存（非常重要，不要忘记）
8. 如果是第一次配置 ILA，Vivado 会提示保存的文件名，建议选择保存到新文件 debug.xdc，防止污染 io.xdc 的内容
9. 观察 debug.xdc 的内容，确认出现了自己配置 ILA 的相关信号的名称
10. 重新生成 Bitstream
11. Program Device 后，即可在打开的 Hardware Manager 中找到 ILA 界面，观察信号的状态

对于 ILA 界面的使用方式，建议阅读 [Vivado Design Suite User Guide](https://www.xilinx.com/support/documents/sw_manuals/xilinx2022_1/ug908-vivado-programming-debugging.pdf) 第 11 章。

!!! note "注意时钟"

    因为逻辑分析仪的原理是用指定的时钟不断地采样 FPGA 内部信号，所以在使用 ILA 采样信号时，被采样的信号与所使用的时钟要对应，因此通常情况下不同的时钟域会使用不同的时钟，也就可能需要创建多个集成逻辑分析仪实例。

在 ILA 中，可以从多个来源选择要采样的信号。通常，`Pre-Synthesis` 中的结构保留最为完整，而 `Post-Fit` 中已经是优化后的网表，可能丢失部分信号（或者名称被修改）。

如果 ILA 始终无法找到/采样某些信号，可以考虑将对应信号标记为 `dont_touch` 以防止 EDA 工具优化。不同语言中用法如下：

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

