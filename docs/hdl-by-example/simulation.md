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
    a = 2'b01;
    b = 2'b10;
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
- 修改输入信号，直接赋值即可：`a = 2'b01`。
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
  reset = 1'b0;
  clock = 1'b1;

  #10;

  clock = 1'b0;

  #10;

  clock = 1'b1;

  #10;

  clock = 1'b0;

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

但是我们希望仿真更多时钟周期，按照上面的写法，每仿真一个时钟周期，就需要反复地设置 `clock` 信号和等待 `#10;`，十分麻烦，能否自动生成时钟信号？

答案是可以，写法是在 `initial` 之外，写一句 `always #10 clock = ~clock;`：

```verilog
initial begin
  reset = 1'b0;
  clock = 1'b1;
end

always #10 clock = ~clock;
```

代码 `always #10 clock = ~clock;` 的含义就是一直重复执行 `#10 clock = ~clock;` 代码，这句话的意思就是等待 10ns，然后 clock 取反，再等待 10ns，clock 再取反，永远循环下去。只需要一开始初始化了 `clock <= 1'b1`，后面就不再需要设置时钟了。

## 复位

处理好时钟以后，仿真上面的代码，你会发现 `timer` 输出一直是 `x`，这是因为 `timer` 没有被复位，仿真的整个过程中，也没有出现 `reset` 为 1 的时候。因此，我们需要进行复位：先设置 `reset` 为 1，再设置 `reset` 为 0：

```verilog
initial begin
  reset = 1'b0;
  clock = 1'b1;

  #10;

  reset = 1'b1;

  #10;

  reset = 1'b0;
end

always #10 clock = ~clock;
```

修改以后，得到了正确的波形：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p.p.."},
      { name: "reset", wave: "0hl.."},
      { name: "timer", wave: "x.0.."}
    ]
}
</script>

可以看到，`timer` 被成功复位成了 `0`，不再是 `x`。但是继续仿真下去，你会发现 `timer` 很长时间里一直是 `0`，这是不是很奇怪？计时器的功能是每过一段时间加一，按理说仿真里也要看到 `timer` 变成 1 才对。

但转念一想，这里一个周期只有 20ns，但是在 `timer` 中，需要计数到 1,000,000 个周期才会给输出加一。这意味着，只有仿真到 1,000,000 个周期以后，才会看到 `timer` 的变化。仿真的时间尺度是很小的，人感知的时间通常是 ms 级别，仿真里就好像时间过得特别缓慢，仿真了很久波形也才跑了多少个 ms。所以为了仿真，有时候可以人为的“加速”，例如把 1,000,000 改成 100，那么就可以很容易地在仿真中观测到变化。

学习到这里，就足够编写一些简单的仿真测试代码了。通常流程是，先设想要测试的情况，然后设计出波形，把波形里面的输入部分翻译成 Verilog 代码。启动仿真，然后在波形中观察输出是否符合自己的预期结果。

## 构造输入

目前的仿真顶层模块只提供了时钟信号和复位信号，没有提供要测试的模块的其他输入信号，那么如果仿真一些需要解析输入数据的模块，例如 PS/2 键盘控制器，只提供时钟和复位信号的情况下，测试不出输入部分的逻辑的问题。

因此，仿真顶层模块还需要针对特定的协议，人为构造输入。具体做法和上面类似，只不过要修改的是协议相关的输入信号。下面以 PS/2 键盘控制器为例，例如如果要构造 `scancode=0xF0` 的输入，需要做哪些事情：

首先，声明 ps2 相关的信号并连接到要测试的模块：

```verilog
reg ps2_clock;
reg ps2_data;

ps2_keyboard dut (
  .clock(clock),
  .reset(reset),

  .ps2_clock(ps2_clock),
  .ps2_data(ps2_data)
);
```

接着，按照 PS/2 的协议，按一定的顺序给 ps2_clock 和 ps2_data 赋值，中间穿插着延迟语句，这样就构造了满足要求的输入：

```verilog
ps2_data = 1'b1;
ps2_clock = 1'b1;
#5;

// start bit
ps2_data = 1'b0;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;

// scancode[0]=0
ps2_data = 1'b0;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;

// scancode[1]=0
ps2_data = 1'b0;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;

// omitted, repeat until scancode[7]

// scancode[7]=1
ps2_data = 1'b1;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;

// parity=1
ps2_data = 1'b1;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;

// stop
ps2_data = 1'b1;
#5;
ps2_clock = 1'b0;
#5;
ps2_clock = 1'b1;
```

类似地，其他协议也可以用类似的方法来构造。构造的时候，边改仿真代码，边观察仿真波形，直到实现想要的波形为止。需要注意延迟的时间，是否满足时钟频率的要求。

更进一步，如果想要重复发送 scancode，只不过 scancode 的内容会更改，可以把这一个步骤封装成一个 task，完整写法见 [Tsinghua GitLab](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/blob/2076e9ffc1ff3e923365a9e79d6a944544a3b8e8/src/keyboard_tb.v#L12)。

## 解析输出

在上面的部分里，模块的输出的检查，需要人去观察波形，在大脑中和预期结果比对。实际上，也可以在仿真的顶层模块中，实现输出的解析，把内容打印到标准输出中，也可以将结果与预期值进行比对，减少了人的负担。

在 Verilog 中，可以用 `$display` 命令进行打印。如果模块给出的结果与预期值不符，可以用 `$display` 命令输出错误信息，然后用 `$fatal` 命令来结束仿真。[Tsinghua GitLab](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/blob/647126c61870eede01e200844fb1c2d48f8acf31/src/sdcard_tb.v#L76) 中提供了一个解析 SPI SD 卡控制器输出的实现，可以打印出控制器发送的命令内容。

## 总结

总结一下上面提到的如何编写用于仿真的 Verilog：

- 单独写一个用于仿真的顶层模块，例化要测试的模块（Device Under Test）。
- 把要测试的模块的输入输出都接到 `reg` 或者 `wire` 上。
- 对于时序逻辑，在 `initial` 块开头初始化时钟信号，然后用 `always #10 clock = ~clock;` 代码来自动生成时钟信号。
- 生成复位信号，在 `initial` 块内，模拟仿真信号由 0 变成 1，再由 1 变成 0 的过程。
- 生成输入信号，在 `initial` 块内，对输入信号对应的 `reg` 信号进行赋值。
- 在波形中观察模块输出和内部信号的变化。
- 如果要测试的模块需要从外部获取数据，可以在仿真的顶层模块中按照协议，生成信号并输入到要测试的模块中。
- 如果从波形上不容易看出数据，可以在仿真的顶层模块中进行解析和打印。
- 可以用仿真来做单元测试，如果结果与预期不符，就用 `$fatal` 表示仿真失败。

## 命令行仿真

上面的教程假设了你在 GUI 中仿真，可以直接看到仿真的波形。如果你希望在命令行中仿真，那么需要额外的工作来生成波形文件。一个比较通用的做法是，在 Verilog 中添加代码：

```verilog
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top_module_name);
end
```

意思是指定输出波形问题名为 `dump.vcd`，输出从模块 `top_module_name` 以下的所有信号。仿真完成后，可以用 gtkwave 打开 dump.vcd 查看生成的波形文件。

下面讲述如何在命令行中运行仿真器，假设源代码包括 `a.v` 和 `b.v`，顶层模块名字为 `sim_top`：

1. Icarus Verilog：
    1. 运行 `iverilog -s sim_top -o sim a.v b.v`
    2. 运行 `./sim`
2. ModelSim：
    1. 把 ModelSim 的 bin 目录加到 PATH 中
    2. 运行 `vlib work`
    3. 运行 `vlog a.v`
    4. 运行 `vlog b.v`
    5. 运行 `vsim -c work.sim_top -do "run -all"`
3. Vivado:
    1. 把 Vivado 的 bin 目录加到 PATH 中
    2. 运行 `xvlog a.v`
    3. 运行 `xvlog b.v`
    4. 运行 `xelab -debug all --snapshot sim_top sim_top`
    5. 运行 `xsim sim_top`

如果仿真的模块中包含由 Quartus 提供的 IP，那么仿真的时候，还需要把 quartus 安装目录下的 `quartus/eda/sim_lib/altera_mf.v` 文件也当成一个源代码，加入到上面的命令中。
