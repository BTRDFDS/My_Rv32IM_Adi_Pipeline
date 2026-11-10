`include "interface.svh"

// 波形：4 个场景，IFB 行为按“呈现 = 队列头 + ready”建模（对齐由 IFB 负责，ID1 只给 ready）。
//   1: 8 条 ADD（全可发射）
//   2: 8 条 LW（lite 白名单外）
//   3: 4 组 (ADD + LW)
//   4: 随意混合
// 时钟：--timescale "1ms/1ms"，周期 10ms；复位保持 20ms；输出 FST（带枚举表）。
module tb_wave;
	logic clk = 0, rst = 1;
	PipeIf2Id1 if2();
	PipeId1Id2 id12();
	Id1 dut(.clk(clk), .rst(rst), .pipeIf2Id1(if2), .pipeId1Id2(id12));

	localparam int N = 32;
	logic [31:0] q[ N];
	logic [31:2] qpc[N];
	int n = 0, rd = 0;
	int phase = 0;
	Id1Ready rdy_q;

	// 波形里直接看枚举名用的镜像信号（VCD/FST 只有位值，枚举名靠类型表）
	Id1Valid dbg_valid0, dbg_valid1;
	Ex1Al    dbg_al_full, dbg_al_lite;
	Id2Imm   dbg_imm;
	always_comb begin
		dbg_valid0  = dut.valid[0];
		dbg_valid1  = dut.valid[1];
		dbg_al_full = id12.dataFull.data.al;
		dbg_al_lite = id12.dataLite.data.al;
		dbg_imm     = id12.dataFull.data.imm;
	end

	always #5 clk = ~clk;

	function automatic string name_valid(input Id1Valid v);
		case (v)
			Id1Valid_Idle:  return "Idle";
			Id1Valid_Valid: return "Valid";
			Id1Valid_Fall:  return "Fall";
			default:        return "Un4b";
		endcase
	endfunction

	// 测试平台自己实现的白名单，用来独立算期望 ready
	function automatic bit lite_ok(input logic [31:0] i);
		logic [6:0] op = i[6:0];
		logic [2:0] f3 = i[14:12];
		logic [6:0] f7 = i[31:25];
		case (op)
			7'b0010011: case (f3)
				3'b000,3'b010,3'b011,3'b100,3'b110,3'b111: lite_ok = 1'b1;
				3'b001: lite_ok = (f7 == 7'b0000000);
				3'b101: lite_ok = (f7 == 7'b0000000) || (f7 == 7'b0100000);
				default: lite_ok = 1'b0;
			endcase
			7'b0110011: case (f3)
				3'b000,3'b101: lite_ok = (f7 == 7'b0000000) || (f7 == 7'b0100000);
				3'b001,3'b010,3'b011,3'b100,3'b110,3'b111: lite_ok = (f7 == 7'b0000000);
				default: lite_ok = 1'b0;
			endcase
			default: lite_ok = 1'b0;
		endcase
	endfunction

	// IFB 模型：呈现 q[rd + ready]，指针按 ready 前进
	always_comb begin
		int base;
		base = rd + int'(rdy_q);
		if2.data[0] = '{valid:Id1Valid_Idle, data:'{instr:32'h0, pc:30'h0}};
		if2.data[1] = if2.data[0];
		if (base < n) begin
			if2.data[0] = '{valid:Id1Valid_Valid, data:'{instr:q[base], pc:qpc[base]}};
			if (base + 1 < n)
				if2.data[1] = '{valid:Id1Valid_Valid, data:'{instr:q[base+1], pc:qpc[base+1]}};
		end
	end

	always @(negedge clk) if (!rst) rdy_q = if2.ready;
	always @(posedge clk) if (!rst) begin
		rd += int'(rdy_q);
		if (rd > n) rd = n;
	end

	task automatic reset_dut();
		rst = 1;
		repeat (2) @(posedge clk);
		@(negedge clk);
		rst = 0;
		rd = 0;
		rdy_q = Id1Ready_0;
	endtask

	task automatic run(input int cnt);
		for (int i = 0; i < cnt; i++) @(negedge clk);
	endtask

	always @(negedge clk) begin
		#1;
		if (!rst) begin
			Id1Ready exp;
			if (!id12.ready)                          exp = Id1Ready_0;
			else if (dut.valid[0] === Id1Valid_Idle)  exp = Id1Ready_0;
			else if (dut.valid[1] !== Id1Valid_Idle && lite_ok(dut.data[1].instr))
			                                          exp = Id1Ready_2;
			else                                      exp = Id1Ready_1;
			// 正确不打印；只在 ready 与期望不符时报错
			if (if2.ready !== exp)
				$display("FAIL t=%0t phase=%0d 呈现 pc=(%h,%h) 寄存器 valid=(%s,%s) full.valid=%b lite.valid=%b => ready=%0d 期望 %0d",
					$time, phase,
					(rd + int'(rdy_q) < n)     ? qpc[rd + int'(rdy_q)]     : 30'h0,
					(rd + int'(rdy_q) + 1 < n) ? qpc[rd + int'(rdy_q) + 1] : 30'h0,
					name_valid(dut.valid[0]), name_valid(dut.valid[1]),
					id12.dataFull.valid, id12.dataLite.valid, if2.ready, exp);
		end
	end

	initial begin
		$dumpfile("build/wave/wave.fst");
		$dumpvars(0, tb_wave);
		id12.ready = 1'b1;
		rdy_q = Id1Ready_0;
		repeat (2) @(posedge clk);

		// 场景 1：8 条 ADD（R 型）
		phase = 1; n = 8;
		for (int i = 0; i < 8; i++) begin
			q[i]   = 32'h0000_0033 | ((i & 31) << 20);
			qpc[i] = 30'(32'h1000_0000 + i);
		end
		reset_dut(); run(8);

		// 场景 2：8 条 LW
		phase = 2; n = 8;
		for (int i = 0; i < 8; i++) begin
			q[i]   = 32'h0000_2083 | ((i & 31) << 20);
			qpc[i] = 30'(32'h2000_0000 + i);
		end
		reset_dut(); run(10);

		// 场景 3：4 组 (ADD + LW)
		phase = 3; n = 8;
		for (int i = 0; i < 4; i++) begin
			q[2*i]     = 32'h0000_0033 | ((i & 31) << 20);
			qpc[2*i]   = 30'(32'h3000_0000 + 2*i);
			q[2*i+1]   = 32'h0000_2083 | ((i & 31) << 20);
			qpc[2*i+1] = 30'(32'h3000_0000 + 2*i + 1);
		end
		reset_dut(); run(10);

		// 场景 4：混合
		phase = 4; n = 8;
		q[0]=32'h0000_0093; qpc[0]=30'(32'h0F00_0000);  // ADDI
		q[1]=32'h0000_2083; qpc[1]=30'(32'h0F00_0001);  // LW
		q[2]=32'h0000_2083; qpc[2]=30'(32'h0F00_0002);  // LW
		q[3]=32'h0000_0093; qpc[3]=30'(32'h0F00_0003);  // ADDI
		q[4]=32'h0000_0033; qpc[4]=30'(32'h0F00_0004);  // ADD
		q[5]=32'h0000_2083; qpc[5]=30'(32'h0F00_0005);  // LW
		q[6]=32'h0000_0093; qpc[6]=30'(32'h0F00_0006);  // ADDI
		q[7]=32'h0000_0033; qpc[7]=30'(32'h0F00_0007);  // ADD
		reset_dut(); run(10);

		phase = 0; run(2);
		$finish;
	end
endmodule
