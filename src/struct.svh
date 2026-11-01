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
	logic [1:0] valod;
	logic [1:0][1:0] hit;
} PackData;
typedef struct packed {
	logic [1:0][31:0] r1,r2;
	logic [31:0] sr;
} PackGprs;
`endif
