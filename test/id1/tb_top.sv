`include "interface.svh"

// Id1（保留输入 pipeReg，输入端正确性由 IFB 保证）：
//   寄存器在 pipeId1Id2.ready=1 的时钟沿装入 (data[0],data[1])；
//   装入后一拍输出对应译码；下游 ready=0 时寄存器保持。
// 验证三件事：
//   1) 装入后一拍的译码字段正确
//   2) 下游 ready=0 时寄存器保持
//   3) ready 三态：0 = 槽0空或下游阻塞；1 = 槽0有效、槽1不可发射；2 = 槽0、槽1都可发射
module tb_top;
	logic clk = 0, rst = 1;
	PipeIf2Id1 if2();
	PipeId1Id2 id12();
	Id1 dut(.clk(clk), .rst(rst), .pipeIf2Id1(if2), .pipeId1Id2(id12));

	int err = 0;
	always #5 clk = ~clk;

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

	task automatic present(input logic [31:0] i0, input logic [31:2] p0, input Id1Valid v0,
	                       input logic [31:0] i1, input logic [31:2] p1, input Id1Valid v1);
		if2.data[0] = '{valid:v0, data:'{instr:i0, pc:p0}};
		if2.data[1] = '{valid:v1, data:'{instr:i1, pc:p1}};
	endtask

	task automatic chk(input bit ok, input string nm);
		if (!ok) begin $display("FAIL %s", nm); err++; end
	endtask

	// 检查 ready 三态是否等于按“寄存器内容 + 下游 ready”算出的期望
	task automatic chk_ready(input string nm);
		Id1Ready exp;
		if (!id12.ready)                        exp = Id1Ready_0;
		else if (!id12.dataFull.valid)          exp = Id1Ready_0;
		else if (id12.dataLite.valid)           exp = Id1Ready_2;
		else                                    exp = Id1Ready_1;
		if (if2.ready !== exp) begin
			$display("FAIL ready %s：得到 %0d 期望 %0d", nm, if2.ready, exp);
			err++;
		end
	endtask

	initial begin
		id12.ready = 1'b1;
		present(32'h0, 30'h0, Id1Valid_Idle, 32'h0, 30'h0, Id1Valid_Idle);
		repeat (2) @(posedge clk);
		rst = 0;

		// 1) 空：ready_0
		present(32'h0, 30'h0, Id1Valid_Idle, 32'h0, 30'h0, Id1Valid_Idle);
		@(posedge clk); #1;
		chk_ready("空");

		// 2) ADDI + ADD：装入后一拍，字段与 ready_2
		present(32'h0050_0093, 30'h1000, Id1Valid_Valid,   // ADDI x1,x0,5
		        32'h0020_80B3, 30'h1004, Id1Valid_Valid);  // ADD  x1,x1,x2
		@(posedge clk); #1;
		chk(id12.dataFull.valid === 1'b1, "full valid");
		chk(id12.dataFull.pc === 30'h1000, "full pc");
		chk(id12.dataFull.data.imm === Id2Imm_I, "ADDI 立即数格式");
		chk(id12.dataFull.data.al === Ex1Al_Add, "ADDI al");
		chk(id12.dataFull.data.rd === 5'd1, "ADDI rd");
		chk(id12.dataLite.valid === 1'b1, "lite valid");
		chk(id12.dataLite.data.al === Ex1Al_Add, "ADD al");
		chk_ready("ADDI+ADD");

		// 3) ADDI + LB：槽1 白名单外 -> ready_1
		present(32'h0040_0093, 30'h1008, Id1Valid_Valid,   // ADDI x1,x0,4
		        32'h0000_2083, 30'h100C, Id1Valid_Valid);  // LW   x1,0(x0)
		@(posedge clk); #1;
		chk(id12.dataFull.valid === 1'b1, "LB 包的 full valid");
		chk(id12.dataLite.valid === 1'b0, "LW 不在 lite 白名单 -> lite.valid=0");
		chk_ready("ADDI+LW");

		// 4) ADDI + Idle：只有一条 -> ready_1
		present(32'h0060_0093, 30'h1010, Id1Valid_Valid,
		        32'h0, 30'h0, Id1Valid_Idle);
		@(posedge clk); #1;
		chk(id12.dataFull.valid === 1'b1, "单条 full valid");
		chk(id12.dataLite.valid === 1'b0, "单条 lite valid=0");
		chk_ready("单条");

		// 5) 下游阻塞：寄存器保持，ready_0
		present(32'h0070_0093, 30'h1014, Id1Valid_Valid,
		        32'h0000_0033, 30'h1018, Id1Valid_Valid);
		@(posedge clk); #1;
		id12.ready = 1'b0;
		present(32'h0080_0093, 30'h101C, Id1Valid_Valid,   // 新包
		        32'h0000_0083, 30'h1020, Id1Valid_Valid);
		repeat (2) @(posedge clk); #1;
		chk(id12.dataFull.pc === 30'h1014, "阻塞时寄存器保持 pc");
		chk(id12.dataLite.valid === 1'b1, "阻塞时寄存器保持（槽1 仍是 ADD）");
		chk_ready("阻塞");
		id12.ready = 1'b1;
		@(posedge clk); #1;
		chk(id12.dataFull.pc === 30'h101C, "解除阻塞后装入新包");
		chk_ready("解除阻塞");

		// 6) 连续装入：每拍装入的包在下一拍出现在输出上，不重不漏
		for (int k = 0; k < 8; k++) begin
			present(32'h0000_0093 | (k << 20), 30'(32'h2000_0000 + k),
			        Id1Valid_Valid,
			        32'h0000_0033 | (k << 20), 30'(32'h2000_0010 + k),
			        Id1Valid_Valid);
			@(posedge clk); #1;
			chk(id12.dataFull.pc === 30'(32'h2000_0000 + k), "连续装入 pc 对齐");
			chk(id12.dataFull.data.rd === 5'd1 && id12.dataLite.valid === 1'b1, "连续装入字段");
			chk_ready("连续装入");
		end

		// 7) pipeReady（= pipeId1Id2.ready）的正确性
		// 7a) 两槽独立装入：只槽0有效、只槽1有效
		present(32'h0000_0093, 30'h3000, Id1Valid_Valid, 32'h0, 30'h0, Id1Valid_Idle);
		@(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Valid && dut.valid[1] === Id1Valid_Idle, "只槽0有效");
		chk(if2.ready === Id1Ready_1, "单条 ready_1");

		present(32'h0, 30'h0, Id1Valid_Idle, 32'h0000_0033, 30'h3004, Id1Valid_Valid);
		@(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Idle && dut.valid[1] === Id1Valid_Valid, "只槽1有效");
		chk(if2.ready === Id1Ready_0, "槽0空时 ready_0");

		// 7b) 下游 ready=0 时 valid 与 data 都保持（两槽）
		present(32'h0000_0093, 30'h3008, Id1Valid_Valid, 32'h0000_0033, 30'h300C, Id1Valid_Valid);
		@(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Valid && dut.valid[1] === Id1Valid_Valid, "两槽都装入");
		id12.ready = 1'b0;
		present(32'h0000_0083, 30'h3010, Id1Valid_Valid, 32'h0000_0083, 30'h3014, Id1Valid_Valid);
		repeat (3) @(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Valid && dut.valid[1] === Id1Valid_Valid, "阻塞时两槽 valid 保持");
		chk(dut.data[0].instr === 32'h0000_0093 && dut.data[1].instr === 32'h0000_0033, "阻塞时两槽 data 保持");
		chk(dut.data[0].pc === 30'h3008 && dut.data[1].pc === 30'h300C, "阻塞时两槽 pc 保持");
		chk(if2.ready === Id1Ready_0, "阻塞时 ready_0");

		// 7c) 复位优先级：rst=1 且下游 ready=0，valid 仍被清成 Idle（data 不复位）
		rst = 1;
		@(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Idle && dut.valid[1] === Id1Valid_Idle, "复位清 valid（与 ready 无关）");
		chk(if2.ready === Id1Ready_0, "复位后 ready_0");
		rst = 0; id12.ready = 1'b1;
		present(32'h0000_0093, 30'h3018, Id1Valid_Valid, 32'h0000_0033, 30'h301C, Id1Valid_Valid);
		@(posedge clk); #1;
		chk(dut.valid[0] === Id1Valid_Valid && dut.valid[1] === Id1Valid_Valid, "复位释放后可正常装入");

		if (err != 0) $display("tb_top: %0d FAIL", err);
		$finish;
	end
endmodule
