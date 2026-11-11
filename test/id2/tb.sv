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

	// 结构检查：这些是 Id2 必须驱动的输出，未驱动会一直保持 X
	always @(negedge clk) if (!rst) begin
		if ($isunknown(i2x.csrAddr)) begin
			$display("FAIL[t=%0t] ex1.csrAddr 未驱动（X）：Id2 没有连接这个接口输出", $time);
			$fatal(1);
		end
		if ($isunknown(i2x.r1Addr[0]) || $isunknown(i2x.r2Addr[0]) ||
		    $isunknown(i2x.r1Addr[1]) || $isunknown(i2x.r2Addr[1])) begin
			$display("FAIL[t=%0t] r1Addr/r2Addr 未驱动（X）", $time);
			$fatal(1);
		end
		if ($isunknown(i12.ready)) begin
			$display("FAIL[t=%0t] id1.ready 未驱动（X）", $time);
			$fatal(1);
		end
	end

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
		i12.dataLite.instr = (25'd5 << 8);
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

		// 10) U 型：LUI x1, 0x12345 -> imm = 0x12345000
		phase = 10;
		setpkt(32'h1234_50B7, Id2Imm_U, 1'b0, 1'b0, 1'b1, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.imm === 32'h1234_5000, "U 型立即数错误",
		    $sformatf("imm=%h 期望 12345000", i2x.dataFull.data.imm));

		// 11) J 型：JAL x0, 16 -> imm = 0x10
		phase = 11;
		setpkt(32'h0100_006F, Id2Imm_J, 1'b0, 1'b0, 1'b0, 1'b1);
		waitclk();
		chk(i2x.dataFull.data.imm === 32'h0000_0010, "J 型立即数错误",
		    $sformatf("imm=%h 期望 10", i2x.dataFull.data.imm));

		// 12) CSR：csrrw x1, 0x300, x2 -> csrAddr=0x300，imm 取 csrData
		phase = 12;
		setpkt(32'h3001_10F3, Id2Imm_C, 1'b1, 1'b0, 1'b1, 1'b1);
		i12.dataFull.data.csr    = Ex1Csr_W;      // 模拟 ID1 的译码结果
		i12.dataFull.data.wbuCsr = WbuCsrOp_Write;
		repeat (2) waitclk();
		chk(i2x.csrAddr === 12'h300, "CSR 地址错误",
		    $sformatf("csrAddr=%h 期望 300", i2x.csrAddr));
		chk(i2x.dataFull.data.imm === 32'hdead_beef, "CSR 指令的 imm 应取 csrData",
		    $sformatf("imm=%h 期望 deadbeef", i2x.dataFull.data.imm));

		chk(i2x.dataFull.data.csr === Ex1Csr_W, "CSRRW 的 csr 操作码错误",
		    $sformatf("csr=%b 期望 %b", i2x.dataFull.data.csr, Ex1Csr_W));
		chk(i2x.dataFull.data.wbuCsr === WbuCsrOp_Write, "CSRRW 的 wbuCsr 错误",
		    $sformatf("wbuCsr=%b 期望 %b", i2x.dataFull.data.wbuCsr, WbuCsrOp_Write));

		// 14) ECALL：wbuCsr 必须是 Trap
		phase = 14;
		setpkt(32'h0000_0073, Id2Imm_T, 1'b0, 1'b0, 1'b0, 1'b1);
		i12.dataFull.data.wbuCsr = WbuCsrOp_Trap; // 模拟 ID1 的译码结果
		repeat (2) waitclk();
		chk(i2x.dataFull.data.wbuCsr === WbuCsrOp_Trap, "ECALL 的 wbuCsr 错误",
		    $sformatf("wbuCsr=%b 期望 Trap", i2x.dataFull.data.wbuCsr));

		// 13) 槽1 旁路：r1Valid=2'b10（只有 lite 级就绪）-> lite 的 r1 取 r1Data[1]
		phase = 13;
		i2x.r1Valid = 2'b11;   // 两级都就绪；槽1 必须取 r1Data[1] 而不是 [0]
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);   // lite 需要 full 也在
		i12.dataLite.valid = 1'b1;
		i12.dataLite.instr = (25'd5 << 8);
		i12.dataLite.data  = '0;
		i12.dataLite.data.r1 = 1'b1;
		repeat (2) waitclk();   // lite 槽在 Id2 内部有寄存器，多等一拍
		chk(i2x.dataLite.data.r1 === 32'h5555_6666, "槽1 旁路数据错误",
		    $sformatf("r1=%h 期望 55556666 | r1Addr1=%0d r1Valid=%b r1Data1=%h lite.r1=%b instr=%h",
			i2x.dataLite.data.r1, i2x.r1Addr[1], i2x.r1Valid, i2x.r1Data[1],
			i12.dataLite.data.r1, i12.dataLite.instr));
		chk(i2x.dataLite.valid === 1'b1, "槽1 应能发射", $sformatf("valid=%b", i2x.dataLite.valid));
		i2x.r1Valid = 2'b11;
		i12.dataLite = '0;

		// 15) flush：EX1 冲刷，Id2 必须清寄存器并转发给 ID1（且优先于 ready=0）
		phase = 15;
		i2x.ready = 2'b00;
		setpkt(32'h0053_0293, Id2Imm_I, 1'b1, 1'b0, 1'b1, 1'b1);
		repeat (2) waitclk();
		i2x.flush = 1'b1;
		waitclk();
		chk(i12.flush === 1'b1, "flush 应转发给 ID1",
		    $sformatf("id1.flush=%b", i12.flush));
		chk(i2x.dataFull.valid === 1'b0, "flush 后 full.valid 应为 0",
		    $sformatf("valid=%b", i2x.dataFull.valid));
		chk(i2x.dataLite.valid === 1'b0, "flush 后 lite.valid 应为 0",
		    $sformatf("valid=%b", i2x.dataLite.valid));
		i2x.flush = 1'b0;
		i2x.ready = 2'b11;

		phase = 0;
		repeat (2) @(negedge clk);
		$display("tb: OK（波形 build/wave/id2.fst）");
		$finish;
	end
endmodule
