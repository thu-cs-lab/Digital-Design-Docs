# Quartus 使用

## 下载安装

本实验使用的 EDA 软件为 Intel Quartus Prime Lite 20.1.1 （以及 Cyclone 设备支持）和配套的 ModelSim 仿真器。为了正常使用，请确保你的硬盘 **至少有 50GB 可用空间**。

Windows 用户请从 [清华云盘](https://cloud.tsinghua.edu.cn/d/8b419beff6d346d09854/) 下载所有的文件，Linux 用户请自行从 [Intel 官网](https://fpgasoftware.intel.com/?edition=lite) 下载对应版本（可能需要注册用户）。

各个组件的安装顺序如下：

* 首先安装 Quartus Prime Lite，使用默认选项即可，注意路径中不要有空格和中文；
* 启动 Quartus，选择 Tools → Install Devices，选择下载的 Cyclone 设备支持文件；
* 最后安装 ModelSim。安装后启动 Quartus，选择 Tools → Options → EDA Tool Options，确认已经自动识别了 ModelSim-IntelFPGA 的安装路径（否则需要手工配置）。

## 工程模板

请从 [此处](static/digital-design-template.zip) 下载工程模板。解压后即可导入 Quartus 中，通常不需要更改任何设置即可使用。

模板中的重要文件和目录包括：

* `digital-design.qpf`：Quartus 项目文件，可以在 Quartus 中通过 File → Open Project 打开
* `digital-design.qsf`：Quartus 设置文件
* `io.tcl`：IO 管脚绑定约束
* `src/`：放置你编写的 RTL 代码
    * `mod_top.sv`：顶层模块，请根据需要取消信号列表中的注释，注意列表末尾的逗号
    * `dpy_scan.v`：数码管扫描、译码模块
    * `vga.v`：使用 VGA 时序驱动 HDMI 接口的样例
* `ip/`：用于放置 Quartus 生成的各类 IP
    * `pll`：预生成的 PLL 模块，用于从输入的 100M 时钟生成 50M 时钟提供给 VGA 模块

在新建文件时，你也应当遵循这一规范，合理放置文件。

!!! success "推荐使用 Git"
    
    强烈推荐使用 Git 进行版本控制管理，而不是使用微信交换文件。助教提供的 `.gitignore` 文件可直接使用，用来忽略 Quartus 生成的中间文件。

### RTL 代码

推荐使用 SystemVerilog 语言编写项目，当然你可以自由选择任何 Quartus 支持的语言。简单的 SystemVerilog 介绍可见 [此课件](static/systemverilog.pdf)，需要注意你只能使用 SystemVerilog 中的 **可综合部分**。

!!! error "禁止使用坐标驱动图像输出"

    提供的 `mod_top.sv` 中使用了横纵坐标来计算出某个像素的颜色，请不要使用这种方法驱动复杂的渲染逻辑，否则将导致 **严重的时序问题**！

RTL 代码应该具有良好的风格，如规范的缩进、清晰的命名和恰当的注释。

### 管脚绑定约束

为了正确地使用外设，需要配置顶层模块的输入/输出信号对应的 FPGA 管脚，此部分内容都包含在 `io.tcl` 中。由于顶层模块中没有声明所有的信号，有部分约束被注释了，包括：

* 所有的 PMOD 接口
* SD 模式的 SD 卡（和 SPI 模式冲突，只能使用一组）
* `ext_ram` 的所有信号（ **此版本的实验板上没有焊接 Ext RAM，无法使用** ）

在使用时，请根据需要修改此文件，但 **不要随意修改管脚名**。

### IP 使用

Quartus 提供了丰富的 IP Core，你可以根据需要自由生成和选用（在 Quartus 的 IP Catalog 中选择）。一些常用的 IP Core 包括：

* RAM / ROM
* FIFO（用于时钟域同步或者任务队列）
* 各类 DSP（乘除法、开方、乘方、三角函数等数学运算）
* Triple-Speed Ethernet（用于驱动 GMII 以太网 PHY）

在使用任何 IP 前，请 **完整阅读** 它的使用手册（通常 Quartus 自带，或可以从 Intel 官网获取）。如果部分 IP 不包含在 Lite 版本的软件中，请联系助教团队寻求帮助。
