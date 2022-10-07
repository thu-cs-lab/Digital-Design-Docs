# 模型

为了进一步理解时序逻辑和组合逻辑的关系，本节介绍一个简单的描述同步时序逻辑的模型，来进一步理解时序逻辑和组合逻辑的工作方式。

这个模型假设：

1. 只有一个时钟信号
2. 寄存器都在该时钟的上升沿触发，不适用下降沿
3. 不考虑寄存器输出延迟，组合逻辑延迟，setup 和 hold 时间

经过这些简化以后，可以建立一个简单的模型，来描述硬件的行为：

1. 所有信号仅在时钟上升沿的时候变化，其他时候所有信号的值都不变；
2. 在时序逻辑中，寄存器**新**的值是根据上升沿之前**旧**的值计算，所有寄存器在一瞬间内同时变化；
3. 所有的组合逻辑也在上升沿立即按照寄存器**新**的值进行计算。

用伪代码表示就是：

```
loop {
    // 等待时钟上升沿
    wait_until_clock_posedge()

    // 保存上升沿之前所有的寄存器和组合信号的取值和顶层模块的输入信号
    values = get_values()
    top_level_input = get_top_level_input()

    // 根据寄存器取值和顶层模块的输入信号，计算出新的寄存器取值
    new_reg_values = compute_next_reg_values(values, top_level_input)
    save_reg_values(new_reg_values)

    // 根据新的寄存器取值和顶层模块的输入信号，计算出其余组合逻辑信号
    comb_values = compute_comb(new_reg_values, top_level_input)
}
```

实际上，这也是仿真时会进行的计算流程。

下面来看一个计数器的例子：

```verilog
module counter (
    input wire clk,
    input wire increment,

    output wire [3:0] count,
    output wire odd,
);
    reg [3:0] count_reg;
    wire [3:0] next_count_comb;

    always @ (posedge clk) begin
        count_reg <= next_count_comb;
    end

    assign next_count_comb = count_reg + increment;
    assign odd = count_reg[0] == 1'b1;
    assign count = count_reg;

endmodule
```

那么上面的代码对应下面的伪代码：

```
fn compute_next_reg_values(values, top_level_input) {
    map {
        count_reg: values.next_count_comb
    }
}

fn compute_comb(new_reg_values, top_level_input) {
    map {
        next_count_comb: new_reg_values.count_reg + top_level_input.increment
        odd: new_reg_values.count_reg[0] == 1'b1
        count: new_reg_values.count_reg
    }
}

fn simulate() {
    loop {
        wait_until_clock_posedge()

        reg_values = get_reg_values()
        top_level_input = get_top_level_input()

        new_reg_values = compute_next_reg_values(reg_values, top_level_input)
        save_reg_values(new_reg_values)

        comb_values = compute_comb(new_reg_values, top_level_input)
    }
}
```

可能的波形图：

<script type="WaveDrom">
{
  signal:
    [
      { name: "clk", wave: "p..."},
      { name: "increment", wave: "=.=.", data: ["1", "2"]},
      { name: "count", wave: "====", data: ["0", "1", "2", "4"]},
      { name: "odd", wave: "010."},
      { name: "count_reg", wave: "====", data: ["0", "1", "2", "4"]},
      { name: "next_count_comb", wave: "====", data: ["1", "2", "4", "6"]},
    ],
  head:{
    tick:0,
    every:2
  },
}
</script>

对应的伪代码计算流程：

1. 初始情况下 count_reg = 0, next_count_comb = 1
2. 时钟上升沿 1 来临，compute_next_reg_values() 得到 count_reg = 1
3. compute_comb() 得到 next_count_comb = 2, odd = 1, count = 1
4. 显示到波形
5. 时钟上升沿 2 来临，compute_next_reg_values() 得到 count_reg = 2
6. compute_comb() 得到 next_count_comb = 4, odd = 0, count = 2
7. 显示到波形
8. 时钟上升沿 3 来临，compute_next_reg_values() 得到 count_reg = 4
9. compute_comb() 得到 next_count_comb = 6, odd = 0, count = 4
10. 显示到波形