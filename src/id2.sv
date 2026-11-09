`include "interface.svh"

module Id2(
    input clk,rst,
    PipeId1Id2.Id2 pipeId1Id2,
    PipeId2Ex1.Id2 pipeId2Ex
);
    // logic [1:0]valid;
    // logic [1:0][31:7]instr;
    // logic [31:2]pc;
    // PackId1Full id1Full;
    // PackId1Lite id1Lite;
    PipeId1Full id1Full;
    PipeId1Lite id1Lite;
    always_ff@(posedge clk)id1Full.valid<=pipeId1Id2.dataFull.valid && !rst;
    always_ff@(posedge clk)id1Full.instr<=pipeId1Id2.dataFull.instr;
    always_ff@(posedge clk)id1Full.pc   <=pipeId1Id2.dataFull.pc;
    always_ff@(posedge clk)id1Full.data<=pipeId1Id2.dataFull.data;
    always_ff@(posedge clk)id1Lite.valid<=pipeId1Id2.dataLite.valid && !rst;
    always_ff@(posedge clk)id1Lite.instr<=pipeId1Id2.dataLite.instr;
    always_ff@(posedge clk)id1Lite.data<=pipeId1Id2.dataLite.data;

	// ================= 直接连线：控制字段 =================
	assign pipeId2Ex.dataFull.data.in1IsPc = id1Full.data.in1IsPc;
	assign pipeId2Ex.dataFull.data.in2IsImm = id1Full.data.in2IsImm;
	assign pipeId2Ex.dataFull.data.bj      = id1Full.data.bj;
	assign pipeId2Ex.dataFull.data.al      = id1Full.data.al;
	assign pipeId2Ex.dataFull.data.csr     = id1Full.data.csr;
	assign pipeId2Ex.dataFull.data.size    = id1Full.data.size;
	assign pipeId2Ex.dataFull.data.res     = id1Full.data.res;
	assign pipeId2Ex.dataFull.data.attrA   = id1Full.data.attrA;
	assign pipeId2Ex.dataFull.data.attrB   = id1Full.data.attrB;
	assign pipeId2Ex.dataFull.data.fence   = id1Full.data.fence;
	assign pipeId2Ex.dataFull.data.wbuCsr  = id1Full.data.wbuCsr;
	// 副通道只有 al 是直连
	assign pipeId2Ex.dataLite.data.al      = id1Lite.data.al;

	// ================= 需要处理，不是直连 =================
	// valid : pipeId2Ex.dataFull.valid / pipeId2Ex.dataLite.valid（握手 + 半包发射）
	// rd    : 从 id1Full.instr[11:7] / id1Lite.instr[11:7] 切出
	// r1/r2 : PRF 读出 + 旁路仲裁后的 32 位数据（配合 pipeId2Ex.r1Addr/r2Addr/r1Data/r2Data）
	// imm   : 由 id1Full.data.imm + id1Full.instr 生成 32 位值
	//         注意：PackId2Full.imm 现在是 Id2Imm（3 位枚举），要装 32 位值需改成 logic [31:0]
	// pc    : id1Full.pc -> pipeId2Ex.dataFull.data.pc
	//         注意：PipeId2Full.data 现在写成 PackId1Full（没有 pc），需改成 PackId2Full
endmodule
