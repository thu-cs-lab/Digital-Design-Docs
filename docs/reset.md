# 复位

时序逻辑通常需要复位信号，用于重置电路状态。本页是关于复位的一些注意事项。

!!! warning "尽量不要使用异步复位"

    Vivado Design Suite User Guide: Synthesis (UG901) 的第四章 HDL Coding Techniques 的 Coding Guidelines 部分指出：

    Do not asynchronously set or reset registers:  

      * Control set remapping becomes impossible.
      * Sequential functionality in device resources such as block RAM components and DSP blocks can be set or reset synchronously only.
      * If you use asynchronously set or reset registers, you cannot leverage device resources, or those resources are configured sub-optimally.
    
    考虑到 FPGA 复位大多来源于按钮触发，时间足够长，请遵守官方的指导，尽量只使用同步复位。

## 信号极性

复位信号通常分为低有效和高有效，为了防止混淆，通常命名为 `rst_n` 和 `rst`。

## 同步与异步

最常用的复位方式分为两种，即同步复位和异步复位，代码如下：

```verilog
reg [3:0] counter;
// synchronous reset
always @(posedge clk) begin
// asynchronous reset
always @(posedge clk, posedge rst) begin
    if (rst) begin
        counter <= 0;
    end else begin
        counter <= counter + 1';
    end
end
```

其语法区别在于 `rst` 是否在 `always` 的敏感信号列表中，而表现差异是复位信号是否立即生效/失效。
在 Xilinx FPGA 上，这两种不同的语义会被使用不同的寄存器原语表达（同步使用 FDRE、异步使用 FDCE），在逻辑复杂度上没有区别。

由于复位的异步释放可能会导致亚稳态，而同步复位又可能无法采样到短暂的复位信号，因此通常使用的复位方式是两者的结合，被称为“异步复位，同步释放”。代码如下：

```verilog
reg [1:0] rst_sync
wire rst_synced;

// use rst_synced as asynchronous reset of all modules
assign rst_synced = rst_sync[1];

always @(posedge clk, posedge rst) begin
    if (rst) begin
        rst_sync <= 2'b11;
    end else begin
        rst_sync <= {rst_sync[0], rst};
    end
end
```

事实上，这种做法就是将 `rst` 的释放延迟两周期采样，与跨时钟域的同步原理相同（采样信号也可以视作来自外部时钟域）。我们推荐在需要异步复位时，**只** 采用这种形式。

??? question "`rst_synced` 应该用做其他需要复位模块的同步还是异步信号？"

    异步复位，否则就无法做到立刻捕获复位信号，同步释放也失去意义了。

