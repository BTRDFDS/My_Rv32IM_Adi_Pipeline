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
	logic [31:0] instr;
	logic [31:2] pc;
} PackInstr;typedef struct packed {Id1Valid valid;PackInstr data;} PipeInstr;
// attrA / attrB：跨指令类复用的一对控制位。一条指令只属于一个类，每个消费方必须用自己的使能门控。
//   M 类 : attrA = 被乘数/被除数有符号，attrB = 乘数/除数有符号
//          （MUL 0/0，MULH 1/1，MULHSU 1/0，MULHU 0/0，DIV/REM 1/1，DIVU/REMU 0/0）
//   访存 : attrB = 0 读(load) / 1 写(store)；attrA 只在 load 时表示是否符号扩展
//   自陷 : imm_T 时 attrB = 0 ecall / 1 ebreak
//   错误 : imm_E 时 attrA = 1 非法指令（0 = 取指问题），attrB = 0 取指访问错误 / 1 地址不对齐
// Ex3Res_Mem：load 与 store 共用（store 靠 rd=0 不写回），它同时是访存单元的启动信号。
typedef struct packed {
	Id2Imm imm;
	logic r1,r2,rd;
	logic in1IsPc,in2IsImm;
	Ex1Bj bj;
	Ex1Al al;
	Ex1Csr csr;
	Ex2Size size;
	Ex3Res res;
	logic attrA,attrB,fence;
	WbuCsrOp wbuCsr;
} PackId1Full;typedef struct packed {logic valid;logic [31:2] pc;logic [31:7] instr;PackId1Full data;} PipeId1Full;
typedef struct packed {
	logic r1,r2,rd;
	Ex1Al al;
} PackId1Lite;typedef struct packed {logic valid;logic [31:7] instr;PackId1Lite data;} PipeId1Lite;
typedef struct packed {
	logic [31:0]imm,r1,r2;
	logic [4:0]rd;
	logic in1IsPc,in2IsImm;
	Ex1Bj bj;
	Ex1Al al;
	Ex1Csr csr;
	Ex2Size size;
	Ex3Res res;
	logic attrA,attrB,fence;
	WbuCsrOp wbuCsr;
	logic [31:2] pc;
} PackId2Full;typedef struct packed {logic valid;PackId2Full data;} PipeId2Full;
typedef struct packed {
	logic [31:0]r1,r2;
	logic [4:0]rd;
	Ex1Al al;
} PackId2Lite;typedef struct packed {logic valid;PackId2Lite data;} PipeId2Lite;
`endif
