`include "interface.svh"

module Id2(
    input clk,rst,
    PipeId1Id2.Id2 id1,
    PipeId2Ex1.Id2 ex1
);
    // logic [1:0]valid;
    // logic [1:0][31:7]instr;
    // logic [31:2]pc;
    // PackId1Full id1Full;
    // PackId1Lite id1Lite;
    PipeId1Full id1Full;
    PipeId1Lite id1Lite;
	logic [1:0]pipeReady;
	assign id1.flush = ex1.flush;
	always_ff@(posedge clk)if(pipeReady[0] || rst || ex1.flush)id1Full.valid<=id1.dataFull.valid && !rst && !ex1.flush &&pipeReady[1];
	always_ff@(posedge clk)if(pipeReady[0])id1Full.instr<=id1.dataFull.instr;
	always_ff@(posedge clk)if(pipeReady[0])id1Full.pc   <=id1.dataFull.pc;
	always_ff@(posedge clk)if(pipeReady[0])id1Full.data	<=id1.dataFull.data;
	always_ff@(posedge clk)if(pipeReady[1]|| rst || ex1.flush)id1Lite.valid<=id1.dataLite.valid && !rst && !ex1.flush;
	always_ff@(posedge clk)if(pipeReady[1])id1Lite.instr<=id1.dataLite.instr;
	always_ff@(posedge clk)if(pipeReady[1])id1Lite.data	<=id1.dataLite.data;

	// ================= 直接连线：控制字段 =================
	assign ex1.dataFull.data.in1IsPc = id1Full.data.in1IsPc;
	assign ex1.dataFull.data.in2IsImm = id1Full.data.in2IsImm;
	assign ex1.dataFull.data.bj      = id1Full.data.bj;
	assign ex1.dataFull.data.al      = id1Full.data.al;
	assign ex1.dataFull.data.csr     = id1Full.data.csr;
	assign ex1.dataFull.data.size    = id1Full.data.size;
	assign ex1.dataFull.data.res     = id1Full.data.res;
	assign ex1.dataFull.data.attrA   = id1Full.data.attrA;
	assign ex1.dataFull.data.attrB   = id1Full.data.attrB;
	assign ex1.dataFull.data.fence   = id1Full.data.fence;
	assign ex1.dataFull.data.wbuCsr  = id1Full.data.wbuCsr;
	assign ex1.dataFull.data.pc       = id1Full.pc;
	// 副通道只有 al 是直连
	assign ex1.dataLite.data.al      = id1Lite.data.al;

	// ================= 立即数生成（全通道） =================
	// instr 字段声明为 logic [31:7]，下标就是原指令的位号，直接切片即可
	always_comb unique case (id1Full.data.imm)
		Id2Imm_I: ex1.dataFull.data.imm = {{20{id1Full.instr[31]}}, id1Full.instr[31:20]};
		Id2Imm_S: ex1.dataFull.data.imm = {{20{id1Full.instr[31]}}, id1Full.instr[31:25], id1Full.instr[11:7]};
		Id2Imm_B: ex1.dataFull.data.imm = {{19{id1Full.instr[31]}}, id1Full.instr[31],id1Full.instr[7],id1Full.instr[30:25], id1Full.instr[11:8], 1'b0};
		Id2Imm_U: ex1.dataFull.data.imm = {id1Full.instr[31:12], 12'b0};
		Id2Imm_J: ex1.dataFull.data.imm = {{11{id1Full.instr[31]}}, id1Full.instr[31],id1Full.instr[19:12],id1Full.instr[20], id1Full.instr[30:21], 1'b0};
		Id2Imm_C: ex1.dataFull.data.imm = ex1.csrData;                      // CSR 转发值
		Id2Imm_T: ex1.dataFull.data.imm = id1Full.data.attrB ? 32'd3:32'd11;    // ebreak / ecall
		Id2Imm_E: ex1.dataFull.data.imm = id1Full.data.attrA ? 32'd2:(id1Full.data.attrB ? 32'd0 : 32'd1);   //  非法指令 / 地址不对齐 / 取指访问错误
	endcase

	assign ex1.dataFull.data.rd = id1Full.instr[11:7] & {5{id1Full.data.rd}};
	assign ex1.r1Addr[0]= id1Full.instr[19:15];
	assign ex1.r2Addr[0]= id1Full.instr[24:20];
	assign ex1.csrAddr	= id1Full.instr[31:20];
	assign ex1.dataFull.data.r1 = ex1.r1Data[0] & {32{|ex1.r1Addr[0]}};
	assign ex1.dataFull.data.r2 = ex1.r2Data[0] & {32{|ex1.r2Addr[0]}};
	logic regValidFull;assign regValidFull=(ex1.r1Valid[0] || !id1Full.data.r1 || ~(|ex1.r1Addr[0])) && (ex1.r2Valid[0] || !id1Full.data.r2 || ~(|ex1.r2Addr[0]));
	assign ex1.dataFull.valid = id1Full.valid && regValidFull;

	assign ex1.dataLite.data.rd = id1Lite.instr[11:7] & {5{id1Lite.data.rd}};
	assign ex1.r1Addr[1] = id1Lite.instr[19:15];
	assign ex1.r2Addr[1] = id1Lite.instr[24:20];
	logic [31:0]immLite;assign immLite = {{20{id1Lite.instr[31]}}, id1Lite.instr[31:20]};
	assign ex1.dataLite.data.r1 = id1Lite.data.r1?(ex1.r1Data[1] & {32{|ex1.r1Addr[1]}}):immLite;
	assign ex1.dataLite.data.r2 = id1Lite.data.r2?(ex1.r2Data[1] & {32{|ex1.r2Addr[1]}}):immLite;
	logic regValidLite;assign regValidLite=(ex1.r1Valid[1] || !id1Lite.data.r1 || ~(|ex1.r1Addr[1])) && (ex1.r2Valid[1] || !id1Lite.data.r2 || ~(|ex1.r2Addr[1]));
	assign ex1.dataLite.valid = id1Lite.valid && regValidLite && ex1.dataFull.valid;

	assign pipeReady[0] = ex1.ready[0] && (!id1Full.valid || regValidFull);
	assign pipeReady[1] = ex1.ready[1] && (!id1Lite.valid || (regValidLite && id1Full.valid));
	assign id1.ready = pipeReady[1] && pipeReady[0];
	// ================= 仍需实现 =================
	// 半包转发（lite 以 full 可走为前提）与 id1.ready / ex1.ready 的握手
endmodule
