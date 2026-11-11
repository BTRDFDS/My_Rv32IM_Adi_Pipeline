`include "interface.svh"

// 波形：ID1（PipeIfbId1 / PipeId1Id2）。IFB 模型按 consume 前进。
//   1: 8 条 ADD      2: 8 条 LW      3: 4 组 (ADD+LW)      4: 混合
// 时钟 --timescale "1ms/1ms" -> 周期 10ms，复位 20ms；输出 FST（带枚举表）。
module tb_wave;
	logic clk = 0, rst = 1;
	PipeIfbId1 ifb();
	PipeId1Id2 id2();
	Id1 dut(.clk(clk), .rst(rst), .ifb(ifb), .id2(id2));

	localparam int N = 32;
	logic [31:0] qi[N];
	logic [31:2] qp[N];
	int n = 0, rd = 0, phase = 0;
	logic [1:0] cq;

	// 波形里直接看枚举名的镜像
	Id1Valid dbg_valid0, dbg_valid1;
	Ex1Al    dbg_al_full, dbg_al_lite;

	always #5 clk = ~clk;

	function automatic int cons(input logic [1:0] x);
		return x[1] ? 2 : (x[0] ? 1 : 0);
	endfunction

	always_comb begin
		ifb.instr[0] = '{valid:Id1Valid_Idle, data:'{instr:32'h0, pc:30'h0}};
		ifb.instr[1] = ifb.instr[0];
		if (rd < n) begin
			ifb.instr[0] = '{valid:Id1Valid_Valid, data:'{instr:qi[rd], pc:qp[rd]}};
			if (rd + 1 < n)
				ifb.instr[1] = '{valid:Id1Valid_Valid, data:'{instr:qi[rd+1], pc:qp[rd+1]}};
		end
		dbg_valid0  = dut.instr[0].valid;
		dbg_valid1  = dut.instr[1].valid;
		dbg_al_full = id2.dataFull.data.al;
		dbg_al_lite = id2.dataLite.data.al;
	end

	// 下降沿采样 consume，上升沿按它推进 IFB 读指针
	always @(negedge clk) if (!rst) cq = ifb.consume;
	always @(posedge clk) if (!rst) begin
		rd += cons(cq);
		if (rd > n) rd = n;
	end

	task automatic load(input int p, input int cnt);
		phase = p;
		n = cnt;
		rd = 0;
		rst = 1;
		repeat (2) @(posedge clk);
		@(negedge clk);
		rst = 0;
	endtask

	initial begin
		$dumpfile("build/wave/wave.fst");
		$dumpvars(0, tb_wave);
		id2.ready = 1'b1;
		cq = 2'b00;
		repeat (2) @(posedge clk);

		// 场景 1：8 条 ADD
		for (int i = 0; i < 8; i++) begin
			qi[i] = 32'h0000_0033 | ((i & 31) << 20);
			qp[i] = 30'(32'h1000_0000 + i);
		end
		load(1, 8);  repeat (6) @(negedge clk);

		// 场景 2：8 条 LW
		for (int i = 0; i < 8; i++) begin
			qi[i] = 32'h0000_2083 | ((i & 31) << 20);
			qp[i] = 30'(32'h2000_0000 + i);
		end
		load(2, 8);  repeat (10) @(negedge clk);

		// 场景 3：4 组 (ADD + LW)
		for (int i = 0; i < 4; i++) begin
			qi[2*i]   = 32'h0000_0033 | ((i & 31) << 20);
			qp[2*i]   = 30'(32'h3000_0000 + 2*i);
			qi[2*i+1] = 32'h0000_2083 | ((i & 31) << 20);
			qp[2*i+1] = 30'(32'h3000_0000 + 2*i + 1);
		end
		load(3, 8);  repeat (10) @(negedge clk);

		// 场景 4：混合
		qi[0]=32'h0000_0093; qp[0]=30'(32'h0F00_0000);  // ADDI
		qi[1]=32'h0000_2083; qp[1]=30'(32'h0F00_0001);  // LW
		qi[2]=32'h0000_2083; qp[2]=30'(32'h0F00_0002);  // LW
		qi[3]=32'h0000_0093; qp[3]=30'(32'h0F00_0003);  // ADDI
		qi[4]=32'h0000_0033; qp[4]=30'(32'h0F00_0004);  // ADD
		qi[5]=32'h0000_2083; qp[5]=30'(32'h0F00_0005);  // LW
		qi[6]=32'h0000_0093; qp[6]=30'(32'h0F00_0006);  // ADDI
		qi[7]=32'h0000_0033; qp[7]=30'(32'h0F00_0007);  // ADD
		load(4, 8);  repeat (10) @(negedge clk);

		phase = 0;
		repeat (2) @(negedge clk);
		$display("tb_wave: OK（波形 build/wave/wave.fst）");
		$finish;
	end
endmodule
