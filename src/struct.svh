`ifndef _STRUCT_SVH_
`define _STRUCT_SVH_
`include "enum.svh"

typedef struct packed {
	logic [31:0] srData,pc;
	logic [11:0] srAddr;
	WbuCsrOp csrOp;
} PackSr;
typedef struct packed {
	logic [4:0] addr;
	logic [31:0] data;
} PackRd;
typedef struct packed {
	logic [1:0][31:0] rd;
	logic [31:0] sr;
	logic [1:0] valid;
	logic [1:0][1:0] hit;
} PackData;
typedef struct packed {
	logic [1:0][31:0] r1,r2;
	logic [31:0] sr;
} PackGprs;
typedef struct packed {
	logic [31:2] pc;

} Packid1Full;
typedef struct packed {
	logic [31:0] instr;
	logic [31:2] pc;
	InstrValid valid;
} PackInstr;
typedef struct packed {
	Id2Imm imm;
	Ex3Res res;
	Ex1Bj bj;
	Ex1Al al;
	Ex2Size size;
	logic r1,r2,rd;
	logic in1IsPc,in2IsImm;
	logic load,store,sext;
} PackIdFull;
`endif
