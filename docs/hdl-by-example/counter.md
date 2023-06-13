# 计数器

## 需求

这次，我们需要设计一个计数器：用户有两个按钮，一个计数按钮，每按一次计数加一；一个复位按钮，按下时计数恢复到零；同时，输出两位十进制的数，显示目前用户按了多少次计数按钮。

根据上面的需求，可以设计如下的输入输出信号：

输入信号：

1. `clock`: 频率为 1MHz 的时钟
2. `reset`: 1 表示复位按钮被按下，0 表示没有按下
3. `button`: 1 表示计数按钮被按下，0 表示没有按下

输出信号：

1. `ones`: 输出次数的个位数，4 位
2. `tens`: 输出次数的十位数，4 位

## 波形

我们来分析一下上面的需求。每按一次计数按钮，计数就加一，你可能会想，能否在 `button` 的时钟上升沿触发，让寄存器加一？理想很美好，现实很骨感，由于按钮的本身特性，按下按钮的几个 ms 内，它实际上是不稳定的，在 FPGA 看来就是不断在 `0` 和 `1` 之间抖动，最后才趋向稳定。所以直接用 `button` 的上升沿作为触发条件，很可能按一下按钮，计数器就增加了很多次。

感兴趣的话，可以看 [按键为什么要进行消抖](https://b23.tv/GTXHPNR) 视频，视频中给出了按键按下和松开时的波形，波形中出现了很多抖动。视频中用电容解决了抖动的问题，在这里，我们在 FPGA 内用数字逻辑来实现。

为了解决这个问题，也就是消除这个抖动的影响（简称消抖，Debounce），我们可以记录最近若干次 `button` 的历史值，如果连续一段时间（比如大于上面的几个 ms），都处于一个固定的值，那就可以认为目前按钮处于这个状态。实现了消抖后，得到的波形就是干净的，按钮按下一次，对应一次从 `0` 到 `1` 的变化。

接下来我们来绘制一下消抖的波形，为了简化，绘制的波形里只需要连续 4 个周期保持相同的值就可以认为是稳定的：


<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p.........."},
      { name: "button", wave: "0.1..01....", node: "..a...b"},
      { name: "button_debounced", wave: "0.........1", node: "..........c"}
    ]
}
</script>

从波形中可以看到，图中的 `a->b` 时间出现了抖动，此时输出的消抖结果 `button_debounced` 不变；直到图中 `b->c` 时间里 `button` 已经连续四个周期为 `1`，此时输出的消抖结果 `button_debounced` 才变为 `1`。实际应用的时候，如果按照 10ms 的消抖时间，时钟是 1MHz 来算，一共需要 `1,000,000 / (1000 / 10) = 10,000` 个周期保持相同的值，才被认为是稳定的。看起来周期数很多，可是对于人按下按钮的时间是可以忽略的。

解决了抖动的问题以后，再来考虑一下计数器。这是一个内部状态，所以还是需要用寄存器来实现。你可能会想，既然已经把抖动去掉了，那能否把去抖以后的信号作为时钟信号来驱动保存计数器的寄存器？答案是不建议，如果可能的话，尽量减少用非时钟信号作为上边沿触发，因为这在数字电路里面会使得时序分析变得困难。这里请记住一个原则，就是 **尽量把相关的时序逻辑都放在同一个时钟域中** ，这些时序逻辑的寄存器都使用了同样的时钟，并且都在同一个上升沿上触发更新。如果涉及到不同时钟域之间的信号处理，之后我们会介绍一些用于实现跨时钟域（CDC，Cross Domain Clocking）的正确电路实现方法。在此之前， **建议只用一个时钟，让这个时钟驱动所有的寄存器** 。

根据上面的一个时钟原则，我们可以在时钟的上升沿来检测 `button_debounced` 从 `0` 变成了 `1`，具体思路是：

1. 额外设置一个寄存器 `button_debounced_delay`，相对于 `button_debounced_delay` 有一个周期的延迟；
2. 当 `button_debounced == 1` 并且 `button_debounced_delay == 0` 的时候（也就是下图的 `a` 和 `b` 时刻），这时候我们就检测到了一个从 `0` 变成 `1` 的过程，对计数器加一。

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p...........", node: "...a.......b"},
      { name: "button_debounced", wave: "0.1...0...1."},
      { name: "button_debounced_delay", wave: "0..1...0...1"},
      { name: "counter_reg", wave: "=..=.......=", data: ["0", "1", "2"]}
    ]
}
</script>

最后再来思考一下输出的要求：题目中要求分别输出个位数和十位数，所以我们还需要通过某种方式把输出拆成个位数和十位数分别输出：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p..........."},
      { name: "counter_reg", wave: "=..=.......=", data: ["9", "10", "11"]},
      { name: "ones", wave: "=..=.......=", data: ["9", "0", "1"]},
      { name: "tens", wave: "=..=.......=", data: ["0", "1", "1"]}
    ]
}
</script>

具体如何实现个位数和十位数分别输出，在下面会细致地进行讨论。

## 电路

### 模块化设计

上面已经把电路的功能和波形图设计地差不多了，接下来来思考一下电路的设计。首先可以看到，代码中主要有两部分，一部分是消抖，一部分是计数和输出的逻辑，而消抖的逻辑是比较独立的，以后可能还会用到，所以我们可以把它拆出来做成一部分电路，然后把消抖后的信号连接到计数和输出逻辑部分即可。

因此，我们进一步细化，把电路拆成两部分：

消抖模块（Debouncer）：

输入：

1. `clock`: 频率为 1MHz 的时钟
2. `reset`: 1 表示复位按钮被按下，0 表示没有按下
3. `button`: 1 表示计数按钮被按下，0 表示没有按下

输出：

1. `button_debounced`: 消抖后的计数按钮信号，高有效

计数模块（Counter）：

输入：

1. `clock`: 频率为 1MHz 的时钟
2. `reset`: 1 表示复位按钮被按下，0 表示没有按下
3. `button_debounced`: 消抖后的计数按钮信号，高有效

输出：

1. `ones`: 输出次数的个位数，4 位
2. `tens`: 输出次数的十位数，4 位

可以用如下的框图来表示它们的关系：

![](imgs/counter.svg)

这种模块化的思考方式是很有用的，你首先需要功能对整个电路进行划分，然后对划分出来的各个模块定义它的功能、输入输出的定义。这样你在实现单个模块的时候，它的复杂度已经很小了，并且比较容易测试和验证它的正确性。实现完各个模块后，最后再进行连接，就可以实现一个比较复杂的设计。

### 消抖模块

接下来思考一下消抖模块电路如何设计。首先，我们需要记录下历史的输入，这样才可以判断是否 10,000 个周期都保持稳定。但实际上，用 10,000 个 1 位的寄存器来保存有些浪费，可以换个思路，用一个寄存器来记录目前稳定了多少个周期，如果输入出现了变化，就重新计数；当计数达到阈值的时候，就更新状态并输出结果。

于是，可以设计如下的电路：

1. 寄存器 `last_button_reg` 记录上一个周期 `button` 是多少
2. 寄存器 `counter_reg` 用来保存一个计数，当 `button == last_button_reg` 的时候，说明 `button` 继续保持稳定，那么 `counter_reg = counter_reg + 1`；否则 `button` 出现了变化，则清零重新计数
3. 寄存器 `button_debounced_reg` 用来保存当前输出的消抖结果，当 `counter_reg = 10000` 的时候，更新 `button_debounced_reg = last_button_reg`。

最后，把 `button_debounced_reg` 连接到 `button_debounced` 输出即可。

### 计数模块

实现了消抖模块以后，接下来实现计数模块。回顾一下，它接收来自消抖模块的输出 `button_debounced`，在检测到它从 `0` 变成 `1` 的时候计数器加一；输出的时候，要把个位数和十位数拆开分别输出。

这时候你可能会想，我能不能用一个完整的寄存器来保存整个计数，然后输出的时候，设置 `ones = counter_reg % 10` 和 `tens = counter_reg / 10`？这样做是不建议的，因为这样的除法和取模运算会耗费大量的逻辑门来实现，并且延迟比较大。一个简单的测试表明，对于一个 7 位的输入，输出十位数和个位数需要 46 个逻辑门，并且有长度为 11 的路径。在这个简单的例子里面可能问题不大，但是如果位数更多，它产生的电路复杂度和延迟可能是不可接受的。考虑到这里每次对 `counter_reg` 的操作只有加一和清零，我们可以添加 `ones_reg` 和 `tens_reg` 寄存器，来实现加一和清零的操作，并且手动处理进位的问题。这样一个复杂的除法和取模的电路就被简化了很多。

接下来用一个寄存器来检测按下的计数按钮，即 `button_debounced` 从 `0` 变成 `1`：

1. 用寄存器 `button_debounced_reg` 来保存上一个周期的 `button_debounced` 值
2. 如果 `button_debounced == 1 && button_debounced_reg == 0`，说明检测到了从 `0` 变成了 `1`

最后是 `ones_reg`，考虑进位逻辑：

1. 如果 `reset == 1`，则清零
2. 如果检测到计数操作，则 `ones_reg = ones_reg == 9 ? 0 : (ones_reg + 1)`

和 `tens_reg`，当 `ones_reg` 要进位时加一：

1. 如果 `reset == 1`，则清零
2. 如果检测到计数操作，则 `tens_reg = ones_reg == 9 ? (tens_reg + 1) : tens_reg`

最后把 `ones_reg` 和 `tens_reg` 连接到输出的 `ones` 和 `tens` 信号即可。

## 代码

最后我们用 HDL 来实现上面的电路。相信读到这里的你，已经能够根据上面的分析，自己写出来下面的代码。

=== "VHDL"
    
    鉴于同学已经比较熟悉 VHDL 代码了，这里直接给出最终代码：
    
    首先是消抖电路：
    
    ```vhdl
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    
    entity debouncer is
        Port ( clock            : in  STD_LOGIC;
               reset            : in  STD_LOGIC;
               button           : in  STD_LOGIC;
               button_debounced : out STD_LOGIC);
    end debouncer;
    
    architecture behavior of debouncer is
    signal last_button_reg : STD_LOGIC;
    signal counter_reg : STD_LOGIC_VECTOR (15 downto 0);
    signal button_debounced_reg : STD_LOGIC;
    begin
      -- sequential
      process(clock, reset, button) begin
        if rising_edge(clock) then
          if reset='1' then
            last_button_reg <= '0';
            counter_reg <= X"0000";
            button_debounced_reg <= '0';
          else
            last_button_reg <= button;
    
            if button=last_button_reg then
              if counter_reg=10000 then
                button_debounced_reg <= last_button_reg;
              else
                counter_reg <= counter_reg + 1;
              end if;
            else
              counter_reg <= X"0000";
            end if;
          end if;
        end if;
      end process;
    
      -- combinatorial
      button_debounced <= button_debounced_reg;
    end behavior;
    ```
    
    接着是计数器部分：
    
    ```vhdl
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    
    entity counter is
        Port ( clock            : in  STD_LOGIC;
               reset            : in  STD_LOGIC;
               button_debounced : in  STD_LOGIC;
               ones             : out STD_LOGIC_VECTOR (3 downto 0);
               tens             : out STD_LOGIC_VECTOR (3 downto 0));
    end counter;
    
    architecture behavior of counter is
    signal ones_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal tens_reg : STD_LOGIC_VECTOR (3 downto 0);
    signal button_debounced_reg : STD_LOGIC;
    begin
      -- sequential
      process(clock, reset, button_debounced) begin
        if rising_edge(clock) then
          if reset='1' then
            ones_reg <= X"0";
            tens_reg <= X"0";
            button_debounced_reg <= '0';
          else
            button_debounced_reg <= button_debounced;
    
            if button_debounced='1' and button_debounced_reg='0' then
              if ones_reg=X"9" then
                ones_reg <= X"0";
                tens_reg <= tens_reg + 1;
              else
                ones_reg <= ones_reg + 1;
              end if;
            end if;
          end if;
        end if;
      end process;
    
      -- combinatorial
      ones <= ones_reg;
      tens <= tens_reg;
    end behavior;
    ```
    
    最后再用一个顶层 `entity` 把两个模块合起来：
    
    ```vhdl
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    
    entity counter_top is
        Port ( clock            : in  STD_LOGIC;
               reset            : in  STD_LOGIC;
               button           : in  STD_LOGIC;
               ones             : out STD_LOGIC_VECTOR (3 downto 0);
               tens             : out STD_LOGIC_VECTOR (3 downto 0));
    end counter_top;
    
    architecture behavior of counter_top is
    signal button_debounced : STD_LOGIC;
    begin
      -- debouncer
      debouncer_component : entity work.debouncer
        port map(
          clock => clock,
          reset => reset,
          button => button,
          button_debounced => button_debounced
        );
    
      -- counter
      counter_component : entity work.counter
        port map(
          clock => clock,
          reset => reset,
          button_debounced => button_debounced,
          ones => ones,
          tens => tens
        );
    end behavior;
    ```
    
    这里新出现的语法是在一个模块中去例化另一个模块，需要提供一个输入输出端口的映射。在这里，`button_debounced` 是两个内部模块之间的，所以声明了一个 `signal`，这个实际上只是连线，并不是寄存器，因为综合器会发现它没有设计时钟的上升沿触发逻辑。其他信号则是直接连接到顶层模块的输入输出信号。
    
    这样就实现了整个计数器的功能。如果看代码的时候感觉有一些困惑，可以开两个网页，把代码和前面的分析内容对照着看。
    
=== "Verilog"
    
    鉴于同学已经比较熟悉 Verilog 代码了，这里直接给出最终代码：
    
    首先是消抖电路：
    
    ```verilog
    module debouncer (
      input wire clock,
      input wire reset,
      input wire button,
      output wire button_debounced
    );
      reg last_button_reg;
      reg [15:0] counter_reg;
      reg button_debounced_reg;
    
      always @ (posedge clock) begin
        if (reset) begin
          last_button_reg <= 1'b0;
          counter_reg <= 16'b0;
          button_debounced_reg <= 1'b0;
        end else begin
          last_button_reg <= button;
    
          if (button == last_button_reg) begin
            if (counter_reg == 16'd10000) begin
              button_debounced_reg <= last_button_reg;
            end else begin
              counter_reg <= counter_reg + 16'b1;
            end
          end else begin
            counter_reg <= 16'b0;
          end
        end
      end
    
      assign button_debounced = button_debounced_reg;
    endmodule
    ```
    
    接着是计数器部分：
    
    ```verilog
    module counter (
      input wire clock,
      input wire reset,
      input wire button_debounced,
      output wire [3:0] ones,
      output wire [3:0] tens
    );
    
      reg [3:0] ones_reg;
      reg [3:0] tens_reg;
      reg button_debounced_reg;
    
      always @ (posedge clock) begin
        if (reset) begin
          ones_reg <= 4'b0;
          tens_reg <= 4'b0;
          button_debounced_reg <= 1'b0;
        end else begin
          button_debounced_reg <= button_debounced;
    
          if (button_debounced && !button_debounced_reg) begin
            if (ones_reg == 4'd9) begin
              ones_reg <= 4'b0;
              tens_reg <= tens_reg + 4'b1;
            end else begin
              ones_reg <= ones_reg + 4'b1;
            end
          end
        end
      end
    
      assign ones = ones_reg;
      assign tens = tens_reg;
    
    endmodule
    ```
    
    最后再用一个顶层 `module` 把两个模块合起来：
    
    ```verilog
    module counter_top (
      input wire clock,
      input wire reset,
      input wire button,
      output wire [3:0] ones,
      output wire [3:0] tens
    );
    
      wire button_debounced;
    
      debouncer debouncer_component (
        .clock(clock),
        .reset(reset),
        .button(button),
        .button_debounced(button_debounced)
      );
    
      counter counter_component (
        .clock(clock),
        .reset(reset),
        .button_debounced(button_debounced),
        .ones(ones),
        .tens(tens)
      );
    
    endmodule
    ```
    
    这里新出现的语法是在一个模块中去例化另一个模块，需要提供一个输入输出端口的映射。在这里，`button_debounced` 是两个内部模块之间的，所以声明了一个 `wire`，这个只是把两个模块的输入输出连起来，并不是寄存器。其他信号则是直接连接到顶层模块的输入输出信号。
    
    这样就实现了整个计数器的功能。如果看代码的时候感觉有一些困惑，可以开两个网页，把代码和前面的分析内容对照着看。
    
=== "System Verilog"
    
    鉴于同学已经比较熟悉 System Verilog 代码了，这里直接给出最终代码：
    
    首先是消抖电路：
    
    ```sv
    module debouncer (
      input wire clock,
      input wire reset,
      input wire button,
      output wire button_debounced
    );
      logic last_button_reg;
      logic [15:0] counter_reg;
      logic button_debounced_reg;

      always_ff @ (posedge clock) begin
        if (reset) begin
          last_button_reg <= 1'b0;
          counter_reg <= 16'b0;
          button_debounced_reg <= 1'b0;
        end else begin
          last_button_reg <= button;
    
          if (button == last_button_reg) begin
            if (counter_reg == 16'd10000) begin
              button_debounced_reg <= last_button_reg;
            end else begin
              counter_reg <= counter_reg + 16'b1;
            end
          end else begin
            counter_reg <= 16'b0;
          end
        end
      end

      assign button_debounced = button_debounced_reg;
    endmodule
    ```

    接着是计数器部分：

    ```sv
    module counter (
      input wire clock,
      input wire reset,
      input wire button_debounced,
      output wire [3:0] ones,
      output wire [3:0] tens
    );

      logic [3:0] ones_reg;
      logic [3:0] tens_reg;
      logic button_debounced_reg;

      always_ff @ (posedge clock) begin
        if (reset) begin
          ones_reg <= 4'b0;
          tens_reg <= 4'b0;
          button_debounced_reg <= 1'b0;
        end else begin
          button_debounced_reg <= button_debounced;
    
          if (button_debounced && !button_debounced_reg) begin
            if (ones_reg == 4'd9) begin
              ones_reg <= 4'b0;
              tens_reg <= tens_reg + 4'b1;
            end else begin
              ones_reg <= ones_reg + 4'b1;
            end
          end
        end
      end
    
      assign ones = ones_reg;
      assign tens = tens_reg;
    
    endmodule
    ```
    
    最后再用一个顶层 `module` 把两个模块合起来：
    
    ```sv
    module counter_top (
      input wire clock,
      input wire reset,
      input wire button,
      output wire [3:0] ones,
      output wire [3:0] tens
    );

      wire button_debounced;

      debouncer debouncer_component (
        .clock(clock),
        .reset(reset),
        .button(button),
        .button_debounced(button_debounced)
      );
    
      counter counter_component (
        .clock(clock),
        .reset(reset),
        .button_debounced(button_debounced),
        .ones(ones),
        .tens(tens)
      );
    
    endmodule
    ```
    
    这里新出现的语法是在一个模块中去例化另一个模块，需要提供一个输入输出端口的映射。在这里，`button_debounced` 是两个内部模块之间的，所以声明了一个 `wire`，这个只是把两个模块的输入输出连起来，并不是寄存器。其他信号则是直接连接到顶层模块的输入输出信号。
    
    这样就实现了整个计数器的功能。如果看代码的时候感觉有一些困惑，可以开两个网页，把代码和前面的分析内容对照着看。

## 扩展

上面介绍了消抖电路，它主要的目的是消除 **物理按键** 在按下和松开时产生的抖动，其检测的事件是，输入信号持续一段时间（ms 量级）不变。

此外，还有一类在输入异步信号的处理上很常用的电路，它针对的问题是，如果我用一个时钟驱动的触发器对异步的输入信号进行采样，如果输入信号变化的时刻 **不满足 setup/hold 约束**，即它变化的时刻与时钟上升沿十分接近，此时触发器的输出是不稳定的，可能会出现错误。对于这个问题，通常的解决方法是，用两个触发器进行采样：

=== "VHDL"

    ```vhdl
    process(clock) begin
      if rising_edge(clk) begin
        in_reg1 <= in;
        in_reg2 <= in_reg1;

        -- use in_reg2 instead of in
      end if;
    end process;
    ```

=== "Verilog"

    ```verilog
    always @ (posedge clock) begin
      in_reg1 <= in;
      in_reg2 <= in_reg1;

      // use in_reg2 instead of in
    end
    ```

=== "System Verilog"

    ```sv
    always_ff @ (posedge clock) begin
      in_reg1 <= in;
      in_reg2 <= in_reg1;

      // use in_reg2 instead of in
    end
    ```

这种方法在异步复位转同步、跨时钟域的场景中都会看到。