`ifndef _STRUCT_SVH_
`define _STRUCT_SVH_
`include "enum.svh"

typedef struct packed {
	logic [4:0] rdAddr;
	logic [31:0] rdData,srData,pc;
	logic [11:0] srAddr;
	WbuCsrOp csrOp;
} PackWbM;typedef struct packed {logic valid;PackWbM data;}PipeWbM;
typedef struct packed {
	logic [4:0] rdAddr;
	logic [31:0] rdData;
} PackWbS;typedef struct packed {logic valid;PackWbS data;} PipeWbS;
`endif
