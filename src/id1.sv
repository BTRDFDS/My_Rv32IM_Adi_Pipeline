`include "interface.svh"
module Id1Full (
	input PackInstr in,
	output PackIdFull out
);
	always_comb unique0 case(in.instr) inside					//Id2Imm		,Ex3Res			,Ex1Bj		,Ex1Al		,Ex2Size		,r1,r2,rd,pc,im,lo,st,se
		32'b???????_?????_?????_???_?????_0110111:out=PackIdFull'{Id2Imm_U		,Ex3Res_Alu		,Ex1Bj_Null	,Ex1Al_Imm	,Ex2Size'('x)	,'0,'0,'1,'x,'x,'0,'0,'x};//LUI
		default									 :out=PackIdFull'{Id2Imm'('x)	,Ex3Res'('x)	,Ex1Bj'('x)	,Ex1Al'('x)	,Ex2Size'('x)	,'0,'0,'x,'x,'x,'0,'0,'x};//error
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
