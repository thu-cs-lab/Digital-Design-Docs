# 仿真

在前面的文档里，我们学习了如何使用硬件描述语言来实现数字电路。实现了电路后，为了验证数字电路是否正确地工作，需要进行仿真。

本文将会讲述如何用 Verilog 语言来编写仿真的代码。**需要注意的是，描述数字电路的 Verilog 和用来仿真的 Verilog 可以认为是两种语言，使用完全不同的编写思路和实现方法。** 前者与电路一一对应，而后者更像是 C 这种过程式的编程语言，不是描述数字电路，而是给数字电路设定好输入的信号。

## 例子

下面来看一个简单的例子，采用的是前文出现过的加法器：

```verilog
module add2 (
  input wire [1:0] a,
  input wire [1:0] b,
  output wire [1:0] c
);
  assign c = a + b;
endmodule
```

把仿真器中运行上面的代码，会得到下面的波形：

<script type="WaveDrom">
{
  signal:
    [
      { name: "a", wave: "xxx"},
      { name: "b", wave: "xxx"},
      { name: "c", wave: "xxx"}
    ]
}
</script>

你会发现所有的信号都显示 `x`，因为仿真的时候，模块外部什么也没有，所以这里的 `a` 和 `b` 什么也没有连接，在仿真器中表示为 `x`，表示数值未知。那是不是代码出了问题？但其实这段代码描述了正确的加法器的数字电路，只不过缺少来自外部的输入。那么思路就明确了：接下来，我要给这个模块输入数据。为了输入数据，要人为地在外面再套一层，就好像从上帝视角，去设置模块的输入：

```verilog
`timescale 1ns/1ps
module add2_tb ();
  reg [1:0] a;
  reg [1:0] b;
  wire [1:0] c;

  initial begin
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
```

这段代码例化了一个 `add2` 模块，也就是要被测试的模块。首先，声明了 `a` `b` `c` 三个信号，由于这里的 `c` 连接到 `add2` 模块的输出，所以要用 `wire`；其他则是要输入到 `add2` 模块中，所以用 `reg`。

接着，在 `initial` 块中编写仿真的输入。例如，这里给 `a` 和 `b` 赋值，然后运行 `#1;` 命令，表示等待 `1ns`，然后再运行 `$finish;`，表示仿真结束。此时的仿真波形里就有了数据：

<script type="WaveDrom">
{
  signal:
    [
      { name: "a", wave: "=", data: ["01"]},
      { name: "b", wave: "=", data: ["10"]},
      { name: "c", wave: "=", data: ["11"]}
    ]
}
</script>

可以看到，上面的代码并不是在描述一个数字电路，而是在描述一个操作流程：先设置 `a` 为 `2'b01`，再设置 `b` 为 `2'b10`，等待 1ns，最后结束仿真。回顾一下数字电路实验，你在搭建好电路以后，会人为地按下按键开关，然后就可以观察到电路的变化。这里也是一样的，只不过是用 Verilog 来描述人的行为，让仿真器按照既定的流程进行操作。

继续强调：描述数字电路的 Verilog，或者说可综合的 Verilog，是奔着电路去编写的，如果写出了无法用电路实现的代码，就会出现问题；而用于仿真的 Verilog，并不对应电路，而是代替人去修改电路的输入和观察电路的输出。只是恰巧二者都是用 Verilog 语言来编写，实际上可以用不同的语言，例如用 Python 来编写仿真代码，见 [cocotb](https://www.cocotb.org/)。写代码的时候，请不要混淆两种 Verilog 语言。

## 时钟

接下来讲讲 **用于仿真** 的 Verilog，一般有哪些常用的写法。上面的例子里，已经出现过：

- 声明信号，然后连接到被测试的模块的输入输出上，例如上面的 `a` `b` `c`。
- 在 `initial` 块中编写仿真的过程。
- 修改输入信号，直接赋值即可：`a <= 2'b01`。
- 等待一段时间，例如 `#1;`，结合最开头的 ``timescale 1ns/1ps`，就是等待 1ns 的意思。
- 调用内置函数，如 `$finish;` 表示结束仿真。

接下来来仿真一个带有时序逻辑的模块，看看如何仿真时钟信号，使用前面的秒表的例子：

```verilog
module timer (
  input wire clock,
  input wire reset,
  output wire [3:0] timer
);
  reg [3:0] timer_reg;
  reg [19:0] counter_reg;

  // sequential
  always @ (posedge clock) begin
    if (reset) begin
      timer_reg <= 4'b0;
      counter_reg <= 20'b0;
    end else begin
      if (counter_reg == 20'd999999) begin
        timer_reg <= timer_reg + 4'b1;
        counter_reg <= 20'b0;
      end else begin
        counter_reg <= counter_reg + 20'b1;
      end
    end
  end

  // combinatorial
  assign timer = timer_reg;
endmodule
```

我们希望给它提供一个时钟信号，然后观察 `timer` 的变化。首先，还是按照前面的规律，例化 `timer` 模块，连接输入输出信号：

```verilog
module timer_tb ();
  reg clock;
  reg reset;
  wire [3:0] timer;

  initial begin
    // TODO
  end

  timer inst (
    .clock(clock),
    .reset(reset),
    .timer(timer)
  );
endmodule
```

接着，我们来思考如何来生成时钟信号。我们知道，时钟信号以一个固定的频率在 0 和 1 之间变化。如果频率是 50MHz，那么一个周期就是 `1 / 50MHz = 20ns`，也就是每 10ns 变化一次。按照这个思想，设定时钟信号为 1，然后等待 10ns，再设定时钟信号为 0，再等待 10ns，这样下去就可以构造出一个时钟信号来：

```verilog
initial begin
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
```

仿真上面的代码，就会得到下面的波形：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p."},
      { name: "reset", wave: "0."}
    ]
}
</script>