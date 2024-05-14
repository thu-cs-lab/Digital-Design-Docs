# 外设相关

## 低速率外部接口

无论是 UART，I2C，PS/2，I2S 还是 SPI，这些外部接口的传输速率/时钟频率相对来说都是比较低的（例如 UART 115200 bps，I2C 几百 kHz 等等，部分外设的 SPI 比较快，达到 50 MHz，可以不按照下面的方法做），这个时候一个直接的想法可能是，用 PLL 生成一个对应频率的时钟输出（例如 UART 就生成一个 115.2 KHz 的时钟），然后实现控制逻辑。但这样做并不好：

1. 在设置 PLL 的时候会发现它不能直接生成这么低的频率，如果真要用 PLL 生成，那就需要串联多级 PLL，逐渐往下降
2. 一些协议的数据需要在时钟信号的负半周期修改，从而保留足够的时序余量，那就意味着需要用负边沿触发的寄存器做输出，同时还要在正边沿采样，这时候跨时钟域就比较复杂

因此一般的解决办法是，用一个更高频率的时钟，通过数周期的形式，模拟一个低频率下的行为。例如 I2C 时钟设定为 100 kHz，为了输出 100 kHz 的时钟给外设，FPGA 内部可以用 50 MHz 的时钟频率驱动寄存器，然后计数，每 `50 MHz / 100 kHz / 2 = 250` 个周期取反一次，然后把寄存器结果输出到 I2C 的时钟信号上，那么外设看到的就是一个 100kHz 的时钟。要修改数据的时候，通过计数，就可以知道现在是处于 I2C 的时钟的正半周期还是负半周期、时钟是否即将出现上升沿/下降沿，然后假装自己在 100 kHz 下对数据进行读和写。

注意手动分频生成的时钟仅用于输出，不用于内部寄存器的时钟输入。

## 例子

下面是一些例子：

### I2C

以 I2C 为例，假如 FPGA 内部时钟频率采用 50 MHz，I2C 采用 250 kHz，那么每 `50 MHz / 250 kHz / 2 = 100` 个周期就要翻转一次 I2C 的时钟输出，也就是 SCL：

```verilog
always @ (posedge clk_50M) begin
    if (reset) begin
        i2c_scl_counter <= 8'b0;
        i2c_scl_reg <= 1'b0;
    end else begin
        if (i2c_scl_counter == 8'd100) begin
            i2c_scl_counter <= 8'b0;
            i2c_scl_reg <= ~i2c_scl_reg;
        end else begin
            i2c_scl_counter <= i2c_scl_counter + 8'b1;
        end
    end
end

// output i2c scl
assign i2c_scl = i2c_scl_reg;
```

当然了，这是一个简化的实现，实际上 SCL 只会在需要传输数据的时候才会翻转，此时就会和状态机的转移结合在一起。为了验证输出的 SCL 信号是否真的是 250 kHz，可以在仿真环境中输入一个 50 MHz 频率的时钟，然后观察 SCL 信号一个周期是不是花了 4000 ns。

除了输出 SCL 信号，还需要在 SDA 上输入或输出数据。既然协议要求要在 SCL 的负半周期修改 SDA 上的数据用于传输，可以这么做：

```verilog
if (i2c_scl_counter == 8'd50 && i2c_scl_reg == 1'd0) begin
    // update i2c_sda
    // state machine transition
end
```

50 表示在负半周期的中点（严格来说，其实 49 才是），实际上也不一定要选中点，只要留足够的余量即可。

### I2S

I2S 是用来传输音频的协议，它的实现方法也是类似地，只不过它要输出 BCLK 和 LRCLK 两个时钟信号：LRCLK 的频率是采样频率，也就是 48 kHz；BCLK 的频率是采样频率的 48 倍（两个通道，每个通道 24 bit），也就是 `48 * 48 = 2.304 MHz`。代码中为了方便整数分频，选取了 `73.728 MHz` 作为 FPGA 内部频率，那么 LRCLK 需要每 `73.728 MHz / 48 kHz / 2 = 768` 个周期翻转一次，BCLK 需要每 `73.728 MHz / 2.304 MHz / 2 = 16` 个周期翻转一次：

```verilog
module top(
    // sample rate fs = 48kHz
    // clk = 6*256*fs = 73.728MHz
    input wire clk,
    // other signals omitted
    );

    always @(posedge clk) begin
        if (rst) begin
            i2s_lrclk_counter <= 16'b0;
            i2s_lrclk_reg <= 1'b0;
        end else begin
            // divide by 1536
            if (i2s_lrclk_counter == 16'd767) begin
                i2s_lrclk_reg <= ~i2s_lrclk_reg;
                i2s_lrclk_counter <= 16'b0;
            end else begin
                i2s_lrclk_counter <= i2s_lrclk_counter + 16'b1;
            end
        end
    end
    assign i2s_lrclk = i2s_lrclk_reg;

    always @(posedge clk) begin
        if (rst) begin
            i2s_bclk_counter <= 16'b0;
            i2s_bclk_reg <= 1'b0;
        end else begin
            // divide by 32
            if (i2s_bclk_counter == 8'd15) begin
                i2s_bclk_reg <= ~i2s_bclk_reg;
                i2s_bclk_counter <= 8'b0;
            end else begin
                i2s_bclk_counter <= i2s_bclk_counter + 8'b1;
            end
        end
    end
endmodule
```

剩下的就是在翻转 BCLK/LRCLK 的同时，读取/写入 I2S 上的音频数据了，这个就交给状态机来实现。

