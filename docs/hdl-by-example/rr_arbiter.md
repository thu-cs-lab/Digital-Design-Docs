# 循环优先级仲裁器

## 需求

在上一个例子中，我们设计了无状态的仲裁器，其实际上就是一个优先级编码器（priority encoder）：给定输入的 `request` 信号，直接得出哪一个用户得到了资源的访问权。但是这种设计，如果高优先级的用户一直在访问，就会导致低优先级的用户一直没有机会访问资源。

因此，接下来我们要实现一个循环优先级仲裁器（round robin arbiter），即根据最后一次获取资源的用户，来决定下一次获取资源的优先级。我们规定：当一个用户 `A` 不再获取资源（即对应位的 `request` 从 `1` 变成 `0`）的时候，重新选择一个可以获取资源的用户，此时优先级是从 `A` 的下一个用户开始为最高优先级，按照编号从小到大（如果溢出了就绕回），最后 `A` 的优先级最低。这样，如果所有用户都要请求同一个资源，那么多次平均下来，所有用户的资源访问次数应该是差不多的。

根据上面的需求，假设有四个用户（编号 `0` 到 `3`），可以设计如下的输入输出信号：

输入：

1. `request`: 宽度为 4，每一位 1 表示对应的用户请求访问资源，0 表示不请求
2. `clock`: 1MHz 的时钟
3. `reset`: 复位信号

输出：

1. `valid`: 1 表示有用户请求访问资源，0 表示无用户请求访问资源
2. `user`: 宽度为 2，如果有用户请求访问资源时，输出获得资源的用户的编号

## 波形

根据上面的需求，可以得到如下的波形：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p.....", period: 2},
      { name: "reset", wave: "0..........."},
      { name: "request", wave: "=.=.=.=.=.=.", data: ["0b0000", "0b0001", "0b0100", "0b0000", "0b1111", "0b1110"], node: "..a.b.c.d.e"},
      { name: "valid", wave: "0.1...0.1..."},
      { name: "user", wave: "x.=.=.x.=...", data: ["0","2","3"]}
    ]
}
</script>

相比上一个例子，这里有两个比较大的区别：

1. 在无状态仲裁器中，如果出现了优先级更高的用户，那么会把资源的访问权立即切换到高优先级的用户；而在循环优先级仲裁器中，只有当用户放弃了请求，才会切换，例如在 `e` 时刻，获得访问权的依然是 `3` 号
2. 仲裁时，优先级会根据最后一次获得访问权的用户来决定，例如在 `d` 时刻，由于最后一次获得访问权的是 `2` 号用户，因此此时优先级最高的是 `3` 号用户

## 电路

接着来分析一下电路。由于此时优先级和最后一次获得访问权的用户有关，那么肯定需要把最后一次访问权的用户记录下来，因此这里肯定需要用 **时序逻辑** 来实现。

不妨用 `user_reg` 来记录最后一次获得访问权的用户编号，我们来考虑一下和它相关的逻辑：

1. 什么时候更新：上一个周期没有用户获得访问权，但是这个周期 `request` 不等于零；或者当前周期获得访问权的用户对应的 `request` 位由 `1` 变成了 `0`
2. 更新成什么：如果更新了，就要按照优先级顺序在 `request` 里面选出一个目前优先级最高的用户

让我们把 `user_reg` 添加到波形中：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clock", wave: "p.....", period: 2},
      { name: "reset", wave: "0..........."},
      { name: "request", wave: "=.=.=.=.=.=.", data: ["0b0000", "0b0001", "0b0100", "0b0000", "0b1111", "0b1110"], node: "..a.b.c.d.e"},
      { name: "valid", wave: "0.1...0.1..."},
      { name: "user_reg", wave: "x...=.=...=.", data: ["0","2","3"]},
      { name: "user", wave: "x.=.=.x.=...", data: ["0","2","3"]}
    ]
}
</script>

观察波形，我们发现，在上图的 `a` 时刻， `request` 由 `0000` 变成 `0001` 的时候，此时就要输出 `user` 为目前获得访问权的用户编号，但 `user_reg` 保存的是之前的信息，它的更新需要等到 `b` 时刻，因此这里 `user` 还涉及到一些组合逻辑，不能直接 `user <= user_reg`。这里正好是反过来：用 `user_reg` 保存上一个周期的 `user`，即 `user_reg <= user`。

由此，我们会发现，在这一类内部具有状态，而又需要在输入变化的同一个周期输出的情况，需要用时序逻辑来保存状态，同时用组合逻辑来实现同周期的输出，把二者结合起来，实现一个比较复杂的功能。

考虑到这里也要用到类似优先级编码器的逻辑，我们可以复用一部分优先级编码器的代码，在它的基础上，即根据最后一次获得访问权的用户编号来确定优先级。因此，我们还是把代码分成两部分：

第一个部分是修改后的优先级编码器，额外添加了一个输入：`last_user` 表示最后一次获得访问权的用户编号。此时，优先级变成了编号为 `last_user+1` 的用户最高，编号为`last_user` 的用户最低。

第二个部分就是维护 `user_reg` 状态。这次，我们直接采用两个模块来实现：第一个模块就是上面提到的修改后的优先级编码器，第二个模块就是整体的循环优先级仲裁器，内部需要例化第一个模块。

## 代码

接下来，让我们用 HDL 语言来实现上面的逻辑。

=== "VHDL"
    
    首先，让我们实现第一部分逻辑，即根据最后一次获取资源的用户编号确定优先级的优先级编码器：
    
    ```vhdl
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    
    entity rr_priority_encoder is
        Port ( request   : in  STD_LOGIC_VECTOR (3 downto 0);
               last_user : in  STD_LOGIC_VECTOR (1 downto 0);
               valid     : out STD_LOGIC;
               user      : out STD_LOGIC_VECTOR (1 downto 0));
    end rr_priority_encoder;
    
    architecture behavior of rr_priority_encoder is
    begin
      process (request, last_user) begin
        -- default
        valid <= '0';
        user <= "00";
    
        -- naive way
        if last_user="11" then
          if request(0)='1' then
            valid <= '1';
            user <= "00";
          elsif request(1)='1' then
            valid <= '1';
            user <= "01";
          elsif request(2)='1' then
            valid <= '1';
            user <= "10";
          elsif request(3)='1' then
            valid <= '1';
            user <= "11";
          end if;
        elsif last_user="00" then
          if request(1)='1' then
            valid <= '1';
            user <= "01";
          elsif request(2)='1' then
            valid <= '1';
            user <= "10";
          elsif request(3)='1' then
            valid <= '1';
            user <= "11";
          elsif request(0)='1' then
            valid <= '1';
            user <= "00";
          end if;
        elsif last_user="01" then
          if request(2)='1' then
            valid <= '1';
            user <= "10";
          elsif request(3)='1' then
            valid <= '1';
            user <= "11";
          elsif request(0)='1' then
            valid <= '1';
            user <= "00";
          elsif request(1)='1' then
            valid <= '1';
            user <= "01";
          end if;
        elsif last_user="10" then
          if request(3)='1' then
            valid <= '1';
            user <= "11";
          elsif request(0)='1' then
            valid <= '1';
            user <= "00";
          elsif request(1)='1' then
            valid <= '1';
            user <= "01";
          elsif request(2)='1' then
            valid <= '1';
            user <= "10";
          end if;
        end if;
      end process;
    end behavior;
    ```
    
    这里直接暴力枚举了所有情况，你也可以尝试一下，能否从面积、延迟、可读性等方面来优化上面的代码。
    
    接着，第二部分就是我们要设计的循环优先级仲裁器：
    
    ```vhdl
    library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    
    entity rr_arbiter is
        Port ( clock   : in  STD_LOGIC;
               reset   : in  STD_LOGIC;
               request : in  STD_LOGIC_VECTOR (3 downto 0);
               valid   : out STD_LOGIC;
               user    : out STD_LOGIC_VECTOR (1 downto 0));
    end rr_arbiter;
    
    architecture behavior of rr_arbiter is
    signal user_reg : STD_LOGIC_VECTOR (1 downto 0);
    signal valid_reg : STD_LOGIC;
    signal priority_encoder_valid_comb : STD_LOGIC;
    signal priority_encoder_user_comb : STD_LOGIC_VECTOR (1 downto 0);
    begin
      -- rr_priority_encoder
      rr_priority_encoder_component : entity work.rr_priority_encoder
        port map(
          request => request,
          last_user => user_reg,
          valid => priority_encoder_valid_comb,
          user => priority_encoder_user_comb
        );
    
      -- sequential
      process (clock, reset) begin
        if clock='1' and clock'event then
          if reset='1' then
            user_reg <= "00";
            valid_reg <= '0';
          else
            valid_reg <= priority_encoder_valid_comb;
            if valid_reg='0' and priority_encoder_valid_comb='1' then
              -- case 1: non valid -> valid
              user_reg <= priority_encoder_user_comb;
            elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='1' then
              -- case 2: persist
            elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='0' then
              -- case 3: next user
              user_reg <= priority_encoder_user_comb;
            end if;
          end if;
        end if;
      end process;
    
      -- combinatorial
      process (valid_reg, priority_encoder_valid_comb, request, user_reg, priority_encoder_user_comb) begin
        -- default
        user <= "00";
    
        if valid_reg='0' and priority_encoder_valid_comb='1' then
          -- case 1: non valid -> valid
          user <= priority_encoder_user_comb;
        elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='1' then
          -- case 2: persist
        elsif valid_reg='1' and priority_encoder_valid_comb='1' and request(conv_integer(user_reg))='0' then
          -- case 3: next user
          user <= priority_encoder_user_comb;
        end if;
    
        valid <= priority_encoder_valid_comb;
      end process;
    end behavior;
    ```
    
    这里要比较注意写法上的一些规则：
    
    1. 声明 `signal` 的时候，按照它是寄存器还是连线，给予不同的名称后缀
    2. 把时序逻辑和组合逻辑写在不同的 `process` 块中
    3. 写组合逻辑的时候，需要保证每个分支下对组合逻辑信号赋值；可以预先写一个默认值防止出错
    4. 遇到复杂的逻辑的时候，一定要在代码中编写注释
    
    这样，就实现了一个循环优先级仲裁器。
    
=== "Verilog"
    
    首先，让我们实现第一部分逻辑，即根据最后一次获取资源的用户编号确定优先级的优先级编码器：
    
    ```verilog
    module rr_priority_encoder (
      input [3:0] request,
      input [1:0] last_user,
      output valid,
      output [1:0] user
    );
      reg valid_comb;
      reg [1:0] user_comb;
    
      always @ (*) begin
        // default
        valid_comb = 1'b0;
        user_comb = 2'd0;
    
        // naive way
        if (last_user == 2'd3) begin
          case (request)
            4'bxxx1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'bxx10: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'bx100: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b1000: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
          endcase
        end else if (last_user == 2'd0) begin
          case (request)
            4'bxx1x: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'bx10x: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b100x: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b0001: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
          endcase
        end else if (last_user == 2'd1) begin
          case (request)
            4'bx1xx: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b10xx: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b00x1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'b0010: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
          endcase
        end else if (last_user == 2'd2) begin
          case (request)
            4'b1xxx: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b0xx1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'b0x10: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'b0100: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
          endcase
        end
    
      end
    
      assign valid = valid_comb;
      assign user = user_comb;
    
    endmodule
    ```
    
    这里直接暴力枚举了所有情况，你也可以尝试一下，能否从面积、延迟、可读性等方面来优化上面的代码。
    
    接着，第二部分就是我们要设计的循环优先级仲裁器：
    
    ```verilog
    module rr_arbiter (
      input clock,
      input reset,
    
      input [3:0] request,
      output valid,
      output [1:0] user
    );
      reg [1:0] user_reg;
      reg valid_reg;
    
      reg [1:0] user_comb;
      reg [1:0] priority_encoder_user_comb;
      
      rr_priority_encoder rr_priority_encoder_inst (
        .request(request),
        .last_user(user_reg),
        .valid(valid),
        .user(priority_encoder_user_comb)
      );
    
      // sequential
      always @ (posedge clock) begin
        if (reset) begin
          user_reg <= 2'd0;
          valid_reg <= 1'b0;
        end else begin
          valid_reg <= valid;
          if (!valid_reg && valid) begin
            // case 1: non valid -> valid
            user_reg <= priority_encoder_user_comb;
          end else if (valid_reg && valid && request[user_reg]) begin
            // case 2: persist
          end else if (valid_reg && valid && !request[user_reg]) begin
            // case 3: next user
            user_reg <= priority_encoder_user_comb;
          end
        end
      end
    
      // combinatorial
      always @ (*) begin
        // default
        user_comb = 2'b0;
        if (!valid_reg && valid) begin
          // case 1: non valid -> valid
          user_comb = priority_encoder_user_comb;
        end else if (valid_reg && valid && request[user_reg]) begin
          // case 2: persist
          user_comb = user_reg;
        end else if (valid_reg && valid && !request[user_reg]) begin
          // case 3: next user
          user_comb = priority_encoder_user_comb;
        end
      end
    
      assign user = user_comb;
    
    endmodule
    ```
    
    这里要比较注意写法上的一些规则：
    
    1. 声明 `reg` 的时候，按照它是寄存器还是连线，给予不同的名称后缀
    2. 把时序逻辑和组合逻辑写在不同的 `always` 块中
    3. 写组合逻辑的时候，需要保证每个分支下对组合逻辑信号赋值；可以预先写一个默认值防止出错
    4. 遇到复杂的逻辑的时候，一定要在代码中编写注释
    
    这样，就实现了一个循环优先级仲裁器。
    
=== "System Verilog"
    
    首先，让我们实现第一部分逻辑，即根据最后一次获取资源的用户编号确定优先级的优先级编码器：
    
    ```sv
    module rr_priority_encoder (
      input [3:0] request,
      input [1:0] last_user,
      output valid,
      output [1:0] user
    );
      logic valid_comb;
      logic [1:0] user_comb;
    
      always_comb begin
        // default
        valid_comb = 1'b0;
        user_comb = 2'd0;
    
        // naive way
        if (last_user == 2'd3) begin
          case (request)
            4'bxxx1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'bxx10: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'bx100: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b1000: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
          endcase
        end else if (last_user == 2'd0) begin
          case (request)
            4'bxx1x: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'bx10x: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b100x: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b0001: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
          endcase
        end else if (last_user == 2'd1) begin
          case (request)
            4'bx1xx: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
            4'b10xx: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b00x1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'b0010: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
          endcase
        end else if (last_user == 2'd2) begin
          case (request)
            4'b1xxx: begin
              valid_comb = 1'b1;
              user_comb = 2'd3;
            end
            4'b0xx1: begin
              valid_comb = 1'b1;
              user_comb = 2'd0;
            end
            4'b0x10: begin
              valid_comb = 1'b1;
              user_comb = 2'd1;
            end
            4'b0100: begin
              valid_comb = 1'b1;
              user_comb = 2'd2;
            end
          endcase
        end
    
      end
    
      assign valid = valid_comb;
      assign user = user_comb;
    
    endmodule
    ```
    
    这里直接暴力枚举了所有情况，你也可以尝试一下，能否从面积、延迟、可读性等方面来优化上面的代码。
    
    接着，第二部分就是我们要设计的循环优先级仲裁器：
    
    ```sv
    module rr_arbiter (
      input clock,
      input reset,
    
      input [3:0] request,
      output valid,
      output [1:0] user
    );
      logic [1:0] user_reg;
      logic valid_reg;
    
      logic [1:0] user_comb;
      logic [1:0] priority_encoder_user_comb;
      
      rr_priority_encoder rr_priority_encoder_inst (
        .request(request),
        .last_user(user_reg),
        .valid(valid),
        .user(priority_encoder_user_comb)
      );
    
      // sequential
      always_ff @ (posedge clock) begin
        if (reset) begin
          user_reg <= 2'd0;
          valid_reg <= 1'b0;
        end else begin
          valid_reg <= valid;
          if (!valid_reg && valid) begin
            // case 1: non valid -> valid
            user_reg <= priority_encoder_user_comb;
          end else if (valid_reg && valid && request[user_reg]) begin
            // case 2: persist
          end else if (valid_reg && valid && !request[user_reg]) begin
            // case 3: next user
            user_reg <= priority_encoder_user_comb;
          end
        end
      end
    
      // combinatorial
      always_comb begin
        // default
        user_comb = 2'b0;
        if (!valid_reg && valid) begin
          // case 1: non valid -> valid
          user_comb = priority_encoder_user_comb;
        end else if (valid_reg && valid && request[user_reg]) begin
          // case 2: persist
          user_comb = user_reg;
        end else if (valid_reg && valid && !request[user_reg]) begin
          // case 3: next user
          user_comb = priority_encoder_user_comb;
        end
      end
    
      assign user = user_comb;
    
    endmodule
    ```
    
    这里要比较注意写法上的一些规则：
    
    1. 声明 `reg` 的时候，按照它是寄存器还是连线，给予不同的名称后缀
    2. 时序逻辑写在 `always_ff` 块中，组合逻辑写在 `always_comb` 块中
    3. 写组合逻辑的时候，需要保证每个分支下对组合逻辑信号赋值；可以预先写一个默认值防止出错
    4. 遇到复杂的逻辑的时候，一定要在代码中编写注释
    
    这样，就实现了一个循环优先级仲裁器。