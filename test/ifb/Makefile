VERILATOR ?= verilator
SRC       := ../../src
INC       := -I$(SRC)
LINTFLAGS := -Wall -Wno-DECLFILENAME -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL
VFLAGS    := --binary --timing -Wno-fatal $(INC)
BUILD     := build

.PHONY: all lint top clean

# 一个模块只有一个测试、一个波形：build/wave/ifb.fst
all: lint top

lint:
	$(VERILATOR) --lint-only $(LINTFLAGS) $(INC) --top-module ifb $(SRC)/ifb.sv

$(BUILD):
	mkdir -p $(BUILD)

top: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --trace-fst --trace-structs --public-flat-rw --timescale "1ms/1ms" --top-module tb tb.sv $(SRC)/ifb.sv --Mdir $(BUILD)/tb -o tb
	./$(BUILD)/tb/tb

clean:
	rm -rf $(BUILD)
