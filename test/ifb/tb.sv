`include "interface.svh"

// ifb 唯一测试：全部场景在一个波形里（build/wave/ifb.fst），遇到第一个错误立即 $fatal。
// 场景：1 恒取 2 / 2 周期性停顿 / 3 混合 1-2-0 / 4 IF2 中途空包 / 5 下游长停顿写满 FIFO
//
// 检查：
//   A. 握手不变量：pipeReady(=if2.ready) 为 1 且寄存器有数据时，这一拍必须真的写进 FIFO，
//      否则寄存器会被覆盖，上游却以为已接收 —— 立即报错。
//   B. 输出流：呈现的一对必须等于期望的下两条。
//   C. 每段结束：必须全部取完。
module tb;
	logic clk = 0, rst = 1;
	PipeIf2Ifb if2();
	PipeIfbId1 id1();
	ifb dut(.clk(clk), .rst(rst), .if2(if2), .id1(id1));

	localparam int N = 64;
	logic [31:0] ins[N];
	logic [31:2] pcv[N];
	int n = 0, pw = 0, pr = 0, phase = 0, cyc = 0;
	int stall_at = 0, bub_at = 0;

	always #5 clk = ~clk;

	function automatic int cons(input logic [1:0] x);
		return x[1] ? 2 : (x[0] ? 1 : 0);
	endfunction

	function automatic string pcs(input int from, input int cnt);
		string s;
		s = "";
		for (int i = 0; i < cnt && from + i < n; i++)
			s = {s, $sformatf("%h ", pcv[from+i])};
		return s;
	endfunction

	always_comb begin
		if2.instr[0] = '{valid:Id1Valid_Idle, data:'{instr:32'h0, pc:30'h0}};
		if2.instr[1] = if2.instr[0];
		if (bub_at > 0 && cyc >= bub_at && cyc < bub_at + 2) begin end
		else if (pw < n) begin
			if2.instr[0] = '{valid:Id1Valid_Valid, data:'{instr:ins[pw], pc:pcv[pw]}};
			if (pw + 1 < n)
				if2.instr[1] = '{valid:Id1Valid_Valid, data:'{instr:ins[pw+1], pc:pcv[pw+1]}};
		end
	end

	always_comb begin
		logic [1:0] c;
		c = 2'b00;
		if (stall_at > 0 && cyc >= stall_at && cyc < stall_at + 24) c = 2'b00;
		else if (id1.instr[0].valid != Id1Valid_Idle) begin
			case (phase)
				2: c = (cyc % 3 == 0) ? 2'b00 : 2'b11;
				3: c = (cyc % 5 == 0) ? 2'b01 : ((cyc % 7 == 0) ? 2'b00 : 2'b11);
				default: c = 2'b11;
			endcase
		end
		id1.consume = c;
	end

	Id1Valid dbg_v0, dbg_v1;
	always_comb begin
		dbg_v0 = id1.instr[0].valid;
		dbg_v1 = id1.instr[1].valid;
	end

	// 握手不变量 + 生产指针推进（按实际写入量）
	always @(posedge clk) if (!rst) begin
		cyc++;
		if (dut.pipeReady && dut.instr[0].valid != Id1Valid_Idle && !dut.fifoWvalid) begin
			$display("FAIL[t=%0t phase=%0d] 握手违例：pipeReady(=if2.ready)=1 但 FIFO 满，寄存器将被覆盖",
				$time, phase);
			$display("                    丢失 pc=%h %h | R0=%0d W0=%0d fifoWvalid=0 已写 pw=%0d 已取 pr=%0d",
				dut.instr[0].data.pc, dut.instr[1].data.pc, dut.fifoR0, dut.fifoW0, pw, pr);
			$fatal(1);
		end
		// 生产者按 pipeReady(=if2.ready) 握手推进
		if (dut.pipeReady && pw < n && if2.instr[0].valid != Id1Valid_Idle)
			pw += (pw + 1 < n && if2.instr[1].valid != Id1Valid_Idle) ? 2 : 1;
		pr += cons(id1.consume);
		if (pr > n) pr = n;
	end

	// 输出流检查
	always @(negedge clk) if (!rst) begin
		if (pr < n && id1.instr[0].valid != Id1Valid_Idle &&
		    id1.instr[0].data.pc !== pcv[pr]) begin
			$display("FAIL[t=%0t phase=%0d] 输出顺序错：期望第 %0d 条 pc=%h，实际 pc=%h",
				$time, phase, pr, pcv[pr], id1.instr[0].data.pc);
			$display("                    实际 R0=%0d W0=%0d out_v=%b%b consume=%b 已写 pw=%0d 已取 pr=%0d",
				dut.fifoR0, dut.fifoW0, id1.instr[0].valid, id1.instr[1].valid, id1.consume, pw, pr);
			$display("                    缺失/多余区间：期望从 pc=%h 起，实际给出 pc=%h",
				pcv[pr], id1.instr[0].data.pc);
			$fatal(1);
		end
	end

	task automatic run(input int p, input int cnt, input int b_at, input int s_at);
		phase = p; n = cnt; pw = 0; pr = 0; cyc = 0; bub_at = b_at; stall_at = s_at;
		for (int i = 0; i < n; i++) begin
			ins[i] = 32'h0000_0093 | ((i & 255) << 20);
			pcv[i] = 30'(32'h1000_0000 + i);
		end
		rst = 1;
		repeat (2) @(posedge clk);
		@(negedge clk); rst = 0;
		while (pr < n && cyc < 4000) @(negedge clk);
		repeat (2) @(negedge clk);
		if (pr != n) begin
			$display("FAIL[t=%0t phase=%0d] 只取到 %0d/%0d 条", $time, phase, pr, n);
			$display("                    已取到 pc=%h；缺失 pc=%h ...", pcv[pr-1], pcv[pr]);
			$display("                    实际 R0=%0d W0=%0d out_v=%b%b consume=%b 已写 pw=%0d",
				dut.fifoR0, dut.fifoW0, id1.instr[0].valid, id1.instr[1].valid, id1.consume, pw);
			$fatal(1);
		end
	endtask

	initial begin
		$dumpfile("build/wave/ifb.fst");
		$dumpvars(0, tb);
		run(1, 32, 0, 0);   // 恒取 2
		run(2, 32, 0, 0);   // 周期性停顿
		run(3, 48, 0, 0);   // 混合
		run(4, 32, 6, 0);   // IF2 中途空包
		run(5, 48, 0, 6);   // 下游长停顿，把 FIFO 写满
		phase = 0;
		repeat (2) @(negedge clk);
		$display("tb: OK（波形 build/wave/ifb.fst）");
		$finish;
	end
endmodule
