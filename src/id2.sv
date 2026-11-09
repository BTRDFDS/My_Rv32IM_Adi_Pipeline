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
	logic [1:0]pipeReady;
	always_ff@(posedge clk)if(pipeReady[0]||rst)id1Full.valid<=pipeId1Id2.dataFull.valid && !rst &&pipeReady[1];
	always_ff@(posedge clk)if(pipeReady[0])id1Full.instr<=pipeId1Id2.dataFull.instr;
	always_ff@(posedge clk)if(pipeReady[0])id1Full.pc   <=pipeId1Id2.dataFull.pc;
	always_ff@(posedge clk)if(pipeReady[0])id1Full.data	<=pipeId1Id2.dataFull.data;
	always_ff@(posedge clk)if(pipeReady[1]||rst)id1Lite.valid<=pipeId1Id2.dataLite.valid && !rst;
	always_ff@(posedge clk)if(pipeReady[1])id1Lite.instr<=pipeId1Id2.dataLite.instr;
	always_ff@(posedge clk)if(pipeReady[1])id1Lite.data	<=pipeId1Id2.dataLite.data;

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
	assign pipeId2Ex.dataFull.data.pc       = id1Full.pc;
	// 副通道只有 al 是直连
	assign pipeId2Ex.dataLite.data.al      = id1Lite.data.al;

	// ================= 立即数生成（全通道） =================
	// instr 字段声明为 logic [31:7]，下标就是原指令的位号，直接切片即可
	always_comb unique case (id1Full.data.imm)
		Id2Imm_I: pipeId2Ex.dataFull.data.imm = {{20{id1Full.instr[31]}}, id1Full.instr[31:20]};
		Id2Imm_S: pipeId2Ex.dataFull.data.imm = {{20{id1Full.instr[31]}}, id1Full.instr[31:25], id1Full.instr[11:7]};
		Id2Imm_B: pipeId2Ex.dataFull.data.imm = {{19{id1Full.instr[31]}}, id1Full.instr[31],id1Full.instr[7],id1Full.instr[30:25], id1Full.instr[11:8], 1'b0};
		Id2Imm_U: pipeId2Ex.dataFull.data.imm = {id1Full.instr[31:12], 12'b0};
		Id2Imm_J: pipeId2Ex.dataFull.data.imm = {{11{id1Full.instr[31]}}, id1Full.instr[31],id1Full.instr[19:12],id1Full.instr[20], id1Full.instr[30:21], 1'b0};
		Id2Imm_C: pipeId2Ex.dataFull.data.imm = pipeId2Ex.csrData;                      // CSR 转发值
		Id2Imm_T: pipeId2Ex.dataFull.data.imm = id1Full.data.attrB ? 32'd3:32'd11;    // ebreak / ecall
		Id2Imm_E: pipeId2Ex.dataFull.data.imm = id1Full.data.attrA ? 32'd2:(id1Full.data.attrB ? 32'd0 : 32'd1);   //  非法指令 / 地址不对齐 / 取指访问错误
	endcase

	assign pipeId2Ex.dataFull.data.rd = id1Full.instr[11:7] & {5{id1Full.data.rd}};
	assign pipeId2Ex.r1Addr[0] = id1Full.instr[19:15];
	assign pipeId2Ex.r2Addr[0] = id1Full.instr[24:20];
	assign pipeId2Ex.dataFull.data.r1 = pipeId2Ex.r1Data[0] & {32{|pipeId2Ex.r1Addr[0]}};
	assign pipeId2Ex.dataFull.data.r2 = pipeId2Ex.r2Data[0] & {32{|pipeId2Ex.r2Addr[0]}};
	logic regValidFull;assign regValidFull=(pipeId2Ex.r1Valid[0] || !id1Full.data.r1 || ~(|pipeId2Ex.r1Addr[0])) && (pipeId2Ex.r2Valid[0] || !id1Full.data.r2 || ~(|pipeId2Ex.r2Addr[0]));
	assign pipeId2Ex.dataFull.valid = id1Full.valid && regValidFull;

	assign pipeId2Ex.dataLite.data.rd = id1Lite.instr[11:7] & {5{id1Lite.data.rd}};
	assign pipeId2Ex.r1Addr[1] = id1Lite.instr[19:15];
	assign pipeId2Ex.r2Addr[1] = id1Lite.instr[24:20];
	logic [31:0]immLite;assign immLite = {{20{id1Lite.instr[31]}}, id1Lite.instr[31:20]};
	assign pipeId2Ex.dataLite.data.r1 = id1Lite.data.r1?(pipeId2Ex.r1Data[1] & {32{|pipeId2Ex.r1Addr[1]}}):immLite;
	assign pipeId2Ex.dataLite.data.r2 = id1Lite.data.r2?(pipeId2Ex.r2Data[1] & {32{|pipeId2Ex.r2Addr[1]}}):immLite;
	logic regValidLite;assign regValidLite=(pipeId2Ex.r1Valid[1] || !id1Lite.data.r1 || ~(|pipeId2Ex.r1Addr[1])) && (pipeId2Ex.r2Valid[1] || !id1Lite.data.r2 || ~(|pipeId2Ex.r2Addr[1]));
	assign pipeId2Ex.dataLite.valid = id1Lite.valid && regValidLite && pipeId2Ex.dataFull.valid;

	assign pipeReady[0] = pipeId2Ex.ready[0] && (!id1Full.valid || regValidFull);
	assign pipeReady[1] = pipeId2Ex.ready[1] && (!id1Lite.valid || (regValidLite && id1Full.valid));
	assign pipeId1Id2.ready = pipeReady[1] && pipeReady[0];
	// ================= 仍需实现 =================
	// 半包转发（lite 以 full 可走为前提）与 pipeId1Id2.ready / pipeId2Ex.ready 的握手
endmodule
