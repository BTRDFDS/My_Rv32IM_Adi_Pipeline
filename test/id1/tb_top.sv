`include "interface.svh"

// Id1 顶层：FIFO 模型（组合读指针 + 按 ready 前进）+ 顺序记分板
// 每个场景都要求：每条指令恰好被 ID2 侧看到一次，且顺序与推入顺序一致。
module tb_top;
	logic clk = 0, rst = 1;
	PipeIf2Id1 if2();
	PipeId1Id2 id12();
	Id1 dut(.clk(clk), .rst(rst), .pipeIf2Id1(if2), .pipeId1Id2(id12));

	localparam int N = 32;
	localparam int MAXC = 400;

	logic [31:0] q_instr[N];
	logic [31:2] q_pc[N];
	int rd = 0, wr = 0;
	int err = 0, cyc = 0, nextIdx = 0, nIssued = 0;

	always #5 clk = ~clk;

	// ---------------- FIFO 模型 ----------------
	always_comb begin
		if2.data[0] = '{valid:Id1Valid_Idle, data:'{instr:32'h0, pc:30'h0}};
		if2.data[1] = if2.data[0];
		if (rd < wr) begin
			if2.data[0] = '{valid:Id1Valid_Valid, data:'{instr:q_instr[rd], pc:q_pc[rd]}};
			if (rd + 1 < wr)
				if2.data[1] = '{valid:Id1Valid_Valid, data:'{instr:q_instr[rd+1], pc:q_pc[rd+1]}};
		end
	end

	function automatic int idx_of_pc(input logic [31:2] pc);
		for (int i = 0; i < N; i++) if (q_pc[i] === pc) return i;
		return -1;
	endfunction

	function automatic int idx_of_instr(input logic [31:7] ins);
		for (int i = 0; i < N; i++) if (q_instr[i][31:7] === ins) return i;
		return -1;
	endfunction

	// ---------------- 顺序记分板 ----------------
	always @(posedge clk) begin
		if (!rst) begin
			cyc++;
			if (id12.dataFull.valid) begin
				if (idx_of_pc(id12.dataFull.pc) != nextIdx) begin
					$display("FAIL full 顺序：pc=%h 期望第 %0d 条（pc=%h）",
						id12.dataFull.pc, nextIdx, q_pc[nextIdx]);
					err++;
				end
				nextIdx++;
				nIssued++;
			end
			if (id12.dataLite.valid) begin
				if (idx_of_instr(id12.dataLite.instr) != nextIdx) begin
					$display("FAIL lite 顺序：instr=%h 期望第 %0d 条", id12.dataLite.instr, nextIdx);
					err++;
				end
				nextIdx++;
				nIssued++;
			end
			rd += int'(if2.ready);
			if (rd > wr) rd = wr;
		end
	end

	task automatic run(input string nm, input int n);
		rst = 1;
		wr = n; rd = 0; nextIdx = 0; nIssued = 0; cyc = 0;
		id12.ready = 1'b1;
		repeat (2) @(posedge clk);
		rst = 0;
		while ((rd < wr || nextIdx < n) && cyc < MAXC) @(posedge clk);
		repeat (2) @(posedge clk);
		if (nextIdx != n) begin
			$display("FAIL %s：只发出 %0d/%0d 条（丢指令或死锁）", nm, nextIdx, n);
			err++;
		end
		$display("  %s: 发出 %0d 条", nm, nIssued);
	endtask

	initial begin
		// 场景 1：全部 lite 可发射（ADDI）
		for (int i = 0; i < N; i++) begin
			q_instr[i] = 32'h0000_0093 | (i << 20);
			q_pc[i]    = 30'(32'h2000_0000 + i);
		end
		run("全可发射", 16);

		// 场景 2：槽 1 交替出现 lite 不支持的 load
		for (int i = 0; i < N; i++) begin
			q_instr[i] = (i % 2 == 0) ? 32'h0000_0093 | (i << 20)   // ADDI
			                          : 32'h0000_0083 | (i << 20);  // LB
			q_pc[i]    = 30'(32'h3000_0000 + i);
		end
		run("交替不支持", 16);

		// 场景 3：随机混合（约三成 load）
		for (int i = 0; i < N; i++) begin
			q_instr[i] = ($urandom_range(9, 0) < 3)
				? (32'h0000_0083 | ($urandom_range(255, 0) << 20))
				: (32'h0000_0093 | ($urandom_range(255, 0) << 20));
			q_pc[i]    = 30'(32'h4000_0000 + i);
		end
		run("随机混合", 24);

		if (err == 0) $display("tb_top: ALL OK");
		else          $display("tb_top: %0d FAIL", err);
		$finish;
	end
endmodule
