`include "interface.svh"

// Id1 顶层：时钟/复位、IF2→ID1 寄存、ready 三态
module tb_top;
	logic clk = 0, rst = 1;
	PipeIf2Id1 if2();
	PipeId1Id2 id12();
	Id1 dut(.clk(clk), .rst(rst), .pipeIf2Id1(if2), .pipeId1Id2(id12));

	int err = 0;
	always #5 clk = ~clk;

	task automatic chk(input bit ok, input string nm);
		if (!ok) begin $display("FAIL %s", nm); err++; end
	endtask

	task automatic pkt(input logic [31:0] i0, input logic [31:2] p0, input Id1Valid v0,
	                   input logic [31:0] i1, input logic [31:2] p1, input Id1Valid v1);
		if2.data[0] = '{valid:v0, data:'{instr:i0, pc:p0}};
		if2.data[1] = '{valid:v1, data:'{instr:i1, pc:p1}};
	endtask

	initial begin
		id12.ready = 1'b1;
		pkt(32'h0, 30'h0, Id1Valid_Idle, 32'h0, 30'h0, Id1Valid_Idle);
		repeat (2) @(posedge clk);
		rst = 0;

		// 双发：ADDI + ADD，lite 可用 → ready=2
		pkt(32'h0000_0093, 30'h2000_0000, Id1Valid_Valid,
		    32'h0000_0033, 30'h2000_0004, Id1Valid_Valid);
		@(posedge clk); #1;
		chk(if2.ready === Id1Ready_2, "ready 双发");
		chk(id12.dataFull.valid === 1'b1 && id12.dataFull.data.al === Ex1Al_Add, "full ADDI");
		chk(id12.dataFull.pc === 30'h2000_0000, "full pc");
		chk(id12.dataLite.valid === 1'b1 && id12.dataLite.data.al === Ex1Al_Add, "lite ADD");

		// 槽1 换成 LB（lite 不支持）→ ready=1
		pkt(32'h0000_0093, 30'h2000_0008, Id1Valid_Valid,
		    32'h0000_0083, 30'h2000_000C, Id1Valid_Valid);
		@(posedge clk); #1;
		chk(if2.ready === Id1Ready_1, "ready 单发");
		chk(id12.dataLite.valid === 1'b0, "lite 不支持 LB");

		// 下游不可接收 → ready=0
		id12.ready = 1'b0; #1;
		chk(if2.ready === Id1Ready_0, "ready 阻塞");

		// 复位：valid 清 Idle
		id12.ready = 1'b1;
		rst = 1;
		pkt(32'h0, 30'h0, Id1Valid_Idle, 32'h0, 30'h0, Id1Valid_Idle);
		@(posedge clk); #1;
		chk(id12.dataFull.valid === 1'b0 && id12.dataLite.valid === 1'b0, "复位后 valid=0");

		if (err == 0) $display("tb_top: ALL OK");
		else          $display("tb_top: %0d FAIL", err);
		$finish;
	end
endmodule
