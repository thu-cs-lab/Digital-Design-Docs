# 代码规范

经过前面一些例子的学习，你应该已经学会了，如何从一个需求中，分析出所需要的波形，从而得到电路的实现，最后用 VHDL/Verilog 来实现。那么在阅读本文中的代码的时候，你会发现所有的代码都是用比较类似的方式来编写的。因此在这里，我们总结了编写 VHDL/Verilog 的代码规范，在目前的学习阶段中，按照下面的代码规范进行代码编写，就可以规避大部分的错误。

## 001 通过命名来区分寄存器和信号

在实现的过程中，模块内部经常需要声明一些变量，但是这些变量在硬件中，可能对应了时序逻辑（寄存器），也可能对应了组合逻辑（信号），为了区分二者，我们推荐：

1. 所有的寄存器命名添加 `_reg` 后缀
2. 所有的组合逻辑信号命名添加 `_comb` 后缀
3. 模块的输入输出信号不添加后缀

VHDL

```vhdl
-- GOOD
signal light_reg : STD_LOGIC;
signal user_reg : STD_LOGIC_VECTOR (1 downto 0);
signal priority_encoder_valid_comb : STD_LOGIC;
```

Verilog:

```verilog
reg light_reg;
reg [1:0] user_reg;
reg priority_encoder_valid_comb;
```

## 002 信号或寄存器应当仅在一个块中赋值

对于目前学到的数字逻辑中，所有的信号或寄存器都应当在一个块（VHDL 是 `process`，Verilog 是 `always`）中赋值。

VHDL:

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

Verilog:

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
```

## 003 将时序逻辑和组合逻辑写在不同的块中

通常，我们会将代码组织为时序逻辑和组合逻辑两部分，比如先写时序逻辑，再写组合逻辑，而不会混在一起编写。

VHDL:

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

Verilog:

```verilog
// GOOD
always @ (posedge clock) begin
  c_reg <= a + b;
end

always @ (*) begin
  d_comb = a - b;
end
```

## 004 每个寄存器应当只在一个时钟上升沿触发

由于 D 触发器只有一个时钟输入，并在时钟的上升沿触发更新，因此不能有超过一个输入；此外，在目前学习的数字电路中，推荐统一使用上升沿，不使用下降沿。

VHDL：

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

Verilog:

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

## 005 寄存器应该实现复位逻辑，并且复位到常量

对于使用到的寄存器，都应当实现相应的复位逻辑，并且应当复位到常量。实现时，可以采用同步复位或者异步复位的方式。

VHDL：

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

Verilog:

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
```

## 006 组合逻辑需要保证每个分支下每个信号都有赋值

在实现比较复杂的组合逻辑的时候，通常会用一些 `if-then-else` 的语句来实现，但此时很容易在一些分支下遗忘了对组合逻辑信号的赋值，此时就会产生锁存器（latch），可能会导致电路与预期效果不符。目前的数字电路学习中，不需要使用锁存器。

为了防止自己遗忘，可以在分支开头设置一个默认值。

VHDL:

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

Verilog:

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