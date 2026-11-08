`include "interface.svh"
module Id1Full (
	input PackInstr in,
	output PackId1Full out
);
	always_comb unique0 case({in.valid,in.instr}) inside				//Id2Imm 	,r1,r2,rd ,pc,im,Ex1Bj		,Ex1Al		,Ex1Csr		,Ex2Size		,Ex3Res 	,aA,aB,fe,WbuCsrOp,v
		34'b01???????_?????_?????_???_?????_0110111:out=PackId1Full'{Id2Imm_U		,'0,'0,'1,'x,'x	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//LUI
		34'b01???????_?????_?????_???_?????_0010111:out=PackId1Full'{Id2Imm_U		,'0,'0,'1,'1,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//AUIPC
		34'b01???????_?????_?????_???_?????_1101111:out=PackId1Full'{Id2Imm_J		,'0,'0,'1,'1,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//JAL
		34'b01???????_?????_?????_000_?????_1100111:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//JALR
		34'b01???????_?????_?????_000_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Beq	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BEQ
		34'b01???????_?????_?????_001_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bne	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BNE
		34'b01???????_?????_?????_100_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Blt	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BLT
		34'b01???????_?????_?????_101_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bge	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BGE
		34'b01???????_?????_?????_110_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bltu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BLTU
		34'b01???????_?????_?????_111_?????_1100011:out=PackId1Full'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bgeu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//BGEU
		34'b01???????_?????_?????_000_?????_0000011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	,'1,in.pc};//LB
		34'b01???????_?????_?????_001_?????_0000011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	,'1,in.pc};//LH
		34'b01???????_?????_?????_010_?????_0000011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'0,'0,WbuCsrOp_Null	,'1,in.pc};//LW
		34'b01???????_?????_?????_100_?????_0000011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//LBU
		34'b01???????_?????_?????_101_?????_0000011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//LHU
		34'b01???????_?????_?????_000_?????_0100011:out=PackId1Full'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	,'1,in.pc};//SB
		34'b01???????_?????_?????_001_?????_0100011:out=PackId1Full'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	,'1,in.pc};//SH
		34'b01???????_?????_?????_010_?????_0100011:out=PackId1Full'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	,'1,in.pc};//SW
		34'b01???????_?????_?????_000_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//ADDI
		34'b01???????_?????_?????_010_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLTI
		34'b01???????_?????_?????_011_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLTIU
		34'b01???????_?????_?????_100_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//XORI
		34'b01???????_?????_?????_110_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//ORI
		34'b01???????_?????_?????_111_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//ANDI
		34'b010000000_?????_?????_001_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLLI
		34'b010000000_?????_?????_101_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SRLI
		34'b010100000_?????_?????_101_?????_0010011:out=PackId1Full'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SRAI
		34'b010000000_?????_?????_000_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//ADD
		34'b010100000_?????_?????_000_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sub	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SUB
		34'b010000000_?????_?????_001_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLL
		34'b010000000_?????_?????_010_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLT
		34'b010000000_?????_?????_011_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SLTU
		34'b010000000_?????_?????_100_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//XOR
		34'b010000000_?????_?????_101_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SRL
		34'b010100000_?????_?????_101_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//SRA
		34'b010000000_?????_?????_110_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//OR
		34'b010000000_?????_?????_111_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//AND
		34'b010000001_?????_?????_000_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mul	,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//MUL
		34'b010000001_?????_?????_001_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'1,'0,WbuCsrOp_Null	,'1,in.pc};//MULH
		34'b010000001_?????_?????_010_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'0,'0,WbuCsrOp_Null	,'1,in.pc};//MULHSU
		34'b010000001_?????_?????_011_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//MULHU
		34'b010000001_?????_?????_100_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'1,'1,'0,WbuCsrOp_Null	,'1,in.pc};//DIV
		34'b010000001_?????_?????_101_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//DIVU
		34'b010000001_?????_?????_110_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'1,'1,'0,WbuCsrOp_Null	,'1,in.pc};//REM
		34'b010000001_?????_?????_111_?????_0110011:out=PackId1Full'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'0,'0,'0,WbuCsrOp_Null	,'1,in.pc};//REMU
		34'b01???????_?????_?????_000_?????_0001111:out=PackId1Full'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	,'1,in.pc};//FENCE
		34'b01???????_?????_?????_001_?????_0001111:out=PackId1Full'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'1,WbuCsrOp_Null	,'1,in.pc};//FENCE.I
		34'b010000000_00000_00000_000_00000_1110011:out=PackId1Full'{Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'0,'0,WbuCsrOp_Trap	,'1,in.pc};//ECALL
		34'b010000000_00001_00000_000_00000_1110011:out=PackId1Full'{Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	,'1,in.pc};//EBREAK
		34'b010011000_00010_00000_000_00000_1110011:out=PackId1Full'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Ret	,'1,in.pc};//MRET
		34'b01???????_?????_?????_001_?????_1110011:out=PackId1Full'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRW
		34'b01???????_?????_?????_010_?????_1110011:out=PackId1Full'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRS
		34'b01???????_?????_?????_011_?????_1110011:out=PackId1Full'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRC
		34'b01???????_?????_?????_101_?????_1110011:out=PackId1Full'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRWI
		34'b01???????_?????_?????_110_?????_1110011:out=PackId1Full'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRSI
		34'b01???????_?????_?????_111_?????_1110011:out=PackId1Full'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write,'1,in.pc};//CSRRCI
		34'b00???????_?????_?????_???_?????_???????:out=PackId1Full'{Id2Imm'('x)	,'x,'x,'x,'x,'x	,Ex1Bj'('x)	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res'('x),'x,'x,'x,WbuCsrOp'('x)	,'0,in.pc};//idle
		34'b10???????_?????_?????_???_?????_???????:out=PackId1Full'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	,'1,in.pc};//fall
		34'b11???????_?????_?????_???_?????_???????:out=PackId1Full'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	,'1,in.pc};//un4b
		default									   :out=PackId1Full'{Id2Imm_E		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'1,'0,'0,WbuCsrOp_Trap	,'1,in.pc};//illegal
	endcase
endmodule
module Id1Lite(
	input PackInstr in,
	output PackId1Lite out
);
endmodule
module Id1(
	input logic clk,rst,
	PipeIf2Id1.Id1 pipeIf2Id1
);
	PackInstr [1:0] data;
	always_ff @(posedge clk) data <= pipeIf2Id1.data;//TODO:ready
endmodule
