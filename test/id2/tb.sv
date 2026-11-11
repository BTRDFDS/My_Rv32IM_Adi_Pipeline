`include "interface.svh"

// Id2 唯一测试：全部用例在一个波形里（build/wave/id2.fst），遇到第一个错误立即 $fatal。
module tb;
	logic clk = 0, rst = 1;
	PipeId1Id2 i12();
	PipeId2Ex1 i2x();
	Id2 dut(.clk(clk), .rst(rst), .id1(i12), .ex1(i2x));

	int phase = 0;
	always #5 clk = ~clk;

	Id2Imm dbg_imm_full;
	always_comb dbg_imm_full = i12.dataFull.data.imm;

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

	task automatic chk(input bit ok, input string nm, input string got);
		if (!ok) begin
			$display("FAIL[t=%0t phase=%0d] %s", $time, phase, nm);
			$display("                    实际：%s", got);
			$fatal(1);
		end
	endtask

	task automatic waitclk();
		@(posedge clk); #1;
	endtask

	initial begin
		$dumpfile("build/wave/id2.fst");
		$dumpvars(0, tb);
		i12.dataFull = '0; i12.dataLite = '0;
		i2x.ready = 2'b11; i2x.r1Valid = 2'b11; i2x.r2Valid = 2'b11;
		i2x.r1Data[0] = 32'haabb_ccdd; i2x.r2Data[0] = 32'h1122_3344;
		i2x.r1Data[1] = 32'h5555_6666; i2x.r2Data[1] = 32'h7777_8888;
		i2x.csrData = 32'hdead_beef;
		repeat (2) @(posedge clk);
		rst = 0;

		// 1) I 型：ADDI x5, x6, -1
		phase = 1;
		setpkt(32'hfff3_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.imm === 32'hffff_ffff, "I 型立即数错误",
		    $sformatf("imm=%h 期望 ffffffff", i2x.dataFull.data.imm));
		chk(i2x.dataFull.data.rd  === 5'd5, "rd 错误",
		    $sformatf("rd=%0d 期望 5", i2x.dataFull.data.rd));
		chk(i2x.dataFull.data.r1  === 32'haabb_ccdd, "r1 数据错误",
		    $sformatf("r1=%h 期望 aabbccdd", i2x.dataFull.data.r1));
		chk(i2x.dataFull.valid    === 1'b1, "full.valid 应为 1",
		    $sformatf("valid=%b", i2x.dataFull.valid));

		// 2) x0：rs1=0 时 r1 必须为 0
		phase = 2;
		setpkt(32'h0050_0013, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.r1 === 32'h0, "x0 未清零",
		    $sformatf("r1=%h", i2x.dataFull.data.r1));

		// 3) 源未就绪：valid 与 ID1.ready 都应拉低
		phase = 3;
		i2x.r1Valid[0] = 1'b0;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.valid === 1'b0, "未就绪时 full.valid 应为 0",
		    $sformatf("valid=%b", i2x.dataFull.valid));
		chk(i12.ready === 1'b0, "未就绪时 ID1.ready 应为 0",
		    $sformatf("ready=%b", i12.ready));

		// 4) lite 必须以 full 为前提
		phase = 4;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		i12.dataLite.valid = 1'b1;
		i12.dataLite.instr = 25'h1;
		i12.dataLite.data  = '0;
		waitclk();
		chk(i2x.dataLite.valid === 1'b0, "槽0 未就绪时 lite 不得发射",
		    $sformatf("lite.valid=%b", i2x.dataLite.valid));
		i2x.r1Valid[0] = 1'b1;

		// 5) 空槽：full 无效时 ID1 必须能前进
		phase = 5;
		setpkt(32'h0, Id2Imm'('x), 1'bx, 1'bx, 1'bx, 1'b0);
		i12.dataLite.valid = 1'b0;
		waitclk();
		chk(i12.ready === 1'b1, "空槽时必须让 ID1 前进（否则死锁）",
		    $sformatf("ready=%b", i12.ready));

		// 6) 连续两包
		phase = 6;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		setpkt(32'h00a3_0313, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.rd === 5'd6, "连续包：第二包 rd 错误",
		    $sformatf("rd=%0d 期望 6", i2x.dataFull.data.rd));

		// 7) 下游阻塞：保持旧内容
		phase = 7;
		i2x.ready = 2'b00;
		setpkt(32'h00b3_0393, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.valid === 1'b1 && i2x.dataFull.data.rd === 5'd6,
		    "阻塞时未保持旧内容",
		    $sformatf("valid=%b rd=%0d 期望 1/6", i2x.dataFull.valid, i2x.dataFull.data.rd));
		repeat (2) waitclk();
		chk(i2x.dataFull.valid === 1'b1 && i2x.dataFull.data.rd === 5'd6,
		    "阻塞多拍仍未保持",
		    $sformatf("valid=%b rd=%0d 期望 1/6", i2x.dataFull.valid, i2x.dataFull.data.rd));
		i2x.ready = 2'b11;
		setpkt(32'h00c4_0413, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.rd === 5'd8, "解除阻塞后未前进",
		    $sformatf("rd=%0d 期望 8", i2x.dataFull.data.rd));

		// 8) S 型：sw x5, 8(x6)
		phase = 8;
		setpkt(32'h0053_2423, Id2Imm_S, 1'b1, 1'b1, 1'b0, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.imm === 32'h0000_0008, "S 型立即数错误",
		    $sformatf("imm=%h 期望 8", i2x.dataFull.data.imm));

		// 9) B 型：bne x5, x6, +16
		phase = 9;
		setpkt(32'h0062_9863, Id2Imm_B, 1'b1, 1'b1, 1'b0, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.imm === 32'h0000_0010, "B 型立即数错误",
		    $sformatf("imm=%h 期望 10", i2x.dataFull.data.imm));

		phase = 0;
		repeat (2) @(negedge clk);
		$display("tb: OK（波形 build/wave/id2.fst）");
		$finish;
	end
endmodule
