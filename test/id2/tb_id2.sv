`include "interface.svh"

// Id2：立即数/rd/r1/r2/valid 与握手
module tb_id2;
	logic clk = 0, rst = 1;
	PipeId1Id2 i12();
	PipeId2Ex1 i2x();
	Id2 dut(.clk(clk), .rst(rst), .id1(i12), .ex1(i2x));

	int err = 0;
	always #5 clk = ~clk;

	task automatic setpkt(input logic [31:0] instr, input Id2Imm immf,
	                      input logic r1, input logic r2, input logic rd, input logic v);
		i12.dataFull.valid    = v;
		i12.dataFull.instr    = instr[31:7];
		i12.dataFull.pc       = 30'h2000_0000;
		i12.dataFull.data     = '0;
		i12.dataFull.data.imm = immf;
		i12.dataFull.data.r1  = r1;
		i12.dataFull.data.r2  = r2;
		i12.dataFull.data.rd  = rd;
	endtask

	task automatic chk(input bit ok, input string nm);
		if (!ok) begin $display("FAIL %s", nm); err++; end
	endtask

	initial begin
		i12.dataFull = '0; i12.dataLite = '0;
		i2x.ready = 2'b11; i2x.r1Valid = 2'b11; i2x.r2Valid = 2'b11;
		i2x.r1Data[0] = 32'haabb_ccdd; i2x.r2Data[0] = 32'h1122_3344;
		i2x.r1Data[1] = 32'h5555_6666; i2x.r2Data[1] = 32'h7777_8888;
		i2x.csrData = 32'hdead_beef;
		repeat (2) @(posedge clk);
		rst = 0;

		// 1) I 型：ADDI x5, x6, -1
		setpkt(32'hfff3_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		@(posedge clk); #1;
		chk(i2x.dataFull.data.imm === 32'hffff_ffff, "I 型立即数");
		chk(i2x.dataFull.data.rd  === 5'd5,             "rd");
		chk(i2x.dataFull.data.r1  === 32'haabb_ccdd,    "r1 数据");
		chk(i2x.dataFull.valid    === 1'b1,             "valid");

		// 2) x0：rs1=0 时 r1 必须为 0（即使 r1Data 是垃圾）
		setpkt(32'h0050_0013, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		@(posedge clk); #1;
		chk(i2x.dataFull.data.r1 === 32'h0, "x0 清零");

		// 3) 源未就绪：r1Valid=0 且源非 x0 -> valid 拉低、对 ID1 的 ready 也拉低
		i2x.r1Valid[0] = 1'b0;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		@(posedge clk); #1;
		chk(i2x.dataFull.valid === 1'b0, "未就绪时 valid=0");
		chk(i12.ready === 1'b0,          "未就绪时 ID1.ready=0");
		i2x.r1Valid[0] = 1'b1;

		// 4) lite 必须以 full 为前提：槽1 就绪、槽0 未就绪 -> lite.valid 必须为 0
		i2x.r1Valid[0] = 1'b0;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		i12.dataLite.valid = 1'b1;
		i12.dataLite.instr = 25'h1;
		i12.dataLite.data  = '0;
		@(posedge clk); #1;
		chk(i2x.dataLite.valid === 1'b0, "槽0 未就绪时 lite 不得发射");
		i2x.r1Valid[0] = 1'b1;

		// 5) 空槽（bubble）：full 无效时 ID1 必须能继续前进
		setpkt(32'h0, Id2Imm'('x), 1'bx, 1'bx, 1'bx, 1'b0);
		i12.dataLite.valid = 1'b0;
		@(posedge clk); #1;
		chk(i12.ready === 1'b1, "空槽时必须让 ID1 前进（否则死锁）");


		// 6) 连续两个包：第二包必须紧跟第一包出现在输出上
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);   // ADDI
		@(posedge clk); #1;
		setpkt(32'h00a3_0313, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);   // ADDI
		@(posedge clk); #1;
		chk(i2x.dataFull.data.rd === 5'd6, "连续包：第二包 rd");

		// 7) 下游不接收：寄存器保持原内容，新包停在接口上等待
		i2x.ready = 2'b00;
		setpkt(32'h00b3_0393, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);   // ADDI x7
		@(posedge clk); #1;
		chk(i2x.dataFull.valid === 1'b1 && i2x.dataFull.data.rd === 5'd6, "阻塞时保持旧内容");
		repeat (2) @(posedge clk); #1;
		chk(i2x.dataFull.valid === 1'b1 && i2x.dataFull.data.rd === 5'd6, "阻塞多拍仍保持");
		i2x.ready = 2'b11;
		setpkt(32'h00c4_0413, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);   // ADDI x8
		@(posedge clk); #1;
		chk(i2x.dataFull.data.rd === 5'd8, "解除阻塞后前进");

		if (err == 0) $display("tb_id2: OK");
		else          $display("tb_id2: %0d FAIL", err);
		$finish;
	end
endmodule
