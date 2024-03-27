# 实验板（Xilinx FPGA 版）

## 实验板外观

!!! warning "了解硬件"

    在开始进行你的实验之前，请务必仔细阅读本章，了解实验板各组件的功能，防止错误的硬件连接损坏实验板。

《数字逻辑设计》课程所用的实验板（Xilinx FPGA 版）外观如图：

![Board](../img/board_xilinx.png)

实验时可能用到的组件标号如下图，具体描述及功能请阅读下一节了解。

![Board with annotation](../img/board_xilinx_anno.png)

## 各组件说明

图片中标注的组件描述如下：

1. 千兆 RJ45 以太网接口（LAB\_ETH）：使用 RTL8211 PHY 芯片，通过 RGMII 总线与 FPGA 相连；
2. PS/2 鼠标接口（LAB\_MOUSE）；
3. PS/2 键盘接口（LAB\_KBD）；
4. HDMI 视频接口（LAB\_HDMI）：最高支持 1080P 24 位色，样例代码请参考工程模板；
5. RS-232 串口（LAB\_RS232）：可连接使用 RS-232 电平的串口外设；
6. USB 转 TTL 串口（LAB\_UART）：连接电脑可用于 FPGA 的调试输出；
7. SD 卡座（LAB\_SD）：建议使用小容量低速 SD 卡，并通过 SPI 协议访问；按照标准，除了 SDUC 以外，其他的 SD 卡都应该支持 SPI 协议，但一些 SD 卡型号违背了标准，不支持 SPI 协议，见 [来源 1](https://forum.4dsystems.com.au/node/1869) 和 [来源 2](https://github.com/MarlinFirmware/Marlin/issues/2082#issuecomment-102381964)；
8. 32 位 LED 灯：用于调试，使用方法请参考工程模板；
9. 8 位扫描式数码管（DPY1-2）：使用方法请参考工程模板；
10. 512MB DDR3-1866 SDRAM 内存：512 Mb x 8，型号为 [MT41K512M8RH-107IT](https://media-www.micron.com/-/media/client/global/documents/products/data-sheet/dram/ddr3/4gb_automotive_ddr3l.pdf)；
11. 4MB（并行）SRAM 内存：32 位宽，理论延迟为 10ns，是两片型号为 [IS61WV102416BLL-10TLI](https://www.issi.com/WW/pdf/61WV102416ALL.pdf) 各 2MB 的 SRAM 数据线并联而成（两组 SRAM 连接同样的 `addr` `ce_n` `we_n` `oe_n` 信号，两组 `data` 拼接成为 32 位，两对 `ub_n` `lb_n` 组合成了 4 位的 `be_n`）；
12. 16MB SPI NOR Flash：型号为 [W25Q128JVSIQTR](https://www.winbond.com/hq/product/code-storage-flash-memory/serial-nor-flash/?__locale=en&partNo=W25Q128JV)；
13. 8MB 串行 SRAM 内存：型号为 [VTI7064](https://www.lcsc.com/datasheet/lcsc_datasheet_1811151432_Vilsion-Tech-VTI7064MSME_C139966.pdf)；
14. FPGA JTAG 调试接口（LAB\_JTAG）：用于连接 Xilinx 下载器下载程序；
15. 2 个带去抖按键（CLK、RST）：自带硬件去抖电路，按下时为高电平；
16. 4 个带去抖按键（KEY1-4）：自带硬件去抖电路，按下时为高电平；
17. 16 位拨码开关（LAB_SW1-2）：拨上时为低电平；
18. 电源输出接口：可用于给外设模块供电，支持 5V 和 3.3V 两种电压；
19. 电源输入接口：**只允许** 连接提供的 12V 直流电源，用于给实验板供电。
20. USB 控制接口（CTL\_OTG）：连接电脑，可用于读写 SRAM 内存；

另外，我们还提供了 5 个 Pmod 扩展接口，可连接兼容 Pmod 标准的外设模块，或使用杜邦线连接其他外设模块。具体使用方法参见 [常见外设](peripheral.md) 章节。

FPGA 型号是 [XC7A200T-2FBG484I](https://docs.amd.com/v/u/en-US/7-series-product-selection-guide)，内置资源有：

- Logic Cells: 215360
- Total Block RAM: 13140 Kb
- DSP Slices: 740
- PLL: 10

## 控制模块使用方法

TODO

### SRAM 读写操作

TODO

## macOS 用户

如果你使用 macOS，由于 Vivado 不支持 macOS，需要在虚拟机或者远程 Linux 环境下运行 Vivado，用 VSCode Remote 进行远程开发。生成 Bitstream .bit 文件后（路径为项目目录下的 `project-template-xilinx.runs/impl_1/mod_top.bit`），复制到本地，再用 openFPGALoader 下载：

```shell
# in macOS
$ brew install openfpgaloader
$ openFPGALoader -c ft2232 --detect
empty
Jtag frequency : requested 6.00MHz   -> real 6.00MHz
index 0:
        idcode 0x3636093
        manufacturer xilinx
        family artix a7 200t
        model  xc7a200
        irlength 6
$ scp linux:/path/to/mod_top.bit .
$ openFPGALoader -c ft2232 --fpga-part xc7a200t mod_top.bit
```

此外，部分 macOS 系统无法连接到控制模块，可以使用 USB 直通到 Linux 虚拟机的方法。


## 与 Intel FPGA 版实验板的区别

Xilinx FPGA 版实验板是 2023 年新设计的数字逻辑设计实验开发板，相比上一个 Intel FPGA 版实验板，做出了如下的改变：

1. FPGA 从 Intel 的 EP4CE115F29I7 换为 Xilinx 的 XC7A200T-2FBG484I，新旧 FPGA 对比，制程从 60nm 提升到 28nm，同时逻辑单元数量提升到 2 倍，内置的 Block RAM 容量提升到 3 倍，可以给同学的设计留下更充足的空间；
2. 将 32MB SDR SDRAM 内存升级到 512MB DDR3 SDRAM 内存，在速度和容量上获得了巨大的提升；
3. 把 PS/2 接口扩展到两个，不再需要鼠标键盘二选一，可以全都要；
4. 由于引脚个数限制，减少了 PMOD 扩展接口的个数：从 8 减少到 5，不过不用担心，根据往年的经验，5 个也是用不完的；
5. 由于引脚个数限制，减少了一组 SRAM，只剩下了一组（并行）SRAM，不过作为补偿，添加了 16MB 的 SPI NOR Flash 和 8MB 串行 SRAM 内存。