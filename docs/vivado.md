# Vivado 使用

Vivado 是用于 Xilinx FPGA 的 EDA 开发工具。

## 下载安装

本实验使用的 EDA 软件为 Xilinx Viavdo 2019.2，安装过程可以参考 [数字逻辑实验课程的 Vivado 安装文档](https://lab.cs.tsinghua.edu.cn/digital-logic-lab/doc/vivado-install/)。请保证硬盘至少有 50GB 的可用空间。

!!! info "为什么不用新版本"

    Vivado 的新版本安装包体积急剧增长，动辄大几十 GB，而在线安装器又需要很长的时间下载，这给安装新版 Vivado 带来了极大的困扰。当然了，新版本的 Vivado 在性能方面可能有一些提升。下面给出了几个版本的参考安装大小（实际大小与选择安装的组件有关）：

    - Vivado 2019.2: 22 GB
    - Vivado 2020.2: 33 GB
    - Vivado 2022.1: 69 GB

    如果你觉得上述问题可以解决，可以和同组同学协商，一起更新到新版本。

## 工程模板

工程模板的仓库为 <https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx>。我们为每个组在清华 GitLab 上创建了项目，仓库地址为 `https://git.tsinghua.edu.cn/digital-design-lab/2024-spring/digital-design-grp-XX`，其中 `XX` 为分配的组号。仓库中已经预置了最新的工程模板，通常可以直接使用。

工程模板还提供了一些外设的样例，下面描述了这些样例的功能，以及这些样例大概做了哪些改动：

- [ethernet](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/ethernet) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...ethernet): 以太网 IP，收到的数据求和后显示在数码管上
    - 把 [verilog-ethernet](https://github.com/alexforencich/verilog-ethernet) 作为 git submodule 加入到 git 仓库中，并把需要用到的文件加入到 vivado 项目
    - 修改 `io.xdc`，取消涉及到 RGMII 部分约束的注释
    - 修改 `mod_top.sv`，取消 RGMII 的顶层信号的注释，例化 `eth_mac_1g_rgmii_fifo` 模块
    - 修改 `ip_pll` 设置，添加两个额外的时钟输出：第一个是 125MHz 时钟，第二个是带 90 度相位差的 125 MHz 时钟
- [ps2_keyboard](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/ps2_keyboard) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...ps2_keyboard): PS/2 键盘，敲击键盘，键盘的 scancode 会显示在数码管上
    - 修改 `io.xdc`，取消涉及到 PS/2 Keyboard 部分约束的注释
    - 修改 `mod_top.sv`，取消 PS/2 Keyboard 的顶层信号的注释，例化 `ps2_keyboard` 模块
    - 在 `ps2_keyboard.sv` 中实现 PS/2 Keyboard 控制器的逻辑
    - 修改 `mod_top_tb.v` ，在仿真环境中验证 PS/2 Keyboard 控制器的正确性
- [ps2_mouse](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/ps2_mouse) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...ps2_mouse): PS/2 鼠标，移动鼠标，鼠标的 x-y 坐标会显示在数码管上
    - 修改 `io.xdc`，取消涉及到 PS/2 Mouse 部分约束的注释
    - 修改 `mod_top.sv`，取消 PS/2 Mouse 的顶层信号的注释，例化 `ps2_mouse` 模块
    - 在 `ps2_mouse.sv` 中基于 [PS/2 控制器 IP](https://github.com/jiegec/ps2) 实现 PS/2 Mouse 控制器的逻辑
    - 修改 `mod_top_tb.v` ，在仿真环境中验证 PS/2 Mouse 控制器的正确性
- [sdcard](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/sdcard) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...sdcard): SD 卡，读取 SD 卡的第一个扇区的内容，滚动显示在数码管上
    - 修改 `io.xdc`，取消涉及到 SDCard SPI 部分约束的注释
    - 修改 `mod_top.sv`，取消 SDCard SPI 的顶层信号的注释，例化 `sd_controller` 模块
    - 在 `sd_controller.sv` 中实现 SDCard SPI 控制器的逻辑
    - 修改 `ip_pll` 设置，添加一个额外的 5MHz 时钟输出用于 SPI 协议
    - 修改 `mod_top_tb.v` ，在仿真环境中验证 SDCard SPI 控制器的正确性
- [sram](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/tree/sram) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...sram): SRAM，添加了 SRAM 仿真模型，没有附带 SRAM 控制器，在实验板子上不会有任何输出；可以在这个项目的基础上，测试自己编写的 SRAM 控制器代码
    - 修改 `io.xdc`，取消涉及到 Base RAM 部分约束的注释
    - 修改 `mod_top.sv`，取消 SDCard SPI 的顶层信号的注释
    - 修改 `mod_top_tb.v` ，在仿真环境中添加 SRAM 仿真模型
- [pmod_i2c](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/pmod_i2c) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...pmod_i2c): 只实现了针对 WM8731 的 I2C 写入，没有处理 ACK；可以在这个项目的的基础上，修改引脚定义（`io.xdc`），修改写入的寄存器（`i2c.sv`），添加 ACK 判断等等
    - 修改 `io.xdc`，复制 PMOD 的 IO 约束，把信号名称改为 I2C 的信号
    - 修改 `mod_top.sv`，添加 I2C 的顶层信号，例化 I2C 控制器 `i2c.sv`
    - 在 `i2c.sv` 中实现 I2C 控制器的逻辑
- [ila](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/ila) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...ila): 使用 Vivado 提供的内嵌逻辑分析仪（ILA），实时观察 FPGA 内部信号的取值
    - 在源码中对要进行调试的信号添加 `(* mark_debug = "true" *)`，点击 `Run Synthesis` 开始综合
    - 综合完成后，点击 `Open Synthesized Design`，点击 `Set Up Debug`，按照提示，把信号加入到 ILA 中，设置好对应的时钟域
    - 点击保存，把更新后的约束保存在 debug.xdc 中，重新 `Generate Bitstream`
    - 在 `Program Device` 之后，就可以观察到 ILA 的界面，进而观察到 FPGA 内部的信号
- [sdram](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/sdram) [diff](https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx/-/compare/master...sdram): 向 DDR3 SDRAM 写入数据，再读出来，显示在数码管上
    - 例化 MIG（Memory Interface Generator），作为 DDR3 SDRAM 内存控制器
    - 不需要修改 `io.xdc`，因为 MIG 会自己生成一份约束文件
    - 修改 `mod_top.sv`，添加 DDR3 SDRAM 的顶层信号，例化 DDR3 SDRAM 控制器
    - 在 `mod_top.sv` 中实现通过 MIG 的接口读写 DDR3 SDRAM 的逻辑

注：切换分支的时候如果 Vivado 已经打开了项目，那么 Vivado 是不会自动从硬盘读取新的项目文件的，因此建议用 Viado 重新打开一次项目。

!!! success "必须使用 Git"
    
    课程强制使用 Git 进行版本控制管理，而不是使用微信交换文件。助教提供的 `.gitignore` 文件可直接使用，用来忽略 Vivado 生成的中间文件。

如果原始框架代码有更新（届时会通过多种渠道通知），你可以如下合并这些更新：

```shell
> git remote add upstream git@git.tsinghua.edu.cn:digital-design-lab/project-template-xilinx.git
> git fetch upstream
> git merge upstream/master
```

或者，更简单地，直接：

```shell
> git pull git@git.tsinghua.edu.cn:digital-design-lab/project-template-xilinx.git master
```

!!! info "注意更新方式"

    用户对于自己的项目仓库没有 force push 权限，所以请不要使用 rebase 来合并上游更新，平时也不要随意修改已经 push 的 commit。如果出现问题，请自行查询并使用 `git reflog` 解决。

模板中的重要文件和目录包括：

* `project-template-xilinx.xpr`：Vivado 项目文件，可以在 Vivado 中通过 File → Project → Open... 打开
* `project-template-xilinx.srcs/constrs_1/new/io.xdc`：IO 管脚绑定约束
* `project-template-xilinx.srcs/sources_1/new/`：放置你编写的 RTL 代码
    * `mod_top.sv`：顶层模块，请根据需要取消信号列表中的注释，注意列表末尾的逗号
    * `dpy_scan.sv`：数码管扫描、译码模块
    * `led_scan.sv`：LED 扫描模块
    * `video.sv`：使用 VGA 时序驱动 HDMI 接口的样例
* `ip/`：用于放置 Quartus 生成的各类 IP
    * `pll`：预生成的 PLL 模块，用于从输入的 100M 时钟生成 50M 时钟提供给 VGA 模块

在新建文件时，你也应当遵循这一规范，合理放置文件。

### RTL 代码

推荐使用 SystemVerilog 语言编写项目，当然你可以自由选择任何 Vivado 支持的语言。简单的 SystemVerilog 介绍可见 [此课件](static/systemverilog.pdf)，需要注意你只能使用 SystemVerilog 中的 **可综合部分**。

!!! error "禁止使用坐标驱动图像输出"

    提供的 `mod_top.sv` 中使用了横纵坐标来计算出某个像素的颜色，请不要使用这种方法驱动复杂的渲染逻辑，否则将导致 **严重的时序问题**！

RTL 代码应该具有良好的风格，如规范的缩进、清晰的命名和恰当的注释。


### 管脚绑定约束

为了正确地使用外设，需要配置顶层模块的输入/输出信号对应的 FPGA 管脚，此部分内容都包含在 `io.xdc` 中。由于顶层模块中没有声明所有的信号，有部分约束被注释了，包括：

- PS/2 键盘和鼠标
- UART/RS232 串口
- DDR3 SDRAM
- BaseRAM（SRAM）
- 所有的 PMOD 接口
- 以太网 RGMI
- QSPI NOR Flash
- QSPI PSRAM
- SDCard 的 SD/SPI 模式

在使用时，请根据需要修改此文件，但 **不要随意修改管脚名**。

### IP 使用

Vivado 提供了丰富的 IP Core，你可以根据需要自由生成和选用（在 Vivado 的 IP Catalog 中选择）。一些常用的 IP Core 包括：

* RAM / ROM
* FIFO（用于时钟域同步或者任务队列）
* 各类 DSP（乘除法、开方、乘方、三角函数等数学运算）
* Tri Mode Ethernet MAC（用于驱动 RGMII 以太网 PHY）

在使用任何 IP 前，请 **完整阅读** 它的使用手册（通常 Vivado 自带，或可以从 Xilinx(AMD) 官网获取）。如果部分 IP 不包含在基础版本的 Vivado 软件中，请联系助教团队寻求帮助。

## 连接到 FPGA

将发给同学的 Xilinx Cable 的 USB 端插到电脑上，另一端插到实验板的 LAB_JTAG 上，就可以在 Vivado 中，点击 `Open Hardware Manager`，连接到 FPGA。检测到 FPGA 后，可以把编译出来的 bitstream 烧写到 FPGA 中，如果配置了 ILA，还可以使用 ILA 观察 FPGA 内部信号的状态。
