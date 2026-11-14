# AI_readme —— 项目上下文与工作约定

> 本文件是给"下一次对话的 AI 助手"看的**唯一入口文档**：先读完它，再动任何代码。
> 它随 git 记录，并会随仓库一起迁移到 Windows 工作区。
> 维护规则：进度、决定、约定有变化时更新本文件；不要让它变成流水账。

---

## 1. 项目定位

- **名称**：`myRv32_adi_p9`（WSL 路径 `/home/biruide/myRv32_adi_p9`，计划迁往 Windows，见 §8）。
- **性质**：**竞业达杯的预研制**，不是教学 CPU。目标频率 **200~250 MHz**。
- **ISA**：RV32IM + Zicsr，顺序、**非对称双发射**。
- **语言**：SystemVerilog（项目长期主语言；远期计划把最复杂的 decoder 改成 Chisel `DecodeTable` 生成，见 §5.6）。
- **仿真**：Verilator 5.040（不使用 iverilog，理由见 §6.2）。
- **波形**：FST（`--trace-fst --trace-structs`），时钟 `--timescale "1ms/1ms"`，周期 10ms、复位 20ms，时间都是整数 ms。

## 2. 流水线结构（当前共识）

```
IF1 (取指 + BPU/BTB) → IF2 → IF3 (IFB) → ID1 → ID2 → EX1 → EX2 → EX3 → WB
```

- **9 级，无 MEM 级**；访存拆在 EX2/EX3（用户通常把访存单元叫 LSU）。
- **非对称双发射**：
  - **full 通道**：全部指令（含分支、CSR、自陷、load/store、乘除）。
  - **lite 通道**：只有 19 条白名单 ALU 指令（I 型 9 条 + R 型 10 条：ADDI/SLTI/SLTIU/XORI/ORI/ANDI/SLLI/SRLI/SRAI + ADD/SUB/SLL/SLT/SLTU/XOR/SRL/SRA/OR/AND）。
  - **只有 full 通道会出现跳转/CSR/自陷**——这是非对称结构的核心简化，分析 BP、冲刷、异常时必须记住。
- **EX1**：ALU0/ALU1、分支与跳转判定（比较 + 目标计算）、乘法发射。
- **EX2**：可变周期等待（乘、除、访存发起/返回握手）。
- **EX3**：结果选择、乘法 CPA（当前设计正在被重新考虑，见 §5.5）。
- **WB**：WBU（GPR 写回、旁路数据）。

## 3. 当前进度（截至本文件创建时）

### 3.1 已完成的模块（`src/`）

| 文件 | 内容 | 状态 |
|---|---|---|
| `enum.svh` | 全部枚举（Id1Valid、Id1Ready、Id2Imm、Ex1Al、Ex1Bj、Ex1Csr、Ex3Res、WbuCsrOp 等） | 稳定 |
| `struct.svh` | 全部 packed struct（PackInstr、PipeInstr、PackId1Full/Lite、PackId2Full/Lite、PackData、PackSr…） | 稳定 |
| `interface.svh` | `PipeIf2Ifb` / `PipeIfbId1` / `PipeId1Id2` / `PipeId2Ex1` / `pipeWb` / `ImmeData` | 随 BP 需求还会加字段，见 §5.4 |
| `id1.sv` | `Id1Full`（主译码，`unique0 case inside`，34 位模式）、`Id1Lite`（19 条白名单）、`Id1`（两槽 pipeReg + 对齐） | **通过全部测试** |
| `id2.sv` | `Id2`：PRF 读地址、r1/r2 有效性与旁路选择、立即数生成、`csrAddr = id1Full.instr[31:20]`、lite 依赖 full、内部分半包寄存器、flush | **通过全部测试** |
| `ifb.sv` | `ifb`：8 条目 FIFO、每拍 2 写 2 读、consume 钳位、flush、`if2.ready` | **通过全部测试** |
| `wbu.sv` | `wbu`：GPR 写回（x0 不写）、旁路 hit/data；`dataGprs.sr` 还没定索引方式（TODO） | 初稿 |
| `ex1.sv` | **空文件（0 字节）**，下一步要写 | 待实现 |

### 3.2 测试（`test/`）

- `test/id1`、`test/id2`、`test/ifb` 各一个 `Makefile` + 一个 `tb.sv`。
- **当前三个 `make all` 全部通过**：
  ```
  test/id1   tb: OK（build/wave/id1.fst）
  test/id2   tb: OK（build/wave/id2.fst）
  test/ifb   tb: OK（build/wave/ifb.fst）
  ```
- 每个 `make all` = **lint（两条：模块级 + tb 级联合 lint）+ 编译仿真 + 生成 FST**。
- 失败即 `$fatal`，make 退出码 2；失败信息带时间、phase、期望/实际、DUT 内部真实信号。

### 3.3 git 状态

- 单分支 `master`，**无远程**（迁移时会推到 GitHub 中转，见 §8）。
- 23 个提交；历史里有"对齐由 ID1 负责""IFB 初步完工""添加 flush"等关键节点。
- 当前暂存区：`src/ex1.sv`（空占位）、`src/wbu.sv`（修改）。
- 未跟踪：`refer/`（参考核 VeeR EH2、OpenC906 的 clone，75MB，**不进主仓库**）。

## 4. 已定的关键协议

### 4.1 ID1 ↔ IFB：`consume` 编码

ID1 拥有两槽 pipeReg，**对齐由 ID1 负责**（不是 IFB）。`PipeIfbId1.consume[1:0]`：

```systemverilog
empty    = (instr[0].valid==Idle && instr[1].valid==Idle);
leftover = (instr[1].valid!=Idle) && !id2.dataLite.valid;   // 槽1 被白名单拦截
pipeReady      = empty || id2.ready;
consume[0]     = pipeReady;                                  // 这一拍至少收 1 条
consume[1]     = empty || (id2.ready && !leftover);          // 收一对新的
```

- 编码：`00`=不动，`01`=前进 1（槽1 上移到槽0），`11`=前进 2；`10` 不可能出现。
- **装入 mux 用 `consume[1]` 选**：`consume[1]=1` 时装 `ifb.instr[0]/[1]`，否则槽0←旧槽1、槽1←ifb.instr[0]。
- **不变量**：ID1 这一拍装入的新条目数 == IFB 读指针前进数。
- **空寄存器必须预取**：`empty` 时发 r2 让 IFB 前进，否则同一对会被再次装入导致重复。

### 4.2 IFB

- 8 条目环形 FIFO，每拍写 2、读 2。
- `consume` 只是上限，IFB 用本地有效条目数钳位（`have1/have2`）。
- 结构不变量：**不可能出现"槽0 Idle、槽1 valid"**（写侧连续、读指针只前进、冲刷整体清空）。
- 冲刷链：`ex1.flush` → Id2（清内部寄存器）→ `id1.flush` → Id1（清两槽）→ `ifb.flush` → ifb（清 FIFO 与输入寄存器）→ `if2.flush`。
- `if2.ready = pipeReady`；FIFO 满时寄存器必须保持、不能覆盖。

### 4.3 译码器

- `Id1Full` 用 `unique0 case ({in.valid,in.data.instr}) inside`，34 位通配模式（`?` 为通配）。
- `Id1Lite` 白名单 19 条；不在白名单或非法指令一律 `valid=0`。
- 已覆盖的边界：`SLLI` 的 `instr[25]=1`（shamt[5]=1）判非法；`SLLI` funct7=0100000 判非法。

### 4.4 分支预测（**设计中，尚未实现**）

- 目标：IF1 里的 BPU，分区 BTB：
  - **分支 16 项**（4 组 × 4 路为远期；**当前先做全相联**，怎么方便怎么来），条目 = `{pc, target, ctr[1:0]}`（2-bit 计数器放进条目）。
  - **JAL 4~8 项**，**JALR 4~8 项**（JALR 含函数返回，别给 4 太小）。
  - **RAS v1 不做**。
  - 替换：分区内轮转；更新时"重复优先覆盖"（先搜 PC，命中就覆盖，否则写轮转指针）。
- 预测"命中即跳"：`taken = jal_hit || jalr_hit || (br_hit && ctr[1])`。
- **预测结果随指令携带**：`pred_taken`(1) + `pred_target`(30)，从 IF1 经 IF2/IFB/ID1/ID2 到 EX1。建议塞进 `PipeInstr`（加 `PackPred`），这样 IFB 条目和各接口自动带上。
- **取指每拍 2 条**：必须查 PC 和 PC+4 两次；`next_pc = taken0 ? tgt0 : (taken1 ? tgt1 : PC+8)`；**`taken0` 时 `ifb.instr[1].valid` 必须清掉**（错误路径不进 IFB），且与 PC 更新同拍同源。
- **EX1 → BPU 上行**：新建 `PipeEx1Bpu`（或在 `PipeId2Ex1` 的 `Ex1` modport 加信号）：`we / typ[1:0] / pc / target / taken / mispredict / redirect`。
  - `typ` 由 `data.bj` + `data.imm` 推出：`Jump && imm==J` → JAL；`Jump && imm==I` → JALR；其余 bj → 条件分支。
- 只有 full 通道有分支 → **BTB 只需一个写口**；`kill_slot1` 仍需要（slot0 taken 时同组 lite 是错误路径）。

### 4.5 乘法（**方案讨论中，用户会自己写代码后再定**）

- 用户反对"在飞计数/issued 位"，主张像普通流水控制一样：发射门控 + 暂停机制。
- 关键正确性条件：**MUL 只有在下一拍能进入 EX2（等待槽）时才发射**；否则 LW 占着 EX2 时发射，结果回来无处可接会丢失。
- 乘法单元独立流水（Vivado 实测 32 位 U32×U32：32 个部分积 + 4 级 CSA，200~250MHz 需要逐级流水）。
- 计划把 9 级压到 8 级（EX1 发射 + EX2 等待，去掉 EX3 的乘法 CPA 职责）。
- **用户说"你没理解我的乘法器设计思路，等代码写完你就明白了"——不要擅自替他设计，等代码。**

### 4.6 WBU

- GPR 写回：`valid && addr!=0`；x0 不写。
- 旁路：`hit[i][j] = addr[i][j]==rd[j].addr`，`r1/r2` 直接读 GPR。
- 未决：`immeData.dataGprs.sr` 的索引方式（TODO 注释在 `src/wbu.sv`）。

## 5. 测试与工具链约定

### 5.1 测试结构（硬性约定）

- **一个模块 = 一个 `tb.sv` = 一个 FST 波形 = 一个 `make all`**。
- **遇到第一个错误立即 `$fatal`**，不带着错误继续。
- 失败信息必须含：时间、phase、期望值、实际值、DUT 真实内部信号（不是测试平台模型值）。
- 场景用 `phase` 编号；测试结尾打印 `tb: OK（波形 build/wave/<mod>.fst）` 或 `N FAIL`。
- 波形必须带枚举名（FST 才行，VCD 没有类型系统）。
- 测试平台可以使用 verilator 独有特性；不需要为了 iverilog 妥协。

### 5.2 lint（硬性约定）

每个 `Makefile` 的 `lint` 目标跑两条：

```make
# 1) 模块级：抓 RTL 自身问题（BLKSEQ、LATCH、WIDTH、CASE…）
verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL \
          -I../../src --top-module <Mod> ../../src/<mod>.sv
# 2) tb 级联合 lint：输入都由 tb 驱动，抓"输出未驱动"（csrAddr 就是这么漏的）
verilator --lint-only --timing -Wall -Wno-DECLFILENAME -Wno-PROCASSINIT \
          -Wno-BLKSEQ -Wno-UNUSEDSIGNAL -I../../src --top-module tb tb.sv ../../src/<mod>.sv
```

- 不加 `-Wno-fatal`：Verilator 默认**警告即错误**。
- 刻意保留的检查：曾用 `ifb.sv:33` 的 BLKSEQ 验证 lint 能拦住（已修）。

### 5.3 Verilator 的事实（踩过的坑）

- **Verilator 是两态仿真**：未驱动信号是 0 不是 X → 运行时 `$isunknown` 抓不到漏驱动，**只能靠 tb 级联合 lint**。
- `case inside` 在 Verilator 5.040 支持（`?` 通配、`[a:b]` 区间都试过）。
- Verilator 的 `--trace-structs` 才能展开 struct；FST 才能保留枚举表。

### 5.4 yosys / 其他综合器的事实（实测）

- **yosys 0.59 完全不支持 `case inside`**（连 `4'd1` 都报 "Cast operation must be applied on sized constants"；`inside` 运算符也不支持）。`casez` 正常。
- **Quartus 官方文档明确不支持 `case inside`**（11.4.13 / 12.5.4）。
- **Vivado 版本相关**（社区有 "Support for case inside" 与 "Incorrect synthesis for case inside" 两类帖子）。
- 结论：如果以后要走 yosys，`case inside` 必须换成 `casez`；当前先不改（用户决定，见 §5.6）。

### 5.5 工具链

- WSL 里有 `verilator 5.040`、`yosys 0.59`、`git`、`python3`。
- Windows 侧：Vivado ML Standard 2023.2，安装在 `C:\application\Xilinx`；`pwsh` 受限模式因工作区在 WSL UNC 路径上会报 `GetNamedSecurityInfoW failed`（迁移到 Windows 路径后应消失）。
- `npx` 在 Windows 上不可用；需要 node 时用 `C:\Users\Dr.B\AppData\Roaming\dsh-desktop\harness\.desktop-bin\node.cmd`。

### 5.6 decoder 迁移计划（用户决定）

- **当前不改** `case inside`；过一段时间改成 **Chisel `DecodeTable` 生成的 decoder**。
- 参考：`/home/biruide/ysyx-workbench/npc/src/cpu/idu.scala`（`chisel3.util.experimental.decode`，生成 PLA：`decoder_invInputs` / `andMatrix` / `orMatrix`，产物是纯门级，yosys 能吃）。
- 迁移时要做的验证：生成版 vs 手写版**逐条等价检查**（定向全指令 + 20 万随机）。

## 6. 工作方式约定（给 AI 助手）

1. **`src/` 归用户**：助手**只能改 `test/`**。要动 `src/` 必须先问，得到明确同意再动（历史上有过未经许可改 `src/id1.sv` 被严厉批评的教训）。
2. **不替用户做微架构决定**：可以分析、给建议、指出风险，但最终方案由用户定。
3. **术语要精确**：避免"打一拍""反压""唤醒"这类不精确说法；描述寄存器、时钟沿、组合路径。
4. **先验证再汇报**：任何结论（波形、综合、lint、测试结果）都要有实际命令输出支撑，不能凭记忆断言。
5. **不要泛泛谈"可移植性"**：以用户实际要用的工具为准（Verilator 支持、yosys 不支持、Quartus 不支持是实测/官方文档结论）。
6. **测试失败信息要具体**：时间、phase、哪条指令、缺哪条、DUT 哪个信号。
7. **用户偏好"先实现优先、怎么方便怎么来"**：BTB 先全相联，组相联后续；RAS 暂不做；不要为了"完美"拖慢进度。
8. **回答用中文**；代码注释可用中文；风格紧凑对齐。

## 7. 已知风险 / 未决问题

1. **Vivado 对 SV interface + modport 的支持**：迁移后第一件事做烟测（最小 interface 例子综合），失败则要一条"interface 展开成扁平端口"的退路。
2. `wbu.sv` 的 `dataGprs.sr` 索引未定。
3. 乘法流水线与指令流水级的解耦方案待用户代码落地。
4. BP 的 `pred_taken/pred_target` 携带成本（31 bit/条目）与 `PipeInstr` 加字段的改动面。
5. `ex1.sv` 目前是空文件，分支判定/目标计算/BTB 更新/乘法发射都在里面。

## 8. 迁移到 Windows（计划）

- **方式**：GitHub 私有仓库中转（不是直接拷贝），保留全部提交历史。
- **管理原则**：**仓库是源码的唯一来源，Vivado 只当工具**。
  - 不提交 `.xpr` / `.runs` / `.cache` / `.gen` / `.ip_user_files` / `.dcp` / `.bit`（工程是"机器状态"，不是源码；提交它会让队友克隆后打不开）。
  - 采用**非工程流（Tcl）**：`fpga/files.f` + `fpga/constraints.xdc` + `fpga/synth.tcl`，`vivado -mode batch -source synth.tcl`；需要 GUI 时 `open_checkpoint` 或跑一次 `create_project.tcl`（由 `write_project_tcl` 生成）。
- **`.gitignore` 至少含**：`*.xpr`、`*.runs/`、`*.cache/`、`*.gen/`、`*.ip_user_files/`、`*.sim/`、`*.hw/`、`.Xil/`、`*.dcp`、`*.bit`、`*.ltx`、`*.jou`、`*.log`、`test/*/build/`、`fpga/project/`、`fpga/build/`。
- **换行符**：两边 `git config core.autocrlf false`。
- **WSL 仍用于 Verilator/yosys**（`/mnt/d/work/...`），Vivado 在 Windows 本地跑。
- **`refer/`（75MB）不进主仓库**，单独放或 submodule。

## 9. 快速上手

```bash
# 仿真（WSL）
cd test/id1 && make all     # lint + 仿真 + 波形 build/wave/id1.fst
cd test/id2 && make all
cd test/ifb && make all

# 看波形（需要 wavepeek）
wavepeek info --waves test/id1/build/wave/id1.fst
wavepeek value --waves test/id1/build/wave/id1.fst --at 150ms \
    --signals tb.phase,tb.ifb.consume,tb.dbg_v0
```

## 10. 当前优先级（下一步）

1. **EX1**：分支判定（比较 + 目标）、`flush` 产生、`kill_slot1`、乘法发射门控、BTB 更新输出。
2. **BPU（IF1）**：分区 BTB（分支 16/全相联 + ctr，JAL 8，JALR 8）、两读口、更新写口、重定向。
3. 迁移到 Windows + Vivado 非工程流 + interface 烟测。
4. EX2/EX3：乘除、访存（xbar）握手、结果选择。
5. WBU/CSR/PRF 收尾，跑通第一条完整指令。

---

*最后更新：2026-11-14，随本次对话整理。*
