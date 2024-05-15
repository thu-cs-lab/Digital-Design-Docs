# 代码规范

经过前面一些例子的学习，你应该已经学会了，如何从一个需求中，分析出所需要的波形，从而得到电路的实现，最后用 VHDL/Verilog/System Verilog 来实现。那么在阅读本文中的代码的时候，你会发现所有的代码都是用比较类似的方式来编写的。因此在这里，我们总结了编写 VHDL/Verilog/System Verilog 的代码规范，在目前的学习阶段中，按照下面的代码规范进行代码编写，就可以规避大部分的错误。

## 001 通过命名来区分寄存器和信号

在实现的过程中，模块内部经常需要声明一些变量，但是这些变量（例如 VHDL 的 `signal`，Verilog 的 `reg` 和 SystemVerilog 的 `logic/reg`）在硬件中，可能对应了时序逻辑（寄存器），也可能对应了组合逻辑（信号），为了区分二者，我们推荐：

1. 所有的寄存器命名添加 `_reg` 后缀
2. 所有的组合逻辑信号命名添加 `_comb` 后缀
3. 模块的输入输出信号不添加 `_reg` 或 `_comb` 后缀

=== "System Verilog"
    
    ```sv
    // GOOD
    logic light_reg;
    logic [1:0] user_reg;
    logic priority_encoder_valid_comb;

    // GOOD
    reg light_reg;
    reg [1:0] user_reg;
    reg priority_encoder_valid_comb;
    ```

=== "Verilog"
    
    ```verilog
    // GOOD
    reg light_reg;
    reg [1:0] user_reg;
    reg priority_encoder_valid_comb;
    ```


=== "VHDL"

    ```vhdl
    -- GOOD
    signal light_reg : STD_LOGIC;
    signal user_reg : STD_LOGIC_VECTOR (1 downto 0);
    signal priority_encoder_valid_comb : STD_LOGIC;
    ```
    

## 002 信号或寄存器应当仅在一个块中赋值

在常用的数字逻辑中，同一个信号或寄存器都应当仅在一个块（VHDL 是 `process`，Verilog 是 `always`）中赋值。

=== "System Verilog"
    
    ```sv
    // GOOD
    always_comb begin
      c_comb = a + b;
    end
    
    // BAD
    always_comb begin
      c_comb = a;
    end
    always_comb begin
      c_comb = b;
    end
    
    // GOOD
    always_ff @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    // BAD
    always_ff @ (posedge clock) begin
      c_reg <= a + b;
    end
    always_ff @ (posedge clock) begin
      c_reg <= a - b;
    end

    // GOOD
    always_comb begin
      c_comb = a + b;
    end
    always_ff @ (posedge clock) begin
      c_reg <= a + b;
    end
    ```


=== "Verilog"
    
    ```verilog
    // GOOD
    always @ (*) begin
      c_comb = a + b;
    end
    
    // BAD
    always @ (*) begin
      c_comb = a;
    end
    always @ (*) begin
      c_comb = b;
    end
    
    // GOOD
    always @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    // BAD
    always @ (posedge clock) begin
      c_reg <= a + b;
    end
    always @ (posedge clock) begin
      c_reg <= a - b;
    end

    // GOOD
    always @ (*) begin
      c_comb = a + b;
    end
    always @ (posedge clock) begin
      c_reg <= a + b;
    end
    ```

=== "VHDL"
    
    ```vhdl
    -- GOOD
    process (a, b) begin
      c_comb <= a + b;
    end process;
    
    -- BAD
    process (a) begin
      c_comb <= a;
    end process;
    
    process (b) begin
      c_comb <= b;
    end process;
    
    -- GOOD
    process (clock) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    -- BAD
    process (clock) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    process (clock) begin
      if rising_edge(clock) then
        c_reg <= a - b;
      end if;
    end process;
    ```
    
    
## 003 将时序逻辑和组合逻辑写在不同的块中

通常，我们会将代码组织为时序逻辑和组合逻辑两部分，比如先写时序逻辑，再写组合逻辑，而不会混在一起编写。

=== "System Verilog"

    ```sv
    // GOOD
    always_ff @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    always_comb begin
      d_comb = a - b;
    end
    ```


=== "Verilog"

    ```verilog
    // GOOD
    always @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    always @ (*) begin
      d_comb = a - b;
    end
    ```

=== "VHDL"
    
    ```vhdl
    -- GOOD
    process (clock) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    process (a, b) begin
      d_comb <= a - b;
    end process;
    
    -- BAD
    process (clock, a, b) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      end if;

      d_comb <= a - b;
    end process;
    ```

## 004 每个寄存器应当只在一个时钟上升沿触发

由于 D 触发器只有一个时钟输入，并在时钟的上升沿触发更新，因此不能有超过一个时钟输入；此外，在目前学习的数字电路中，推荐统一使用上升沿触发，不使用下降沿触发。

=== "System Verilog"
 
    ```sv
    // GOOD
    always_ff @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    // BAD
    always_ff @ (posedge clock1) begin
      c_reg <= a + b;
    end
    always_ff @ (posedge clock2) begin
      c_reg <= a - b;
    end
    
    // BAD
    always_ff @ (posedge clock1, posedge clock2) begin
      c_reg <= a + b;
    end
    ```


=== "Verilog"

    ```verilog
    // GOOD
    always @ (posedge clock) begin
      c_reg <= a + b;
    end
    
    // BAD
    always @ (posedge clock1) begin
      c_reg <= a + b;
    end
    always @ (posedge clock2) begin
      c_reg <= a - b;
    end
    
    // BAD
    always @ (posedge clock1, posedge clock2) begin
      c_reg <= a + b;
    end
    ```

=== "VHDL"

    ```vhdl
    -- GOOD
    process (clock) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    -- BAD
    process (clock1, clock2) begin
      if rising_edge(clock1) then
        c_reg <= a + b;
      end if;
      if rising_edge(clock2) then
        c_reg <= a - b;
      end if;
    end
    ```

## 005 寄存器应该实现复位逻辑，并且复位到常量

对于使用到的寄存器，都应当实现相应的复位逻辑，并且应当复位到常量。实现时，可以采用同步复位或者异步复位的方式。

如果编写的硬件逻辑面向的是 Xilinx FPGA，建议采用同步复位的方法。

=== "System Verilog"

    需要注意的是，虽然编写的时候是 `posedge reset`，但实际上这里的 `reset` 是电平触发。
    
    ```sv
    // GOOD
    // sync reset
    always_ff @ (posedge clock) begin
      if (reset) begin
        c_reg <= 1'b0;
      end else begin
        c_reg <= a + b;
      end
    end
    
    // GOOD
    // async reset
    always_ff @ (posedge clock, posedge reset) begin
      if (reset) begin
        c_reg <= 1'b0;
      end else begin
        c_reg <= a + b;
      end
    end
    
    // BAD
    always_ff @ (posedge clock, posedge reset) begin
      if (reset) begin
        c_reg <= a - b;
      end else begin
        c_reg <= a + b;
      end
    end
    ```

=== "Verilog"

    需要注意的是，虽然编写的时候是 `posedge reset`，但实际上这里的 `reset` 是电平触发。

    ```verilog
    // GOOD
    // sync reset
    always @ (posedge clock) begin
      if (reset) begin
        c_reg <= 1'b0;
      end else begin
        c_reg <= a + b;
      end
    end
    
    // GOOD
    // async reset
    always @ (posedge clock, posedge reset) begin
      if (reset) begin
        c_reg <= 1'b0;
      end else begin
        c_reg <= a + b;
      end
    end
    
    // BAD
    always @ (posedge clock, posedge reset) begin
      if (reset) begin
        c_reg <= a - b;
      end else begin
        c_reg <= a + b;
      end
    end
    ```

=== "VHDL"

    ```vhdl
    -- GOOD
    -- async reset
    process (clock, reset) begin
      if reset='1' then
        c_reg <= '0';
      elsif rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    -- GOOD
    -- sync reset
    process (clock, reset) begin
      if rising_edge(clock) then
        if reset='1' then
          c_reg <= '0';
        else
          c_reg <= a + b;
        end if;
      end if;
    end process;
    
    -- BAD
    process (clock, reset) begin
      if reset='1' then
        c_reg <= a - b;
      elsif rising_edge(clock) then
        c_reg <= a + b;
      end if;
    end process;
    
    -- BAD
    process (clock, reset) begin
      if rising_edge(clock) then
        c_reg <= a + b;
      elsif reset='1' then
        c_reg <= '0';
      end if;
    end process;
    ```

## 006 组合逻辑需要保证每个分支下每个信号都有赋值

在实现比较复杂的组合逻辑的时候，通常会用一些 `if-then-else` 的语句来实现，但此时很容易在一些分支下遗忘了对组合逻辑信号的赋值，此时就会产生锁存器（latch），可能会导致电路与预期效果不符。目前的数字电路学习中，不需要使用锁存器。

为了防止自己遗忘，可以在分支开头设置一个默认值。

=== "System Verilog"
 
    ```sv
    // GOOD
    always_comb begin
      if (!a) begin
        d_comb = b + c;
      end else begin
        d_comb = b - c;
      end
    end
 
    // BAD
    always_comb begin
      if (!a) begin
        d_comb = b + c;
      end else if (!b) begin
        d_comb = b - c;
      end
    end
 
    // GOOD
    always_comb begin
      d_comb = c;
      if (!a) begin
        d_comb = b + c;
      end else if (!b) begin
        d_comb = b - c;
      end
    end
    ```


=== "Verilog"
 
    ```verilog
    // GOOD
    always @ (*) begin
      if (!a) begin
        d_comb = b + c;
      end else begin
        d_comb = b - c;
      end
    end
 
    // BAD
    always @ (*) begin
      if (!a) begin
        d_comb = b + c;
      end else if (!b) begin
        d_comb = b - c;
      end
    end
 
    // GOOD
    always @ (*) begin
      d_comb = c;
      if (!a) begin
        d_comb = b + c;
      end else if (!b) begin
        d_comb = b - c;
      end
    end
    ```


=== "VHDL"
 
    ```vhdl
    -- GOOD
    process (a,b,c) begin
      if a='0' then
        d_comb <= b + c;
      else
        d_comb <= b - c;
      end if;
    end process;
 
    -- BAD
    process (a,b,c) begin
      if a='0' then
        d_comb <= b + c;
      elsif b='0' then
        d_comb <= b - c;
      end if;
    end process;
 
    -- GOOD
    process (a,b,c) begin
      d_comb <= c;
      if a='0' then
        d_comb <= b + c;
      elsif b='0' then
        d_comb <= b - c;
      end if;
    end process;
    ```

## 007 如有必要可以对寄存器设置 FPGA 启动初始值

当 FPGA 初始化的时候，寄存器也有一个启动初始值，它与复位不同，FPGA 在加载 bitstream 的时候，会按照启动初始值来设置寄存器的取值。这个方法用的比较少，通常来说并不需要使用这个功能，但是在一些情况下，例如对于外设的访问，如果按照默认初始值，可能还没来得及复位，就对外设进行了非预期的操作，这时候就需要设置寄存器的 FPGA 启动初始值。但是这种方法只对 FPGA 和仿真环境有效，而 ASIC 无效。

设置启动初始值不能代替复位的功能，不能偷懒，必须都实现。不可以对组合逻辑使用。

=== "System Verilog"
 
    ```sv
    // GOOD, but do not use with always_ff
    logic some_reg;
    initial begin
      some_reg = 1'b0;
    end
 
    // GOOD
    logic some_reg;
    initial some_reg = 1'b0;

    // BAD
    wire some_comb = 1'b0;

    // BAD
    wire some_comb;
    initial some_comb = 1'b0;
    ```


=== "Verilog"
 
    ```verilog
    // GOOD
    reg some_reg;
    initial begin
      some_reg = 1'b0;
    end
 
    // GOOD
    reg some_reg;
    initial some_reg = 1'b0;

    // BAD
    wire some_comb = 1'b0;

    // BAD
    wire some_comb;
    initial some_comb = 1'b0;
    ```


=== "VHDL"
 
    ```vhdl
    -- GOOD
    architecture behavior of initial_reg is
    signal some_reg : STD_LOGIC := '0';
    begin
    end behavior;

    -- BAD
    architecture behavior of initial_reg is
    signal some_comb : STD_LOGIC := '0';
    begin
    end behavior;
    ```

## 008 组合逻辑块中的赋值语句之间若有依赖则需要保证赋值顺序

如果在一个组合逻辑块中，赋值的变量又会参与到同一个组合逻辑块的其他变量的赋值当中，那么需要保证赋值的顺序，即被依赖的赋值要写在前面。

=== "System Verilog"
    
    ```sv
    // GOOD
    always_comb begin
      c_comb = a + b;
      d_comb = c_comb;
    end

    // BAD
    always_comb begin
      d_comb = c_comb;
      c_comb = a + b;
    end
    ```

=== "Verilog"
    
    ```verilog
    // GOOD
    always @(*) begin
      c_comb = a + b;
      d_comb = c_comb;
    end

    // BAD
    always @(*) begin
      d_comb = c_comb;
      c_comb = a + b;
    end
    ```

=== "VHDL"
    
    ```vhdl
    -- GOOD
    process (a, b) begin
      c_comb <= a + b;
      d_comb <= c_comb;
    end process;

    -- BAD
    process (a, b) begin
      d_comb <= c_comb;
      c_comb <= a + b;
    end process;
    ```



## V-001（仅 Verilog）组合逻辑的敏感信号应当用隐式列表（`@(*)`）

编写组合逻辑的时候，敏感信号列表应该用隐式列表（`@(*)`），而不列出每个敏感信号。

如果在代码中列出敏感信号，很容易出现遗漏，导致行为不符合预期。

```verilog
// GOOD
always @(*) begin
  c_comb = a + b;
end

// BAD
always @(a, b) begin
  c_comb = a + b;
end

// VERY BAD
always @(a) begin
  c_comb = a + b;
end
```

## V-002（仅 Verilog/System Verilog）组合逻辑块中使用阻塞赋值，时序逻辑块中使用非阻塞赋值

在组合逻辑块中，应当使用阻塞赋值（`=`），而时序逻辑块中，应当使用非阻塞赋值（`<=`）。不能混用，也不能两种赋值同时出现在同一个 `always` 块中。

=== "Verilog"
 
    ```verilog
    // GOOD
    reg some_reg;
    always @ (posedge clock) begin
      some_reg <= 1'b0;
    end
 
    // GOOD
    always @ (*) begin
      some_comb = 1'b0;
    end

    // BAD
    reg some_reg;
    always @ (posedge clock) begin
      some_reg = 1'b0;
    end

    // BAD
    always @ (*) begin
      some_comb <= 1'b0;
    end

    // BAD
    always @ (*) begin
      some_comb = 1'b0;
      if (a) begin
        some_comb <= 1'b1;
      end
    end
    ```

=== "System Verilog"
 
    ```sv
    // GOOD
    reg some_reg;
    always_ff @ (posedge clock) begin
      some_reg <= 1'b0;
    end
 
    // GOOD
    always_comb begin
      some_comb = 1'b0;
    end

    // BAD
    reg some_reg;
    always_ff @ (posedge clock) begin
      some_reg = 1'b0;
    end

    // BAD
    always_comb begin
      some_comb <= 1'b0;
    end

    // BAD
    always_comb begin
      some_comb = 1'b0;
      if (a) begin
        some_comb <= 1'b1;
      end
    end
    ```

## V-003（仅 Verilog/System Verilog）异步复位中边沿触发要与 `if` 判断语句极性一致

异步复位时，如果复位信号是高有效，那么敏感信号应该写 `posedge reset`，`if` 判断语句应该写 `if (reset)`；如果复位信号是低有效，那么敏感信号应该写 `negedge reset_n`，`if` 判断语句应该写 `if (~reset_n)`。

判断是否复位的 `if` 语句应该是 `always` 块中的最顶层的第一个语句，并且其余的逻辑放在 `else` 中。

如果没有判断复位的 `if` 语句，那么敏感信号中不应该出现复位信号。

=== "Verilog"
 
    ```verilog
    // GOOD
    reg some_reg;
    always @ (posedge clock, posedge reset) begin
      if (reset) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end
 
    // GOOD
    reg some_reg;
    always @ (posedge clock, negedge reset_n) begin
      if (~reset_n) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end

    // BAD
    reg some_reg;
    always @ (posedge clock, posedge reset) begin
      some_reg <= 1'b0;
    end

    // BAD
    reg some_reg;
    always @ (posedge clock, posedge reset) begin
      if (~reset) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end

    // BAD
    reg some_reg;
    always @ (posedge clock, posedge reset) begin
      if (a) begin
        some_reg <= a + b;
      end else if (reset) begin
        some_reg <= 1'b0;
      end
    end

    // BAD
    reg some_reg;
    always @ (posedge clock, posedge reset) begin
      if (reset) begin
        some_reg <= 1'b0;
      end
      if (c) begin
        some_reg <= a + b;
      end
    end
    ```

=== "System Verilog"
 
    ```sv
    // GOOD
    reg some_reg;
    always_ff @ (posedge clock, posedge reset) begin
      if (reset) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end
 
    // GOOD
    reg some_reg;
    always_ff @ (posedge clock, negedge reset_n) begin
      if (~reset_n) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end

    // BAD
    reg some_reg;
    always_ff @ (posedge clock, posedge reset) begin
      some_reg <= 1'b0;
    end

    // BAD
    reg some_reg;
    always_ff @ (posedge clock, posedge reset) begin
      if (~reset) begin
        some_reg <= 1'b0;
      end else begin
        some_reg <= a + b;
      end
    end

    // BAD
    reg some_reg;
    always_ff @ (posedge clock, posedge reset) begin
      if (a) begin
        some_reg <= a + b;
      end else if (reset) begin
        some_reg <= 1'b0;
      end
    end

    // BAD
    reg some_reg;
    always_ff @ (posedge clock, posedge reset) begin
      if (reset) begin
        some_reg <= 1'b0;
      end
      if (c) begin
        some_reg <= a + b;
      end
    end
    ```

## V-004（仅 Verilog/System Verilog）使用 `casez` 替代 `casex`

在编写需要通配符的 `case` 语句的时候，使用 `casez`，而不是 `casex`。它们的区别是在遇到输入数据是 `x` 的时候，匹配的行为不一样。