# Quartus 使用

Quartus 是用于 Intel FPGA 的 EDA 开发工具。

## 下载安装

本实验使用的 EDA 软件为 Intel Quartus Prime Lite Edition，由于 20.1.1 版本存在一个 [bug](https://community.intel.com/t5/Intel-Quartus-Prime-Software/Error-suppressible-vsim-12110-The-novopt-option-has-no-effect-on/td-p/1195522)，我们建议下载 19.1 版本。同时需要安装 Cyclone IV 器件支持，以及 ModelSim IntelFPGA Starter Edition 仿真器，用于实验过程中的仿真。请保证硬盘至少有 50GB 的可用空间。

!!! info "为什么不用新版本"

    Quartus 从 21.1 版本开始，仿真器从 ModelSim 换成了 Questa，前者不需要 License 就可以使用，后者需要在 Intel 官网上注册，虽然也是免费，但是增加了学习成本。Quartus 20.1.1 又有 BUG，虽然可以解决，但是修改起来比较麻烦。最后就决定采用 19.1 版本。

    如果你觉得上述问题可以解决，可以和同组同学协商，一起更新到新版本。

Quartus 文档可以从 [Intel® Quartus® Prime Pro and Standard Software User Guides](https://www.intel.com/content/www/us/en/support/programmable/support-resources/design-software/user-guides.html) 下载。

## 工程模板

<!-- 请从 [此处](static/digital-design-template.zip) 下载工程模板。解压后即可导入 Quartus 中，通常不需要更改任何设置即可使用。 -->

工程模板的仓库为 <https://git.tsinghua.edu.cn/digital-design-lab/project-template>。我们为每个组在清华 GitLab 上创建了项目，仓库地址为 `https://git.tsinghua.edu.cn/digital-design-lab/2023-spring/digital-design-grp-XX`，其中 `XX` 为分配的组号。仓库中已经预置了最新的工程模板，通常可以直接使用。

工程模板还提供了一些外设的样例：

- [ethernet](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/ethernet): 以太网 IP，收到的数据求和后显示在数码管上
- [ps2_keyboard](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/ps2_keyboard): PS/2 键盘，敲击键盘，键盘的 scancode 会显示在数码管上
- [ps2_mouse](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/ps2_mouse): PS/2 鼠标，数码管上会显示 XY 坐标和鼠标按键状态
- [sdcard](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/sdcard): SD 卡，读取 SD 卡的第一个扇区的内容，滚动显示在数码管上
- [sram](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/sram): SRAM，添加了 SRAM 仿真模型，没有附带 SRAM 控制器，在实验板子上不会有任何输出；可以在这个项目的基础上，测试自己编写的 SRAM 控制器代码
- [i2c](https://git.tsinghua.edu.cn/digital-design-lab/project-template/-/tree/i2c): 只实现了针对 WM8731 的 I2C 写入，没有处理 ACK；可以在这个项目的的基础上，修改引脚定义（`io.tcl`），修改写入的寄存器（`i2c.sv`），添加 ACK 判断等等

工程模板还提供了仿真脚本，用于在 Linux 命令行中运行仿真器：ModelSim 仿真脚本 `sim_modelsim.sh`，Vivado 仿真脚本 `sim_vivado.sh` 和 Icarus Verilog 仿真脚本 `sim_icarus.sh`。使用前，需要按照本地的安装路径修改脚本。

!!! success "必须使用 Git"
    
    课程强制使用 Git 进行版本控制管理，而不是使用微信交换文件。助教提供的 `.gitignore` 文件可直接使用，用来忽略 Quartus 生成的中间文件。

如果原始框架代码有更新（届时会通过多种渠道通知），你可以如下合并这些更新：

```shell
> git remote add upstream git@git.tsinghua.edu.cn:digital-design-lab/project-template.git
> git fetch upstream
> git merge upstream/master
```

或者，更简单地，直接：

```shell
> git pull git@git.tsinghua.edu.cn:digital-design-lab/project-template.git master
```

!!! info "注意更新方式"

    用户对于自己的项目仓库没有 force push 权限，所以请不要使用 rebase 来合并上游更新，平时也不要随意修改已经 push 的 commit。如果出现问题，请自行查询并使用 `git reflog` 解决。

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
