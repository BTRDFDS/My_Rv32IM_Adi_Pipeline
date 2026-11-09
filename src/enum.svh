`ifndef _ENUM_SVH_
`define _ENUM_SVH_

typedef enum logic[1:0] {WbuCsrOp_Null,WbuCsrOp_Write,WbuCsrOp_Trap,WbuCsrOp_Ret} WbuCsrOp;
typedef enum logic[1:0] {Id1Valid_Idle,Id1Valid_Valid,Id1Valid_Fall,Id1Valid_Un4b} Id1Valid;
typedef enum logic[1:0] {Id1Ready_0,Id1Ready_1,Id1Ready_2} Id1Ready;

typedef enum logic[2:0] {Id2Imm_E,Id2Imm_I,Id2Imm_S,Id2Imm_B,Id2Imm_U,Id2Imm_J,Id2Imm_C,Id2Imm_T} Id2Imm;
typedef enum logic[2:0] {Ex3Res_Alu,Ex3Res_Mul,Ex3Res_Mulh,Ex3Res_Div,Ex3Res_Rem,Ex3Res_Mem} Ex3Res;
typedef enum logic[2:0] {Ex1Bj_Beq,Ex1Bj_Bne,Ex1Bj_Jump,Ex1Bj_Null,Ex1Bj_Blt,Ex1Bj_Bge,Ex1Bj_Bltu,Ex1Bj_Bgeu} Ex1Bj;
typedef enum logic[3:0] {Ex1Al_Add,Ex1Al_Sll,Ex1Al_Slt,Ex1Al_Sltu,Ex1Al_Xor,Ex1Al_Srl,Ex1Al_Or,Ex1Al_And,Ex1Al_Sub=4'b1000,Ex1Al_Npc,Ex1Al_Imm,Ex1Al_Sra=4'b1101} Ex1Al;
typedef enum logic[1:0] {Ex1Csr_I,Ex1Csr_C,Ex1Csr_S,Ex1Csr_W} Ex1Csr;

typedef enum logic [2:0] {Ex2Size_W,Ex2Size_H,Ex2Size_B} Ex2Size;
`endif
