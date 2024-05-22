# 板载外设（Xilinx FPGA 版）

## HDMI 接口

实验板上提供了 HDMI 视频输出接口，用于输出视频信号。FPGA 直接产生 HDMI 信号并输出。我们的工程模板中已经提供了输出视频的样例代码，代码使用的是 800x600 分辨率，72Hz 的视频格式，此时像素时钟正好是 50MHz。

其他支持的视频格式，可参考 [VGA 时序列表](http://tinyvga.com/vga-timing)，注意修改分辨率时，需要同时修改 `video` 模块例化中的时序参数以及 `rgb2dvi` IP 的设置（注意 TMDS clock range 选项），如无必要，不建议使用样例之外的时序格式。受 FPGA 限制（见 [Artix 7 Datasheet](https://docs.amd.com/v/u/en-US/ds181_Artix_7_Data_Sheet)），像素时钟不应超过 136 MHz（`F_{MAX\_BUFIO} / 5 = 680 / 5 = 136`）。

由于 VGA 和 HDMI 只是物理接口和传输数据的方式不同，而传输的数据、时序都是一样的，所以本实验中 VGA 或者 HDMI 实际上说的是同一回事。

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

    显存是项目中对内存消耗最大的模块。例如样例中使用的 800x600 24 位色，将会占用 `800*600*24/8/1048576 = 1.37MB` 的内存资源。而大部分设计中，无需使用 24 位真彩色（RGB888 格式），而是采用 RGB565 格式，甚至更低的色深（例如 RGB232），以尽量减少内存资源占用。对于低色深的图片，输出时可直接将其连接至视频数据的高位，将低位置 0；或采用各类转换算法完成色深之间的线性插值转换。有关这些颜色格式和相互转换，可参考 [博客文章](http://www.barth-dev.de/about-rgb565-and-how-to-convert-into-it/)。

    除了降低色深以外，也可以降低分辨率，例如显存只保存 400x300 个像素，然后在输出到 VGA/HDMI 的时候，在 x 和 y 方向上重复输出像素。

    结合色深和分辨率的压缩，可以在牺牲一定显示效果的代价下，把显存放到 FPGA 内部进行存储，此时可以用一个双端口的 RAM 作为显存。

    不用太追求分辨率和 24 位色，如果担心效果不好，就自己在电脑上用图片测试一下降分辨率和颜色深度的效果，看看是否能接受。

    也可以把显存放到 FPGA 外部，例如 SRAM 和 SDRAM，此时需要考虑的是如何把读取内存的逻辑与 VGA/HDMI 控制器连接起来。由于 SRAM/SDRAM 只有单端口，不能同时进行读和写操作，可以使用仲裁的方式，当 VGA/HDMI 控制器不需要读的时候（例如在消隐区），其他逻辑就可以对内存进行写入。如果把 SRAM/SDRAM 用于显存，从 SRAM/SDRAM 读取的数据要通过 VGA/HDMI 显示到显示器上，那么需注意 SRAM/SDRAM 控制器的时钟和显示输出的像素时钟，如果这两个时钟不是同一个，就需要考虑跨时钟域的问题。如果想避免跨时钟域的问题，可以让 SRAM 控制器以显示输出的像素时钟作为时钟，不过代价是读写 SRAM 需要的时间变长，设计上需要做一些取舍；SDRAM 控制器通常无法简单地任意设置时钟频率，因此需要针对跨时钟域进行处理。

!!! note "不要猜，动动手，算一下！"

    在软件上，图片是用一个数组来表示的，要修改这个数组，很自然地会想到用一个循环去更新它的内容。而在硬件中，要实现类似的更新，则会用状态机的方式，每个周期修改一点，用很多个周期完成整个更新。但你可能会担心，每个周期只改一点，例如只改一个像素，把整个 800x600 的画面都更新一遍，会不会很慢？

    不要猜，动动手，算一下！假设 800x600 的画面，每个周期更新一个像素，那就需要 `800 * 600 * 1 = 480000` 个周期，这个周期是在 50MHz 的频率下，那么换算成时间，就是 `480000 / 50 / 1000000 = 0.0096`，也就是 9.6 ms，人眼是看不出来的。所以不要猜一个事情是快还是慢，既然知道频率，要用多少个周期也可以算出来，自己动手乘一下，就可以知道到底多快多慢了。

## SDRAM 内存

实验板上提供了 512MB 容量的 DDR3 SDRAM 内存，型号为 MT41K512M8RH-107IT，关于它的特性可参考 [数据手册](https://media-www.micron.com/-/media/client/global/documents/products/data-sheet/dram/ddr3/4gb_automotive_ddr3l.pdf)。SDRAM 采用较为复杂的同步访问时序，可以支持更高的时钟频率，但需要使用多个周期，并且通过专用的控制器进行访问，有关它与 SRAM 内存的区别，请参考 [文章](http://www.differencebetween.net/object/difference-between-sram-and-sdram/)。

在实验框架的 `sdram` 分支中，已经给出了一个 SDRAM 内存的访问示例，它例化了 Xilinx Vivado 提供的 MIG IP，通过它的 User Interface 接口读写 SDRAM 内存，这个接口分为三部分：

1. Command：把 Command 以及内存地址传给 MIG，Command 可以是读或者写
2. Write Data：把要写入的数据传给 MIG
3. Read Data：MIG 会输出从 SDRAM 读取到的内存数据

因此，要完成一次写操作，要在 Command 接口上发送写命令，并且在 Write Data 接口上传要写入的数据；要完成一次读操作，要在 Command 接口上发送读命令，在 Read Data 接口上等待读取完成并获取数据。

完整的接口描述，请阅读 [Zynq-7000 SoC and 7 Series Devices Memory Interface Solutions](https://docs.amd.com/v/u/en-US/ug586_7Series_MIS) 第一章中相关内容。


## 千兆以太网

实验板上提供了千兆以太网 PHY 芯片，其型号为 RTL8211。我们将其配置成了 RGMII 接口，与实验 FPGA 相连。我们的 FPGA 同时扮演了“CPU”和 MAC 芯片的角色。PHY 芯片将网线上的比特流进行接收，通过 RGMII 接口发送至 FPGA；FPGA 中实现的 MAC 模块将其进行解析后，将原始的以太网帧通过各类流式总线发送至 FPGA 中的其他逻辑，即可完成各类处理。

由于 Vivado 软件中提供的 Tri Mode Ethernet MAC IP 核需要专用的 license，助教团队使用 [verilog-ethernet](https://github.com/alexforencich/verilog-ethernet) 项目中，开源的 `eth_mac_1g_rgmii` 模块进行了调试。该模块将 RGMII 中到来的以太网帧，从 AXI Stream 接口中发出，该接口的位宽为 8bit，时钟频率为 125MHz。可以从 [模板仓库的 ethernet 分支](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/ethernet) 找到样例工程，参考其中的使用方法。该项目中同时提供了带缓存的 `eth_mac_1g_rgmii_fifo` 模块，如果需要对以太网帧进行短时间的 FIFO 缓存，可以将 MAC 替换为该模块。

同时，针对 AXI Stream 协议，[verilog-axis](https://github.com/alexforencich/verilog-axis) 项目提供了许多有用的模块，例如 FIFO、数据宽度转换等，建议根据实际需要，使用其中的一些开源模块搭建项目。在此对这两个项目的作者 [Alex Forencich](https://github.com/alexforencich) 表示感谢，同学们也可以查看他编写的更多 Verilog 模块，从中获得启发。

## SRAM

实验板上提供了 4MB 的 SRAM，是两片型号为 [IS61WV102416BLL-10TLI](https://www.issi.com/WW/pdf/61WV102416ALL.pdf) 各 2MB 的 SRAM 数据线并联而成（两组 SRAM 连接同样的 `addr` `ce_n` `we_n` `oe_n` 信号，两组 `data` 拼接成为 32 位，两对 `ub_n` `lb_n` 组合成了 4 位的 `be_n`）。

SRAM 读写需要满足一定的时序，可以按照下面的文档，学习如何编写 SRAM 控制器：

- [计算机组成原理实验 4：总线实验之 SRAM 控制器实验](https://lab.cs.tsinghua.edu.cn/cod-lab-docs/labs/lab4/sram/)
- [异步 SRAM 的时序和控制器编写（进阶）](https://jia.je/hardware/2022/05/19/async-sram-timing/)

需要注意 SRAM 的数据信号要使用三态门。

如果把 SRAM 用于显存，从 SRAM 读取的数据要通过 HDMI 显示到显示器上，那么需注意 SRAM 控制器的时钟和显示输出的像素时钟，如果这两个时钟不是同一个，需要考虑跨时钟域的问题。如果想避免跨时钟域的问题，可以让 SRAM 控制器以显示输出的像素时钟作为时钟，不过代价是读写 SRAM 需要的时间变长，设计上需要做一些取舍。

## SPI NOR Flash

实验板子还提供了 16MB 的 SPI NOR Flash，型号为 [W25Q128JVSIQTR](https://www.winbond.com/hq/product/code-storage-flash-memory/serial-nor-flash/?__locale=en&partNo=W25Q128JV)。它是一片非易失的 Flash 存储，可以用来保存自己的数据。FPGA 通过 SPI 或者 QSPI 接口，可以快速地随机访问 SPI NOR Flash 的内容。Flash 写入时，需要先擦除，再写入新的数据。

## SPI SRAM

实验板子还提供了 8MB SPI SRAM 内存，型号为 [VTI7064](https://www.lcsc.com/datasheet/lcsc_datasheet_1811151432_Vilsion-Tech-VTI7064MSME_C139966.pdf)。它和前面所述的（并行）SRAM 的区别主要是接口不同，这里的 SPI SRAM 接口需要通过 SPI 接口访问，实现更简单，速度会慢一些，但是容量更大。

## PS/2

实验板提供了两个 PS/2 接口，可以用于同时连接一个键盘和一个鼠标，但实际上，无论是键盘还是鼠标，接口和协议都是一样的。其中 PS/2 键盘更简单，如果不考虑大小写锁定的灯的显示，就不需要实现从 FPGA 向 PS/2 键盘发送命令；而 PS/2 鼠标比较复杂，需要 FPGA 向 PS/2 鼠标发送命令，告诉鼠标按照什么格式向 FPGA 发送信息。实验框架针对 PS/2 键盘和鼠标分别提供了样例代码。

## UART 串口

实验板提供了 UART 串口，并且内置了 USB 转串口芯片，只需要拿一根 USB Type-B 的线，把实验板的 LAB_UART 口连接到电脑上，就可以在电脑上读写串口。另一侧，FPGA 可以通过 UART 协议进行串口通信，可以用于一些低速的通信，也可以用来调试。

类似地，实验板还提供了 RS232 电平的串口，可以用来连接 RS-232 电平的外设。不过近几年还没有遇到过这个需求。

## SD 卡

实验板提供了 SD 卡座，可以用来插入 SD 卡。SD 卡直接连接到 FPGA，FPGA 可以用不同协议来实现访问 SD 卡的功能。其中比较简单的是 SPI 协议，按照标准，除了 SDUC 以外，其他的 SD 卡都应该支持 SPI 协议，但一些 SD 卡型号违背了标准，不支持 SPI 协议，见 [来源 1](https://forum.4dsystems.com.au/node/1869) 和 [来源 2](https://github.com/MarlinFirmware/Marlin/issues/2082#issuecomment-102381964)。因此建议使用小容量低速 SD 卡，并通过 SPI 协议访问。实验框架提供了一个通过 SPI 协议访问 SD 卡的样例。

需要注意的是，SD 卡访问的时候，直接使用扇区地址去读写数据，而实际电脑上看到的文件，要经过文件系统和分区表两层映射才会对应到具体的扇区上。建议用一些软件直接操作 SD 卡的扇区，绕过文件系统和分区表，这样可以保证电脑上写入指定的扇区，从 FPGA 可以正确地读出来。