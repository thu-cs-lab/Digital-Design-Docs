# Vivado 使用

Vivado 是用于 Xilinx FPGA 的 EDA 开发工具。

## 下载安装

本实验使用的 EDA 软件为 Xilinx Viavdo 2019.2，安装过程可以参考 [数字逻辑实验课程的 Vivado 安装文档](https://lab.cs.tsinghua.edu.cn/digital-logic-lab/doc/vivado-install/)。请保证硬盘至少有 50GB 的可用空间。

!!! info "为什么不用新版本"

    Vivado 的新版本安装包体积急剧增长，动辄大几十 GB，而在线安装器又需要很长的时间下载，这给安装新版 Vivado 带来了极大的困扰。

    如果你觉得上述问题可以解决，可以和同组同学协商，一起更新到新版本。

## 工程模板

工程模板的仓库为 <https://git.tsinghua.edu.cn/digital-design-lab/project-template-xilinx>。我们为每个组在清华 GitLab 上创建了项目，仓库地址为 `https://git.tsinghua.edu.cn/digital-design-lab/2024-spring/digital-design-grp-XX`，其中 `XX` 为分配的组号。仓库中已经预置了最新的工程模板，通常可以直接使用。

工程模板还提供了一些外设的样例：

TODO

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

TODO

在新建文件时，你也应当遵循这一规范，合理放置文件。

### RTL 代码

推荐使用 SystemVerilog 语言编写项目，当然你可以自由选择任何 Vivado 支持的语言。简单的 SystemVerilog 介绍可见 [此课件](static/systemverilog.pdf)，需要注意你只能使用 SystemVerilog 中的 **可综合部分**。

!!! error "禁止使用坐标驱动图像输出"

    提供的 `mod_top.sv` 中使用了横纵坐标来计算出某个像素的颜色，请不要使用这种方法驱动复杂的渲染逻辑，否则将导致 **严重的时序问题**！

RTL 代码应该具有良好的风格，如规范的缩进、清晰的命名和恰当的注释。


### 管脚绑定约束

为了正确地使用外设，需要配置顶层模块的输入/输出信号对应的 FPGA 管脚，此部分内容都包含在 `io.xdc` 中。由于顶层模块中没有声明所有的信号，有部分约束被注释了，包括：

TODO

在使用时，请根据需要修改此文件，但 **不要随意修改管脚名**。

### IP 使用

TODO