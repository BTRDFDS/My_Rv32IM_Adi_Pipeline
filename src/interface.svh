`ifndef _INTERFACE_SVH_
`define _INTERFACE_SVH_
`include "enum.svh"
interface ImmeFw;
	logic [31:0] r1[1:0],r2[1:0],sr;
	logic [4:0] r1Addr[1:0],r2Addr[1:0];
	logic [11:0] srAddr;
	logic r1Valid[1:0],r2Valid[1:0];
	modport down( input r1Addr,r2Addr,srAddr,output r1,r2,sr,r1Valid,r2Valid);
	modport up  (output r1Addr,r2Addr,srAddr, input r1,r2,sr,r1Valid,r2Valid);
endinterface //ImmeFw

interface pipeWb;
	logic [4:0] rdAddr[1:0];
	logic [31:0] rdData[1:0],srData,pc;
	logic [11:0] srAddr;
	WbuCsrOp csrOp;
	logic valid[1:0];
	modport in(input rdAddr,rdData,srData,pc,srAddr,csrOp,valid);
	modport out(output rdAddr,rdData,srData,pc,srAddr,csrOp,valid);
endinterface //pipeWb

`endif
