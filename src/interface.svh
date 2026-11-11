`ifndef _INTERFACE_SVH_
`define _INTERFACE_SVH_
`include "struct.svh"
interface pipeWb;
	PackRd rd[1:0];
	PackSr sr;
	logic [1:0] valid;
	modport in( input rd,sr,valid);
	modport out(output rd,sr,valid);
endinterface //pipeWb
interface ImmeData;
	PackData dataEx1,dataEx2,dataLsu,dataWbu;
	PackGprs dataGprs;
	logic [1:0][1:0][4:0] addr;
	logic [11:0] srAddr;
	modport idu(output addr,srAddr, input dataEx1,dataEx2,dataLsu,dataWbu,dataGprs);
	modport ex1( input addr,srAddr,output dataEx1);
	modport ex2( input addr,srAddr,output dataEx2);
	modport lsu( input addr,srAddr,output dataLsu);
	modport wbu( input addr,srAddr,output dataWbu,dataGprs);
endinterface : ImmeData

interface PipeIf2Ifb;
	PipeInstr [1:0]instr;
	logic ready;
	modport Ifb( input instr,output ready);
	modport If1(output instr, input ready);
endinterface : PipeIf2Ifb
interface PipeIfbId1;
	PipeInstr [1:0]instr;
	// Id1Ready ready;
	logic [1:0] consume;
	modport Id1( input instr,output consume);
	modport Ifb(output instr, input consume);
endinterface : PipeIfbId1
interface PipeId1Id2;
	PipeId1Full dataFull;
	PipeId1Lite dataLite;
	logic ready;
	modport Id2( input dataFull,dataLite,output ready);
	modport Id1(output dataFull,dataLite, input ready);
endinterface : PipeId1Id2
interface PipeId2Ex1;
	PipeId2Full dataFull;
	PipeId2Lite dataLite;
	logic [1:0]ready;
	logic [1:0]r1Valid;
	logic [1:0]r2Valid;
	logic [1:0][4:0]r1Addr;
	logic [1:0][4:0]r2Addr;
	logic [1:0][31:0]r1Data;
	logic [1:0][31:0]r2Data;
	logic [11:0]csrAddr;
	logic [31:0]csrData;
	modport Ex1( input dataFull,dataLite,r1Addr,r2Addr,csrAddr,output ready,r1Valid,r2Valid,r1Data,r2Data,csrData);
	modport Id2(output dataFull,dataLite,r1Addr,r2Addr,csrAddr, input ready,r1Valid,r2Valid,r1Data,r2Data,csrData);
endinterface : PipeId2Ex1

`endif
