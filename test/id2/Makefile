VERILATOR ?= verilator
SRC       := ../../src
INC       := -I$(SRC)
LINTFLAGS := -Wall -Wno-DECLFILENAME -Wno-UNDRIVEN -Wno-UNUSEDSIGNAL
VFLAGS    := --binary --timing -Wno-fatal $(INC)
BUILD     := build

.PHONY: all lint top clean

# 一个模块只有一个测试、一个波形：build/wave/id2.fst
all: lint top

lint:
	$(VERILATOR) --lint-only $(LINTFLAGS) $(INC) --top-module Id2 $(SRC)/id2.sv
	$(VERILATOR) --lint-only --timing -Wall -Wno-DECLFILENAME -Wno-PROCASSINIT -Wno-BLKSEQ -Wno-UNUSEDSIGNAL $(INC) --top-module tb tb.sv $(SRC)/id2.sv


$(BUILD):
	mkdir -p $(BUILD)

top: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --trace-fst --trace-structs --public-flat-rw --timescale "1ms/1ms" --top-module tb tb.sv $(SRC)/id2.sv --Mdir $(BUILD)/tb -o tb
	./$(BUILD)/tb/tb

clean:
	rm -rf $(BUILD)
