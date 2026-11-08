`include "interface.svh"
module Id1Full (
	input PackInstr in,
	output PackId1Full out
);
	always_comb unique0 case({in.valid,in.instr}) inside		//	valid	,Id2Imm 	,r1,r2,rd ,pc,im,Ex1Bj		,Ex1Al		,Ex1Csr		,Ex2Size		,Ex3Res 	,aA,aB,fe,WbuCsrOp,v
		34'b01???????_?????_?????_???_?????_0110111:out=PackId1Full'{'1,in.pc,Id2Imm_U		,'0,'0,'1,'x,'x	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//LUI
		34'b01???????_?????_?????_???_?????_0010111:out=PackId1Full'{'1,in.pc,Id2Imm_U		,'0,'0,'1,'1,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//AUIPC
		34'b01???????_?????_?????_???_?????_1101111:out=PackId1Full'{'1,in.pc,Id2Imm_J		,'0,'0,'1,'1,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//JAL
		34'b01???????_?????_?????_000_?????_1100111:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//JALR
		34'b01???????_?????_?????_000_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Beq	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BEQ
		34'b01???????_?????_?????_001_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bne	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BNE
		34'b01???????_?????_?????_100_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Blt	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BLT
		34'b01???????_?????_?????_101_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bge	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BGE
		34'b01???????_?????_?????_110_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bltu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BLTU
		34'b01???????_?????_?????_111_?????_1100011:out=PackId1Full'{'1,in.pc,Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bgeu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BGEU
		34'b01???????_?????_?????_000_?????_0000011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	};//LB
		34'b01???????_?????_?????_001_?????_0000011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	};//LH
		34'b01???????_?????_?????_010_?????_0000011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'0,'0,WbuCsrOp_Null	};//LW
		34'b01???????_?????_?????_100_?????_0000011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	};//LBU
		34'b01???????_?????_?????_101_?????_0000011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	};//LHU
		34'b01???????_?????_?????_000_?????_0100011:out=PackId1Full'{'1,in.pc,Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SB
		34'b01???????_?????_?????_001_?????_0100011:out=PackId1Full'{'1,in.pc,Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SH
		34'b01???????_?????_?????_010_?????_0100011:out=PackId1Full'{'1,in.pc,Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SW
		34'b01???????_?????_?????_000_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ADDI
		34'b01???????_?????_?????_010_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTI
		34'b01???????_?????_?????_011_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTIU
		34'b01???????_?????_?????_100_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//XORI
		34'b01???????_?????_?????_110_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ORI
		34'b01???????_?????_?????_111_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ANDI
		34'b010000000_?????_?????_001_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLLI
		34'b010000000_?????_?????_101_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRLI
		34'b010100000_?????_?????_101_?????_0010011:out=PackId1Full'{'1,in.pc,Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRAI
		34'b010000000_?????_?????_000_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ADD
		34'b010100000_?????_?????_000_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sub	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SUB
		34'b010000000_?????_?????_001_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLL
		34'b010000000_?????_?????_010_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLT
		34'b010000000_?????_?????_011_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTU
		34'b010000000_?????_?????_100_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//XOR
		34'b010000000_?????_?????_101_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRL
		34'b010100000_?????_?????_101_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRA
		34'b010000000_?????_?????_110_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//OR
		34'b010000000_?????_?????_111_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//AND
		34'b010000001_?????_?????_000_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mul	,'0,'0,'0,WbuCsrOp_Null	};//MUL
		34'b010000001_?????_?????_001_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'1,'0,WbuCsrOp_Null	};//MULH
		34'b010000001_?????_?????_010_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'0,'0,WbuCsrOp_Null	};//MULHSU
		34'b010000001_?????_?????_011_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'0,'0,'0,WbuCsrOp_Null	};//MULHU
		34'b010000001_?????_?????_100_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'1,'1,'0,WbuCsrOp_Null	};//DIV
		34'b010000001_?????_?????_101_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'0,'0,'0,WbuCsrOp_Null	};//DIVU
		34'b010000001_?????_?????_110_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'1,'1,'0,WbuCsrOp_Null	};//REM
		34'b010000001_?????_?????_111_?????_0110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'0,'0,'0,WbuCsrOp_Null	};//REMU
		34'b01???????_?????_?????_000_?????_0001111:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//FENCE
		34'b01???????_?????_?????_001_?????_0001111:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'1,WbuCsrOp_Null	};//FENCE.I
		34'b010000000_00000_00000_000_00000_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'0,'0,WbuCsrOp_Trap	};//ECALL
		34'b010000000_00001_00000_000_00000_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	};//EBREAK
		34'b010011000_00010_00000_000_00000_1110011:out=PackId1Full'{'1,in.pc,Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Ret	};//MRET
		34'b01???????_?????_?????_001_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRW
		34'b01???????_?????_?????_010_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRS
		34'b01???????_?????_?????_011_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRC
		34'b01???????_?????_?????_101_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRWI
		34'b01???????_?????_?????_110_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRSI
		34'b01???????_?????_?????_111_?????_1110011:out=PackId1Full'{'1,in.pc,Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRCI
		34'b00???????_?????_?????_???_?????_???????:out=PackId1Full'{'0,in.pc,Id2Imm'('x)	,'x,'x,'x,'x,'x	,Ex1Bj'('x)	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res'('x),'x,'x,'x,WbuCsrOp'('x)	};//idle
		34'b10???????_?????_?????_???_?????_???????:out=PackId1Full'{'1,in.pc,Id2Imm_E		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	};//fall
		34'b11???????_?????_?????_???_?????_???????:out=PackId1Full'{'1,in.pc,Id2Imm_E		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	};//un4b
		default									   :out=PackId1Full'{'1,in.pc,Id2Imm_E		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'1,'0,'0,WbuCsrOp_Trap	};//illegal
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
