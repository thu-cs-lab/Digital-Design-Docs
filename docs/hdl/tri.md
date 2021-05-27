# 三态门

在一些接口协议中，比如 I2C、SPI 等等，为了节省引脚数量，都出现了同一个信号在不同的时间传输不同方向的数据的现象。因此，为了防止两端设备同时输出，设备在不输出信号时需要设置高阻态。在 Verilog 代码中，我们通常会将三态门 `signal_io` 拆分成三个信号：`signal_i`、`signal_o` 和 `signal_t`，分别表示输入、输出和高阻态。对应的代码如下：

```verilog
module tri_state_logic (
    inout signal_io
);

    wire signal_i;
    wire signal_o;
    wire signal_t;

    assign signal_io = signal_t ? 1'bz : signal_o;
    assign signal_i = signal_io;

endmodule
```

这样实现以后，内部就可以很方便地处理三态逻辑了。