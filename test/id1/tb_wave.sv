`include "interface.svh"

// 波形：ADDI / LB 交替推入。复位在下降沿释放，避免初始块与 always_ff 的调度竞争。
// make wave -> build/wave/wave.vcd（--trace-structs，结构体字段可见）
module tb_wave;
	logic clk = 0, rst = 1;
	PipeIf2Id1 if2();
	PipeId1Id2 id12();
	Id1 dut(.clk(clk), .rst(rst), .pipeIf2Id1(if2), .pipeId1Id2(id12));

	logic [31:0] q[8];
	logic [31:2] pc[8];
	int rd = 0, wr = 0;
	Id1Ready rdy_q;

	// 把 DUT 内部的寄存器 valid 位镜像到测试平台层，波形里直接可见
	Id1Valid rv0, rv1;
	always_comb begin
		rv0 = dut.valid[0];
		rv1 = dut.valid[1];
	end

	always #5 clk = ~clk;

	always_comb begin
		if2.data[0] = '{valid:Id1Valid_Idle, data:'{instr:32'h0, pc:30'h0}};
		if2.data[1] = if2.data[0];
		if (rd < wr) begin
			if2.data[0] = '{valid:Id1Valid_Valid, data:'{instr:q[rd], pc:pc[rd]}};
			if (rd + 1 < wr)
				if2.data[1] = '{valid:Id1Valid_Valid, data:'{instr:q[rd+1], pc:pc[rd+1]}};
		end
	end

	// 下降沿：采样 ready（决定下一个上升沿前进几条），并打印本周期状态
	always @(negedge clk) begin
		if (!rst) begin
			rdy_q = if2.ready;
			$display("t=%0t 寄存器 pc=%h valid=(%0d,%0d) lite.valid=%b | IFB 头=(%h,%h) -> ready=%0d",
				$time, id12.dataFull.pc, rv0, rv1, id12.dataLite.valid,
				q[rd][31:7], (rd+1 < wr) ? q[rd+1][31:7] : 25'h0, rdy_q);
		end
	end

	always @(posedge clk) begin
		if (!rst) begin
			rd += int'(rdy_q);
			if (rd > wr) rd = wr;
		end
	end

	initial begin
		$dumpfile("build/wave/wave.vcd");
		$dumpvars(0, tb_wave);
		for (int i = 0; i < 8; i++) begin
			q[i]  = (i % 2 == 0) ? (32'h0000_0093 | (i << 20))   // ADDI
			                     : (32'h0000_0083 | (i << 20));  // LB
			pc[i] = 30'(32'h3000_0000 + i);
		end
		wr = 8;
		id12.ready = 1'b1;
		repeat (2) @(negedge clk);     // 复位保持
		rst = 0;                       // 在下降沿释放
		repeat (6) @(negedge clk);
		$finish;
	end
endmodule
