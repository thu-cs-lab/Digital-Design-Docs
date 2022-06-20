# 总线协议

本节介绍了开发过程中可能使用的总线协议。总线协议用于仲裁多个主从设备的读写请求，通常分为内存映射协议与流式传输协议。

## 握手信号

总线协议通常使用 ready / valid 信号进行握手。在使用时，需要严格遵守相应文档中的说明，否则可能产生死锁等不正确状态。一些参考说明可见：

* <https://inst.eecs.berkeley.edu/~cs150/Documents/Interfaces.pdf>
* <http://fpgacpu.ca/fpga/handshake.html>
* <http://fpgacpu.ca/fpga/Pipeline_Skid_Buffer.html>
* <https://zipcpu.com/blog/2019/05/22/skidbuffer.html>
* <https://jia.je/hardware/2021/01/26/skid-buffer/>


## 内存映射协议

内存映射协议（memory-mapped protocol）用于可寻址的数据传输，通常用于 CPU 等复杂设备。其传输的单位是“事务”（transaction），通常有数据、地址、响应等多个通道（channel），在传输前需要进行协商，包括方向（读/写）、地址、数据大小、传输模式（单次、突发、回绕）等。

IntelFPGA 上的 IP 使用的标准内存映射协议为 Avalon，详细说明位于 [官方文档](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf) 的第三节。

由 ARM 牵头定制的 AMBA (Advanced Microcontroller Bus Architecture) 规范中包含了名为 AXI 和 AXI-Lite 的内存映射协议，被 Xilinx 等平台广泛使用。其文档可见 [Xilinx UG761](https://www.xilinx.com/support/documentation/ip_documentation/ug761_axi_reference_guide.pdf)，以及 [AMBA 规范](https://developer.arm.com/documentation/ihi0022/hc) 的 Part A/B。

在一些开源设计中，例如 Opencores 网站上的 IP，通常会使用 Wishbone 内存映射协议，它相对上面的两种协议来说比较简单，可以阅读 [Wishbone 总线协议介绍](https://jia.je/hardware/2022/06/19/wishbone/) 和 [Wishbone 总线协议标准](https://cdn.opencores.org/downloads/wbspec_b4.pdf)。

在使用内存映射协议时，以下的 IP 可能会对设计有帮助：

* Interconnect / Crossbar：在多个主/从设备间进行仲裁，并可能包含下面列举的所有功能
* Width Converter：转换主从接口的数据宽度
* Clock Converter：转换主从接口的时钟频率
* FIFO：在接口间缓存数据
* Register Slice：插入寄存器，切断组合逻辑，改善时许

Quartus 与 Vivado 中均有相应的 IP 可供使用。

## 流式传输协议

流式协议（streaming protocol）通常用于大量数据的传输，通常只有一个传输方向和通道，传输单位为“帧”（frame），无地址概念。常见的流式传输协议如下：

IntelFPGA 上的 IP 使用的标准流式协议为 Avalon Streaming (Avalon-ST)，详细说明位于 [官方文档](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf) 的第五节。

AMBA 中同样包含了名为 AXI Stream 的流式协议，也被 Xilinx 平台广泛使用。其文档可见 [Xilinx UG761](https://www.xilinx.com/support/documentation/ip_documentation/ug761_axi_reference_guide.pdf) 的第 45 页，以及 [AMBA 规范](https://developer.arm.com/documentation/ihi0051/a/Introduction/About-the-AXI4-Stream-protocol)。

流式协议同样存在 Interconnect、Crossbar、Width Converter、Clock Converter、Register Slice 等辅助组件，Quartus 与 Vivado 中都有相应的 IP 可供使用。

## 协议检查器

在实现总线协议的时候，可能会遇到一些实现上不满足标准的情况，此时可能会遇到例如死锁、数据错误等问题。为了解决这个问题，可以使用一些现成的协议检查器（Protocol Checker）。你可以将协议检查器接到你实现的总线协议接口上，它就会按照标准的要求进行检查。如果出现错误了，在仿真的时候，它会在仿真输出窗口打印错误信息；在 FPGA 上会输出错误信号，你可以把错误信号接到 LED 或者 ILA 上，从而判断是否在运行时出现了问题。