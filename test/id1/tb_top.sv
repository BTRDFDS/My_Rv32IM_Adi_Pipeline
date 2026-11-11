`include "interface.svh"

// Id1（PipeIfbId1 / PipeId1Id2）：
//   consume=2'b10 -> IFB 前进 2；2'b01 -> 前进 1；2'b00 -> 不动
// IFB 模型：呈现 q[rd]/q[rd+1]（rd 指向“第一条还没进 ID1 的指令”），按 consume 前进。
module tb_top;
	logic clk = 0, rst = 1;
	PipeIfbId1 ifb();
	PipeId1Id2 id2();
	Id1 dut(.clk(clk), .rst(rst), .ifb(ifb), .id2(id2));

	int err = 0, rd = 0, n = 0;
	logic [31:0] qi[16];
	logic [31:2] qp[16];
	logic [1:0] c;

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
	end

	task automatic chk(input bit ok, input string nm);
		if (!ok) begin
			$display("FAIL %-22s consume=%b 寄存器=(%h,%h) rd=%0d",
				nm, ifb.consume, dut.instr[0].data.pc, dut.instr[1].data.pc, rd);
			err++;
		end
	endtask

	// 一个周期：先取本拍 consume，再等 posedge（装入/推进），最后按它推进 rd
	task automatic tick();
		c = ifb.consume;
		@(posedge clk); #1;
		rd += cons(c);
		if (rd > n) rd = n;
	endtask

	initial begin
		id2.ready = 1'b1;
		n = 8;
		qi[0]=32'h0000_0033; qp[0]=30'h1000;   // ADD
		qi[1]=32'h0000_2083; qp[1]=30'h1004;   // LW
		qi[2]=32'h0000_0033; qp[2]=30'h1008;   // ADD
		qi[3]=32'h0000_0033; qp[3]=30'h100C;   // ADD
		qi[4]=32'h0000_2083; qp[4]=30'h1010;   // LW
		qi[5]=32'h0000_0033; qp[5]=30'h1014;
		qi[6]=32'h0000_0033; qp[6]=30'h1018;
		qi[7]=32'h0000_0033; qp[7]=30'h101C;

		repeat (2) @(posedge clk);
		@(negedge clk); rst = 0; #1;

		// 1) 空寄存器：consume=10
		chk(ifb.consume[1] === 1'b1, "空: consume=10");
		tick();
		chk(dut.instr[0].data.pc === 30'h1000 && dut.instr[1].data.pc === 30'h1004, "空: 装入第一对");
		chk(rd === 2, "空: IFB 前进 2");

		// 2) 槽1 = LW：consume=01；下一拍寄存器应为 (旧槽1, IFB[0])
		chk(ifb.consume[1] === 1'b0 && ifb.consume[0] === 1'b1, "LW 在槽1: consume=01");
		tick();
		chk(dut.instr[0].data.pc === 30'h1004, "槽1 上移到槽0");
		chk(dut.instr[1].data.pc === 30'h1008, "IFB[0] 装入槽1");
		chk(rd === 3, "IFB 前进 1");

		// 3) 下游阻塞：consume=00，寄存器保持
		id2.ready = 1'b0;
		@(negedge clk); #1;
		chk(ifb.consume === 2'b00, "阻塞: consume=00");
		tick();
		chk(dut.instr[0].data.pc === 30'h1004 && dut.instr[1].data.pc === 30'h1008, "阻塞: 寄存器保持");
		chk(rd === 3, "阻塞: IFB 不动");

		// 4) 复位后空且阻塞：consume=10（预取）
		rst = 1'b1;
		repeat (2) @(posedge clk);
		@(negedge clk); rst = 1'b0; #1;
		chk(dut.instr[0].valid === Id1Valid_Idle && dut.instr[1].valid === Id1Valid_Idle, "复位后空");
		chk(ifb.consume[1] === 1'b1, "空+阻塞: consume=10 预取");
		tick();
		chk(dut.instr[0].valid === Id1Valid_Valid, "空+阻塞: 仍然装入");
		chk(rd === 5, "空+阻塞: IFB 前进 2");

		if (err == 0) $display("tb_top: OK");
		else          $display("tb_top: %0d FAIL", err);
		$finish;
	end
endmodule
