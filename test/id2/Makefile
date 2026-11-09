VERILATOR ?= verilator
SRC       := ../../src
INC       := -I$(SRC)
VFLAGS    := --binary --timing -Wno-fatal $(INC)
BUILD     := build

.PHONY: all lint top clean

all: lint top

lint:
	$(VERILATOR) --lint-only $(INC) --top-module Id2 $(SRC)/id2.sv

$(BUILD):
	mkdir -p $(BUILD)

top: | $(BUILD)
	$(VERILATOR) $(VFLAGS) --top-module tb_id2 tb_id2.sv $(SRC)/id2.sv --Mdir $(BUILD)/tb_id2 -o tb_id2
	./$(BUILD)/tb_id2/tb_id2

clean:
	rm -rf $(BUILD)
