# FAQ

## 修改了一些代码以后，为什么 VGA 不工作了？

VGA 不工作，常见的原因有：

- 没有输出像素时钟 video_clk
- 像素时钟与 VGA 时序不匹配，常见的原因是修改了 PLL 的设置，改了时钟频率，但是没有改 vga 的参数

因此如果需要 50MHz 以外的时钟频率，有两种办法实现：

1. 在 PLL IP 设置中新增一个时钟输出，把这个时钟频率设置成自己想要的频率；需要解决跨时钟域的问题
2. 把 VGA 时钟频率改成自己想要的时钟频率，把 VGA 的时钟同时用于其他逻辑；前提是要找到匹配的 VGA Timing，使得 Pixel Clock 是期望的时钟频率，然后相应地修改 vga 模块的参数。

## SD 卡读取出的数据与预期结果不一致？

SD 卡读取的时候，不同 SD 卡的地址编码不一样：

- SDSC 读取的地址单位是字节
- SDHC 和 SDXC 读取的地址单位是扇区，每个扇区 512 字节

目前示例代码没有内置自动检测 SDSC 或 SDHC 的逻辑，如果想要实现，可以发送 CMD58 命令获取 CCS，如果 CCS 为 0 就是 SDSC，CCS 为 1 就是 SDHC 或 SDXC。可以从 SD 卡表面区分 SDSC/SDHC/SDXC。

如果使用 WinHex 工具来查看文件的地址，需要注意的是，默认显示的地址可能是相对于分区开头的，而不是 SD 卡开头。例如地址 0x00044000 对应逻辑扇区 544，但是分区前还有 32 个扇区，物理扇区号是 544+32=576，因此在读取 SD 卡的时候，应该要读取第 576 个扇区。这些数据在 WinHex 的右侧边栏中会显示。

## COE 文件的格式是什么样的？

官方文档：[COE File Syntax](https://docs.amd.com/r/en-US/ug896-vivado-ip/COE-File-Syntax)，文档中给出了几个例子：

```ini
; This .COE file specifies the contents for a block memory
; of depth=16, and width=4. In this case, values are specified
; in binary format.
memory_initialization_radix=2;
memory_initialization_vector=
1111,
1111,
1111,
1111,
1111,
0000,
0101,
0011,
0000,
1111,
1111,
1111,
1111,
1111,
1111,
1111;
```

```ini
; The example specifies initialization values for a memory of depth= 32, 
; and width=16. In this case, values are specified in hexadecimal
; format.
memory_initialization_radix = 16;
memory_initialization_vector = 23f4 0721 11ff ABe1 0001 1 0A 0
 23f4 0721 11ff ABe1 0001 1 0A 0
 23f4 721 11ff ABe1 0001 1 A 0
 23f4 721 11ff ABe1 0001 1 A 0;
```

## 出现 Incorrect bitstream assigned to device 错误

实验模板已经配置好了实验 FPGA 的型号，因此如果没有修改过实验模板的配置，那么项目配置是没有问题的。此时，可以去 Hardware Manager 查看一下，如果识别到的 FPGA 型号是 xc7z020，那就说明 JTAG 插错地方了，识别了错误的 FPGA，应该插到板子左下角的 JTAG 插座上。

## 出现 A LUT3 cell in the design is missing a connection 错误

这通常是使用了某个 Vivado 提供的 IP，例化以后，部分信号没有连接，导致 Vivado 在优化的时候，发现部分信号空悬，这才报了错。

这个时候，打开 IP 配置界面，或者查看 IP 的 Instantiaion Wrapper，可以看到 IP 都有哪些输入输出信号，结合 IP 的文档了解这些信号的含义，进行正确的连接或赋值。

## Vivado 提示奇怪的 Verilog 语法错误，无法直接定位到问题

这是因为 Vivado 的 Verilog 报错功能实现地比较粗暴，可能前面某个地方写错了一点，导致后面的代码都被解析成错误的语法，然后出现不知所云的错误。此时就要人工浏览一遍代码，仔细找找语法错误。

类比一下，写 C/C++ 的时候，如果出现了类似的问题，GCC/Clang 等编译器做的会比较好，会找出程序员一些常见的错误并指出，而不是简单地汇报 lexer/parser 分析时出现的直接问题。Vivado 显然没有花那么多功夫。
