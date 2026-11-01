`include "interface.svh"
module Id1Full (input PackInstr in);
	always_comb unique0 case(in.instr) inside
		
	endcase
endmodule
module Id1Lite();
endmodule
module Id1(
	input logic clk,rst,
	PipeIf2Id1.Id1 pipeIf2Id1
);
	PackInstr [1:0] data;
	always_ff @(posedge clk) data <= pipeIf2Id1.data;//TODO:ready
endmodule
