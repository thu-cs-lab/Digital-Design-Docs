# 板载外设（Xilinx FPGA 版）

## HDMI 接口

实验板上提供了 HDMI 视频输出接口，用于输出视频信号。FPGA 直接产生 HDMI 信号并输出，最高可支持 1080p 60Hz 24 位真彩色的视频信号。

我们的工程模板中已经提供了输出视频的样例代码，其中使用的是 800x600 分辨率，72Hz 的视频格式，其他支持的视频格式，可参考 [芯片数据手册](https://www.ti.com/lit/ds/symlink/tfp410.pdf) 或 [VGA 时序列表](http://tinyvga.com/vga-timing)，注意修改分辨率时，需要同时修改 `video` 模块例化中的时序参数以及 `rgb2dvi` IP 的设置，如无必要，不建议使用样例之外的时序格式。由于 VGA 和 HDMI 只是物理接口和传输数据的方式不同，而传输的数据、时序都是一样的，所以本实验中 VGA 或者 HDMI 实际上说的是同一回事。

样例代码中使用了如下参数，和 [VESA Signal 800 x 600 @ 72 Hz](http://tinyvga.com/vga-timing/800x600@72Hz) 对应关系如下：

- Pixel clock: 50MHz
- HSIZE: 800 (Visible Area)
- HFP: 856 = 800 (Visible Area) + 56 (Front proch)
- HSP: 976 = 856 + 120 (Sync pulse)
- HMAX: 1040 (Whole line)
- VSIZE: 600 (Visible Area)
- VFP: 637 = 600 (Visible Area) + 37 (Front porch)
- VSP: 643 = 637 + 6 (Sync pulse)
- VMAX: 666 (Whole frame)

!!! warning "使用显存"

    在工程模板中，使用了 VGA 时序模块 `video.v` 输出的横纵坐标信息，驱动显示了 24 位彩色条。在实际项目开发中，严禁此类渲染逻辑，请使用显存作为图像的缓冲区。如有必要，可以采用双缓存、ring buffer 等机制，改善渲染的效果。

!!! warning "不建议用除法和取模"

    在使用 VGA/HDMI 输出的时候，可能下意识想对坐标进行除法或者取模运算。但是使用组合逻辑实现除法和取模，需要很大的面积，时序上也会产生很长的路径。正确做法是，由于坐标的更新是有规律的，可以在每次更新坐标的同时，数周期，设置一个更新比较慢的寄存器，每 n 个周期才加 1，这样就可以持续保持和坐标有一个倍数关系。取模也是类似的。

!!! note "降低色深和分辨率"

    显存是项目中对内存消耗最大的模块。例如样例中使用的 800x600 24 位色，将会占用 `800*600*24/8/1048576 = 1.37MB` 的内存资源。而大部分设计中，无需使用 24 位真彩色（RGB888 格式），而是采用 RGB565 格式，甚至更低的色深，以尽量减少内存资源占用。对于低色深的图片，输出时可直接将其连接至视频数据的高位，将低位置 0；或采用各类转换算法完成色深之间的线性插值转换。有关这些颜色格式和相互转换，可参考 [博客文章](http://www.barth-dev.de/about-rgb565-and-how-to-convert-into-it/)。

    除了降低色深以外，也可以降低分辨率，例如显存只保存 400x300 个像素，然后在输出到 VGA/HDMI 的时候，在 x 和 y 方向上重复输出像素。

    结合色深和分辨率的压缩，可以在牺牲一定显示效果的代价下，把显存放到 FPGA 内部进行存储，此时可以用一个双端口的 RAM 作为显存。

    也可以把显存放到 FPGA 外部，例如 SRAM 和 SDRAM，此时需要考虑的是如何把读取内存的逻辑与 VGA/HDMI 控制器连接起来。由于 SRAM 和 SDRAM 只有单端口，不能同时进行读和写操作，可以使用仲裁的方式，当 VGA/HDMI 控制器不需要读的时候（例如在消隐区），其他逻辑就可以对内存进行写入。

## SDRAM 内存

实验板上提供了 512MB 容量的 DDR3 SDRAM 内存，型号为 MT41K512M8RH-107IT，关于它的特性可参考 [数据手册](https://media-www.micron.com/-/media/client/global/documents/products/data-sheet/dram/ddr3/4gb_automotive_ddr3l.pdf)。SDRAM 采用较为复杂的同步访问时序，可以支持更高的时钟频率，但需要使用多个周期，并且通过专用的控制器进行访问，有关它与 SRAM 内存的区别，请参考 [文章](http://www.differencebetween.net/object/difference-between-sram-and-sdram/)。

TODO

## 千兆以太网

实验板上提供了千兆以太网 PHY 芯片，其型号为 RTL8211。我们将其配置成了 RGMII 接口，与实验 FPGA 相连。我们的 FPGA 同时扮演了“CPU”和 MAC 芯片的角色。PHY 芯片将网线上的比特流进行接收，通过 RGMII 接口发送至 FPGA；FPGA 中实现的 MAC 模块将其进行解析后，将原始的以太网帧通过各类流式总线发送至 FPGA 中的其他逻辑，即可完成各类处理。

由于 Vivado 软件中提供的 Tri Mode Ethernet MAC IP 核需要专用的 license，助教团队使用 [verilog-ethernet](https://github.com/alexforencich/verilog-ethernet) 项目中，开源的 `eth_mac_1g_rgmii` 模块进行了调试。该模块将 RGMII 中到来的以太网帧，从 AXI Stream 接口中发出，该接口的位宽为 8bit，时钟频率为 125MHz。可以从 [TODO](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/ethernet) 找到样例工程，参考其中的使用方法。该项目中同时提供了带缓存的 `eth_mac_1g_rgmii_fifo` 模块，如果需要对以太网帧进行短时间的 FIFO 缓存，可以将 MAC 替换为该模块。

同时，针对 AXI Stream 协议，[verilog-axis](https://github.com/alexforencich/verilog-axis) 项目提供了许多有用的模块，例如 FIFO、数据宽度转换等，建议根据实际需要，使用其中的一些开源模块搭建项目。在此对这两个项目的作者 [Alex Forencich](https://github.com/alexforencich) 表示感谢，同学们也可以查看他编写的更多 Verilog 模块，从中获得启发。

## SRAM

实验板上提供了 4MB 的 SRAM，是两片型号为 [IS61WV102416BLL-10TLI](https://www.issi.com/WW/pdf/61WV102416ALL.pdf) 各 2MB 的 SRAM 数据线并联而成（两组 SRAM 连接同样的 `addr` `ce_n` `we_n` `oe_n` 信号，两组 `data` 拼接成为 32 位，两对 `ub_n` `lb_n` 组合成了 4 位的 `be_n`）。

SRAM 读写需要满足一定的时序，可以按照下面的文档，学习如何编写 SRAM 控制器：

- [计算机组成原理实验 4：总线实验之 SRAM 控制器实验](https://lab.cs.tsinghua.edu.cn/cod-lab-docs/labs/lab4/sram/)
- [异步 SRAM 的时序和控制器编写（进阶）](https://jia.je/hardware/2022/05/19/async-sram-timing/)
