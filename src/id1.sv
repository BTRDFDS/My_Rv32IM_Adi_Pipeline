`include "interface.svh"
module Id1Full (
	input PackInstr in,
	output PackIdFull out
);
	always_comb unique0 case(in.instr) inside					//Id2Imm 		,r1,r2,rd ,pc,im,Ex1Bj		,Ex1Al		,Ex1Csr		,Ex2Size		,Ex3Res 	,aA,aB,fe,WbuCsrOp
		32'b???????_?????_?????_???_?????_0110111:out=PackIdFull'{Id2Imm_U		,'0,'0,'1,'x,'x	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//LUI
		32'b???????_?????_?????_???_?????_0010111:out=PackIdFull'{Id2Imm_U		,'0,'0,'1,'1,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//AUIPC
		32'b???????_?????_?????_???_?????_1101111:out=PackIdFull'{Id2Imm_J		,'0,'0,'1,'1,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//JAL
		32'b???????_?????_?????_000_?????_1100111:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Jump	,Ex1Al_Npc	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//JALR
		32'b???????_?????_?????_000_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Beq	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BEQ
		32'b???????_?????_?????_001_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bne	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BNE
		32'b???????_?????_?????_100_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Blt	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BLT
		32'b???????_?????_?????_101_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bge	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BGE
		32'b???????_?????_?????_110_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bltu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BLTU
		32'b???????_?????_?????_111_?????_1100011:out=PackIdFull'{Id2Imm_B		,'1,'1,'0,'1,'1	,Ex1Bj_Bgeu	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//BGEU
		32'b???????_?????_?????_000_?????_0000011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	};//LB
		32'b???????_?????_?????_001_?????_0000011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'1,'0,'0,WbuCsrOp_Null	};//LH
		32'b???????_?????_?????_010_?????_0000011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'0,'0,WbuCsrOp_Null	};//LW
		32'b???????_?????_?????_100_?????_0000011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	};//LBU
		32'b???????_?????_?????_101_?????_0000011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'0,'0,'0,WbuCsrOp_Null	};//LHU
		32'b???????_?????_?????_000_?????_0100011:out=PackIdFull'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_B		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SB
		32'b???????_?????_?????_001_?????_0100011:out=PackIdFull'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_H		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SH
		32'b???????_?????_?????_010_?????_0100011:out=PackIdFull'{Id2Imm_S		,'1,'1,'0,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size_W		,Ex3Res_Mem	,'x,'1,'0,WbuCsrOp_Null	};//SW
		32'b???????_?????_?????_000_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ADDI
		32'b???????_?????_?????_010_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTI
		32'b???????_?????_?????_011_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTIU
		32'b???????_?????_?????_100_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//XORI
		32'b???????_?????_?????_110_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ORI
		32'b???????_?????_?????_111_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ANDI
		32'b0000000_?????_?????_001_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLLI
		32'b0000000_?????_?????_101_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRLI
		32'b0100000_?????_?????_101_?????_0010011:out=PackIdFull'{Id2Imm_I		,'1,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRAI
		32'b0000000_?????_?????_000_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Add	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//ADD
		32'b0100000_?????_?????_000_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sub	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SUB
		32'b0000000_?????_?????_001_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sll	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLL
		32'b0000000_?????_?????_010_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Slt	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLT
		32'b0000000_?????_?????_011_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sltu	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SLTU
		32'b0000000_?????_?????_100_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Xor	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//XOR
		32'b0000000_?????_?????_101_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Srl	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRL
		32'b0100000_?????_?????_101_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Sra	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//SRA
		32'b0000000_?????_?????_110_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Or	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//OR
		32'b0000000_?????_?????_111_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_And	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//AND
		32'b0000001_?????_?????_000_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mul	,'0,'0,'0,WbuCsrOp_Null	};//MUL
		32'b0000001_?????_?????_001_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'1,'0,WbuCsrOp_Null	};//MULH
		32'b0000001_?????_?????_010_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'1,'0,'0,WbuCsrOp_Null	};//MULHSU
		32'b0000001_?????_?????_011_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Mulh,'0,'0,'0,WbuCsrOp_Null	};//MULHU
		32'b0000001_?????_?????_100_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'1,'1,'0,WbuCsrOp_Null	};//DIV
		32'b0000001_?????_?????_101_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Div	,'0,'0,'0,WbuCsrOp_Null	};//DIVU
		32'b0000001_?????_?????_110_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'1,'1,'0,WbuCsrOp_Null	};//REM
		32'b0000001_?????_?????_111_?????_0110011:out=PackIdFull'{Id2Imm'('x)	,'1,'1,'1,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Rem	,'0,'0,'0,WbuCsrOp_Null	};//REMU
		32'b???????_?????_?????_000_?????_0001111:out=PackIdFull'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Null	};//FENCE
		32'b???????_?????_?????_001_?????_0001111:out=PackIdFull'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'1,WbuCsrOp_Null	};//FENCE.I
		32'b0000000_00000_00000_000_00000_1110011:out=PackIdFull'{Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al_Csr	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'0,'0,WbuCsrOp_Trap	};//ECALL
		32'b0000000_00001_00000_000_00000_1110011:out=PackIdFull'{Id2Imm_T		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al_Csr	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'0,'1,'0,WbuCsrOp_Trap	};//EBREAK
		32'b0011000_00010_00000_000_00000_1110011:out=PackIdFull'{Id2Imm'('x)	,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al'('x)	,Ex1Csr'('x),Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Ret	};//MRET
		32'b???????_?????_?????_001_?????_1110011:out=PackIdFull'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRW
		32'b???????_?????_?????_010_?????_1110011:out=PackIdFull'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRS
		32'b???????_?????_?????_011_?????_1110011:out=PackIdFull'{Id2Imm_C		,'1,'0,'1,'0,'0	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRC
		32'b???????_?????_?????_101_?????_1110011:out=PackIdFull'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_W	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRWI
		32'b???????_?????_?????_110_?????_1110011:out=PackIdFull'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_S	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRSI
		32'b???????_?????_?????_111_?????_1110011:out=PackIdFull'{Id2Imm_C		,'0,'0,'1,'0,'1	,Ex1Bj_Null	,Ex1Al_Imm	,Ex1Csr_C	,Ex2Size'('x)	,Ex3Res_Alu	,'x,'x,'0,WbuCsrOp_Write};//CSRRCI
		default									 :out=PackIdFull'{Id2Imm_E		,'0,'0,'0,'x,'x	,Ex1Bj_Null	,Ex1Al_Csr	,Ex1Csr_I	,Ex2Size'('x)	,Ex3Res_Alu	,'1,'0,'0,WbuCsrOp_Trap	};//illegal
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
