VERILATOR ?= verilator
SRC       := ../../src
INC       := -I$(SRC)
VFLAGS    := --binary --timing -Wno-fatal $(INC)
BUILD     := build

.PHONY: all lint full lite top wave clean

all: lint full lite top

# 第一步：静态检查（三个顶层都过一遍）
lint:
	$(VERILATOR) --lint-only $(INC) --top-module Id1Full $(SRC)/id1.sv
	$(VERILATOR) --lint-only $(INC) --top-module Id1Lite $(SRC)/id1.sv
	$(VERILATOR) --lint-only $(INC) --top-module Id1     $(SRC)/id1.sv

$(BUILD):
	mkdir -p $(BUILD)

# 全通道译码：定向用例 + 随机指令的 X 检查
full: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --top-module tb_full tb_full.sv $(SRC)/id1.sv --Mdir $(BUILD)/full -o tb_full
	./$(BUILD)/full/tb_full

# 副通道译码：19 条白名单 + 随机指令
lite: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --top-module tb_lite tb_lite.sv $(SRC)/id1.sv --Mdir $(BUILD)/lite -o tb_lite
	./$(BUILD)/lite/tb_lite

# ID1 顶层：时钟、复位、ready 三态
top: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --top-module tb_top tb_top.sv $(SRC)/id1.sv --Mdir $(BUILD)/top -o tb_top
	./$(BUILD)/top/tb_top

# 波形：结构体字段可见（--trace-structs）
wave: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --trace-fst --trace-structs --public-flat-rw --timescale "1ms/1ms" --top-module tb_wave tb_wave.sv $(SRC)/id1.sv --Mdir $(BUILD)/wave -o tb_wave
	./$(BUILD)/wave/tb_wave
	@echo "波形: $(BUILD)/wave/wave.vcd"

clean:
	rm -rf $(BUILD)
