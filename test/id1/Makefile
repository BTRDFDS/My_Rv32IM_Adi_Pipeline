VERILATOR ?= verilator
SRC       := ../../src
INC       := -I$(SRC)
LINTFLAGS := -Wall -Wno-DECLFILENAME -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL
VFLAGS    := --binary --timing -Wno-fatal $(INC)
BUILD     := build

.PHONY: all lint top clean

# 一个模块只有一个测试、一个波形：build/wave/id1.fst
all: lint top

lint:
	$(VERILATOR) --lint-only $(LINTFLAGS) $(INC) --top-module Id1Full $(SRC)/id1.sv
	$(VERILATOR) --lint-only $(LINTFLAGS) $(INC) --top-module Id1Lite $(SRC)/id1.sv
	$(VERILATOR) --lint-only $(LINTFLAGS) $(INC) --top-module Id1     $(SRC)/id1.sv

$(BUILD):
	mkdir -p $(BUILD)

top: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --trace-fst --trace-structs --public-flat-rw --timescale "1ms/1ms" --top-module tb tb.sv $(SRC)/id1.sv --Mdir $(BUILD)/tb -o tb
	./$(BUILD)/tb/tb

clean:
	rm -rf $(BUILD)
