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
`endif
