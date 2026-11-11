`include "interface.svh"

// Id1 唯一测试：译码器（Full/Lite）+ 流水接口 + 4 个波形场景，全部在一个波形里
// （build/wave/id1.fst）。遇到第一个错误立即 $fatal。
module tb;
	logic clk = 0, rst = 1;

	// ---- 译码器 ----
	PipeInstr   fin;  PipeId1Full  fout;  Id1Full  ufull(.in(fin), .out(fout));
	PipeInstr   lin;  PipeId1Lite lout;  Id1Lite  ulite(.in(lin), .out(lout));

	// ---- 流水 ----
	PipeIfbId1 ifb();
	PipeId1Id2 id2();
	Id1 dut(.clk(clk), .rst(rst), .ifb(ifb), .id2(id2));

	int phase = 0;
	always #5 clk = ~clk;

	typedef struct {
		logic [31:0] ins; Id2Imm imm; Ex1Al al; Ex1Bj bj; Ex3Res res; WbuCsrOp wbu;
		logic r1, r2, rd; string nm;
	} CaseF;
	CaseF dfull[17] = '{
		'{32'h0000_0037, Id2Imm_U,    Ex1Al_Imm,    Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Null , 1'b0, 1'b0, 1'b1, "LUI"},
		'{32'h0000_0097, Id2Imm_U,    Ex1Al_Add,    Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Null , 1'b0, 1'b0, 1'b1, "AUIPC"},
		'{32'h0000_00EF, Id2Imm_J,    Ex1Al_Npc,    Ex1Bj_Jump, Ex3Res_Alu , WbuCsrOp_Null , 1'b0, 1'b0, 1'b1, "JAL"},
		'{32'h0000_00E7, Id2Imm_I,    Ex1Al_Npc,    Ex1Bj_Jump, Ex3Res_Alu , WbuCsrOp_Null , 1'b1, 1'b0, 1'b1, "JALR"},
		'{32'h0000_0063, Id2Imm_B,    Ex1Al'('x),   Ex1Bj_Beq , Ex3Res_Alu , WbuCsrOp_Null , 1'b1, 1'b1, 1'b0, "BEQ"},
		'{32'h0000_0083, Id2Imm_I,    Ex1Al_Add,    Ex1Bj_Null, Ex3Res_Mem , WbuCsrOp_Null , 1'b1, 1'b0, 1'b1, "LB"},
		'{32'h0000_0023, Id2Imm_S,    Ex1Al_Add,    Ex1Bj_Null, Ex3Res_Mem , WbuCsrOp_Null , 1'b1, 1'b1, 1'b0, "SB"},
		'{32'h0000_0093, Id2Imm_I,    Ex1Al_Add,    Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Null , 1'b1, 1'b0, 1'b1, "ADDI"},
		'{32'h4000_0033, Id2Imm'('x), Ex1Al_Sub,    Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Null , 1'b1, 1'b1, 1'b1, "SUB"},
		'{32'h0200_1033, Id2Imm'('x), Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Mulh, WbuCsrOp_Null , 1'b1, 1'b1, 1'b1, "MULH"},
		'{32'h0200_5033, Id2Imm'('x), Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Div , WbuCsrOp_Null , 1'b1, 1'b1, 1'b1, "DIVU"},
		'{32'h0000_0073, Id2Imm_T,    Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Trap , 1'b0, 1'b0, 1'b0, "ECALL"},
		'{32'h0010_0073, Id2Imm_T,    Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Trap , 1'b0, 1'b0, 1'b0, "EBREAK"},
		'{32'h3020_0073, Id2Imm'('x), Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Ret  , 1'b0, 1'b0, 1'b0, "MRET"},
		'{32'h0000_1073, Id2Imm_C,    Ex1Al_Imm,    Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Write, 1'b1, 1'b0, 1'b1, "CSRRW"},
		'{32'h0000_100F, Id2Imm'('x), Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Null , 1'b0, 1'b0, 1'b0, "FENCE.I"},
		'{32'h0000_0000, Id2Imm_E,    Ex1Al'('x),   Ex1Bj_Null, Ex3Res_Alu , WbuCsrOp_Trap , 1'b0, 1'b0, 1'b0, "ILLEGAL"}
	};

	typedef struct { logic [31:0] ins; Ex1Al al; logic r2; string nm; } CaseL;
	CaseL dlite[19] = '{
		'{32'h0000_0093, Ex1Al_Add , 1'b0, "ADDI" },
		'{32'h0000_2093, Ex1Al_Slt , 1'b0, "SLTI" },
		'{32'h0000_3093, Ex1Al_Sltu, 1'b0, "SLTIU"},
		'{32'h0000_4093, Ex1Al_Xor , 1'b0, "XORI" },
		'{32'h0000_6093, Ex1Al_Or  , 1'b0, "ORI"  },
		'{32'h0000_7093, Ex1Al_And , 1'b0, "ANDI" },
		'{32'h0000_1093, Ex1Al_Sll , 1'b0, "SLLI" },
		'{32'h0000_5093, Ex1Al_Srl , 1'b0, "SRLI" },
		'{32'h4000_5093, Ex1Al_Sra , 1'b0, "SRAI" },
		'{32'h0000_0033, Ex1Al_Add , 1'b1, "ADD"  },
		'{32'h4000_0033, Ex1Al_Sub , 1'b1, "SUB"  },
		'{32'h0000_1033, Ex1Al_Sll , 1'b1, "SLL"  },
		'{32'h0000_2033, Ex1Al_Slt , 1'b1, "SLT"  },
		'{32'h0000_3033, Ex1Al_Sltu, 1'b1, "SLTU" },
		'{32'h0000_4033, Ex1Al_Xor , 1'b1, "XOR"  },
		'{32'h0000_5033, Ex1Al_Srl , 1'b1, "SRL"  },
		'{32'h4000_5033, Ex1Al_Sra , 1'b1, "SRA"  },
		'{32'h0000_6033, Ex1Al_Or  , 1'b1, "OR"   },
		'{32'h0000_7033, Ex1Al_And , 1'b1, "AND"  }
	};

	// ---- 流水刺激 ----
	localparam int N = 64;
	logic [31:0] qi[N];
	logic [31:2] qp[N];
	int n = 0, rd = 0, cyc = 0;
	logic [1:0] cq;

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

	always @(negedge clk) if (!rst) cq = ifb.consume;
	always @(posedge clk) if (!rst) begin
		cyc++;
		rd += cons(cq);
		if (rd > n) rd = n;
	end

	Id1Valid dbg_v0, dbg_v1;
	Ex1Al dbg_al_full, dbg_al_lite;
	always_comb begin
		dbg_v0 = dut.instr[0].valid;
		dbg_v1 = dut.instr[1].valid;
		dbg_al_full = id2.dataFull.data.al;
		dbg_al_lite = id2.dataLite.data.al;
	end

	task automatic chk(input bit ok, input string nm, input string got);
		if (!ok) begin
			$display("FAIL[t=%0t phase=%0d] %s", $time, phase, nm);
			if (got != "") $display("                    实际：%s", got);
			$fatal(1);
		end
	endtask

	// 逐拍核对 consume（期望由寄存器状态 + 下游 ready 独立算出）
	always @(negedge clk) if (!rst && phase >= 10) begin
		#1;
		begin
			logic empty, leftover;
			empty    = (dut.instr[0].valid==Id1Valid_Idle) && (dut.instr[1].valid==Id1Valid_Idle);
			leftover = (dut.instr[1].valid!=Id1Valid_Idle) && !id2.dataLite.valid;
			if (ifb.consume[0] !== (empty || id2.ready)) begin
				$display("FAIL[t=%0t phase=%0d] consume[0] 错：实际=%b 期望=%b（empty=%b ready=%b）",
					$time, phase, ifb.consume[0], (empty||id2.ready), empty, id2.ready);
				$display("                    寄存器 v0=%b v1=%b R0? 下游 ready=%b", dbg_v0, dbg_v1, id2.ready);
				$fatal(1);
			end
			if (ifb.consume[1] !== (empty || (id2.ready && !leftover))) begin
				$display("FAIL[t=%0t phase=%0d] consume[1] 错：实际=%b 期望=%b（empty=%b leftover=%b）",
					$time, phase, ifb.consume[1], (empty||(id2.ready&&!leftover)), empty, leftover);
				$display("                    寄存器 v0=%b v1=%b lite.valid=%b", dbg_v0, dbg_v1, id2.dataLite.valid);
				$fatal(1);
			end
		end
	end

	task automatic loadq(input int p, input int cnt);
		phase = p; n = cnt; rd = 0; cyc = 0;
		rst = 1;
		repeat (2) @(posedge clk);
		@(negedge clk); rst = 0;
	endtask

	initial begin
		$dumpfile("build/wave/id1.fst");
		$dumpvars(0, tb);

		// ===== 译码器：Id1Full 定向 =====
		phase = 1;
		fin.data.pc = 30'h2000_0000;
		foreach (dfull[i]) begin
			fin.valid = Id1Valid_Valid; fin.data.instr = dfull[i].ins; #1;
			if (fout.valid !== 1'b1 || fout.data.imm !== dfull[i].imm ||
			    fout.data.al !== dfull[i].al || fout.data.bj !== dfull[i].bj ||
			    fout.data.res !== dfull[i].res || fout.data.wbuCsr !== dfull[i].wbu ||
			    fout.data.r1 !== dfull[i].r1 || fout.data.r2 !== dfull[i].r2 ||
			    fout.data.rd !== dfull[i].rd) begin
				$display("FAIL[phase=1] Id1Full %s", dfull[i].nm);
				$display("                    实际 imm=%b al=%b bj=%b res=%b wbu=%b r1=%b r2=%b rd=%b",
					fout.data.imm, fout.data.al, fout.data.bj, fout.data.res,
					fout.data.wbuCsr, fout.data.r1, fout.data.r2, fout.data.rd);
				$fatal(1);
			end
		end

		// ===== Id1Full：Idle + 随机 =====
		phase = 2;
		fin.valid = Id1Valid_Idle; fin.data.instr = 32'hdead_beef; #1;
		chk(fout.valid === 1'b0, "Idle 槽 full.valid 应为 0", $sformatf("valid=%b", fout.valid));
		for (int i = 0; i < 20000; i++) begin
			fin.valid = Id1Valid'($urandom_range(3, 1));
			fin.data.instr = $urandom;
			fin.data.pc = 30'($urandom);
			#1;
			if (fout.valid !== 1'b1 || fout.pc !== fin.data.pc ||
			    $isunknown(fout.data.res) || $isunknown(fout.data.bj) || $isunknown(fout.data.wbuCsr)) begin
				$display("FAIL[phase=2] 随机指令：instr=%h valid=%b pc=%h/%h res=%b bj=%b wbu=%b",
					fin.data.instr, fout.valid, fin.data.pc, fout.pc,
					fout.data.res, fout.data.bj, fout.data.wbuCsr);
				$fatal(1);
			end
		end

		// ===== Id1Lite 定向 =====
		phase = 3;
		foreach (dlite[i]) begin
			lin.valid = Id1Valid_Valid; lin.data.instr = dlite[i].ins; #1;
			if (lout.valid !== 1'b1 || lout.data.al !== dlite[i].al ||
			    lout.data.r1 !== 1'b1 || lout.data.rd !== 1'b1 || lout.data.r2 !== dlite[i].r2) begin
				$display("FAIL[phase=3] Id1Lite %s", dlite[i].nm);
				$display("                    实际 valid=%b al=%b r1=%b r2=%b rd=%b",
					lout.valid, lout.data.al, lout.data.r1, lout.data.r2, lout.data.rd);
				$fatal(1);
			end
		end
		begin
			logic [31:0] bad[4] = '{32'h0000_0083, 32'h0200_0033, 32'h0000_0037, 32'h0000_0073};
			string nm[4] = '{"LB", "MUL", "LUI", "ECALL"};
			for (int i = 0; i < 4; i++) begin
				lin.valid = Id1Valid_Valid; lin.data.instr = bad[i]; #1;
				chk(lout.valid === 1'b0, $sformatf("白名单外指令 %s 应 valid=0", nm[i]),
				    $sformatf("valid=%b", lout.valid));
			end
		end

		// ===== Id1Lite 随机 =====
		phase = 4;
		for (int i = 0; i < 20000; i++) begin
			lin.valid = Id1Valid'($urandom_range(3, 1));
			lin.data.instr = $urandom;
			#1;
			if (lout.valid === 1'b1) begin
				if (lout.data.r1 !== 1'b1 || lout.data.rd !== 1'b1) begin
					$display("FAIL[phase=4] 随机 lite r1/rd 错：instr=%h", lin.data.instr); $fatal(1);
				end
				case (lout.data.al)
					Ex1Al_Add, Ex1Al_Sub, Ex1Al_Sll, Ex1Al_Slt, Ex1Al_Sltu,
					Ex1Al_Xor, Ex1Al_Srl, Ex1Al_Sra, Ex1Al_Or, Ex1Al_And : ;
					default: begin
						$display("FAIL[phase=4] 随机 lite al=%b instr=%h", lout.data.al, lin.data.instr);
						$fatal(1);
					end
				endcase
				if (lout.data.r2 !== ((lin.data.instr[6:0] == 7'b0110011) ? 1'b1 : 1'b0)) begin
					$display("FAIL[phase=4] 随机 lite r2 错：instr=%h", lin.data.instr); $fatal(1);
				end
			end
		end

		// ===== 流水：空 → 装一对 =====
		phase = 10;
		id2.ready = 1'b1;
		qi[0]=32'h0000_0033; qp[0]=30'h1000;   // ADD
		qi[1]=32'h0000_2083; qp[1]=30'h1004;   // LW
		qi[2]=32'h0000_0033; qp[2]=30'h1008;   // ADD
		qi[3]=32'h0000_0033; qp[3]=30'h100C;
		qi[4]=32'h0000_2083; qp[4]=30'h1010;   // LW
		qi[5]=32'h0000_0033; qp[5]=30'h1014;
		qi[6]=32'h0000_0033; qp[6]=30'h1018;
		qi[7]=32'h0000_0033; qp[7]=30'h101C;
		n = 8; rd = 0;
		rst = 1;
		repeat (2) @(posedge clk);
		@(negedge clk); rst = 0; #1;
		chk(ifb.consume[1] === 1'b1, "空寄存器应输出 consume=1x", $sformatf("consume=%b", ifb.consume));
		@(posedge clk); #1;
		chk(dut.instr[0].data.pc === 30'h1000 && dut.instr[1].data.pc === 30'h1004,
		    "空寄存器装入第一对错误",
		    $sformatf("寄存器 pc=(%h,%h) 期望 (1000,1004)", dut.instr[0].data.pc, dut.instr[1].data.pc));
		chk(rd === 2, "IFB 应前进 2", $sformatf("rd=%0d", rd));

		// ===== 流水：LW 在槽 1 → 上移 =====
		phase = 11;
		chk(ifb.consume === 2'b01, "LW 在槽1 应 consume=01", $sformatf("consume=%b", ifb.consume));
		@(posedge clk); #1;
		chk(dut.instr[0].data.pc === 30'h1004, "槽1 应上移到槽0",
		    $sformatf("槽0 pc=%h 期望 1004", dut.instr[0].data.pc));
		chk(dut.instr[1].data.pc === 30'h1008, "IFB[0] 应装入槽1",
		    $sformatf("槽1 pc=%h 期望 1008", dut.instr[1].data.pc));

		// ===== 流水：下游阻塞 → 保持 =====
		phase = 12;
		id2.ready = 1'b0;
		@(negedge clk); #1;
		chk(ifb.consume === 2'b00, "阻塞时应 consume=00", $sformatf("consume=%b", ifb.consume));
		@(posedge clk); #1;
		chk(dut.instr[0].data.pc === 30'h1004 && dut.instr[1].data.pc === 30'h1008,
		    "阻塞时寄存器应保持",
		    $sformatf("寄存器 pc=(%h,%h) 期望 (1004,1008)", dut.instr[0].data.pc, dut.instr[1].data.pc));

		// ===== 流水：复位后空 + 阻塞 → 预取 =====
		phase = 13;
		rst = 1'b1;
		repeat (2) @(posedge clk);
		@(negedge clk); rst = 1'b0; #1;
		chk(dut.instr[0].valid === Id1Valid_Idle && dut.instr[1].valid === Id1Valid_Idle,
		    "复位后寄存器应为空", $sformatf("v=(%b,%b)", dut.instr[0].valid, dut.instr[1].valid));
		chk(ifb.consume[1] === 1'b1, "空+阻塞 应 consume=1x（预取）", $sformatf("consume=%b", ifb.consume));
		@(posedge clk); #1;
		chk(dut.instr[0].valid === Id1Valid_Valid, "空+阻塞 仍应装入",
		    $sformatf("v0=%b", dut.instr[0].valid));

		// ===== 4 个波形场景 =====
		id2.ready = 1'b1;
		// 场景 1：8 条 ADD（进 2 条/拍）
		phase = 20;
		for (int i = 0; i < 8; i++) begin
			qi[i] = 32'h0000_0033 | ((i & 31) << 20); qp[i] = 30'(32'h1000_0000 + i);
		end
		loadq(20, 8);  repeat (6) @(negedge clk);

		// 场景 2：8 条 LW（槽1 被拦截，1 条/拍）
		phase = 21;
		for (int i = 0; i < 8; i++) begin
			qi[i] = 32'h0000_2083 | ((i & 31) << 20); qp[i] = 30'(32'h2000_0000 + i);
		end
		loadq(21, 8);  repeat (10) @(negedge clk);

		// 场景 3：4 组 (ADD + LW)
		phase = 22;
		for (int i = 0; i < 4; i++) begin
			qi[2*i]   = 32'h0000_0033 | ((i & 31) << 20); qp[2*i]   = 30'(32'h3000_0000 + 2*i);
			qi[2*i+1] = 32'h0000_2083 | ((i & 31) << 20); qp[2*i+1] = 30'(32'h3000_0000 + 2*i + 1);
		end
		loadq(22, 8);  repeat (10) @(negedge clk);

		// 场景 4：混合
		phase = 23;
		qi[0]=32'h0000_0093; qp[0]=30'(32'h0F00_0000);
		qi[1]=32'h0000_2083; qp[1]=30'(32'h0F00_0001);
		qi[2]=32'h0000_2083; qp[2]=30'(32'h0F00_0002);
		qi[3]=32'h0000_0093; qp[3]=30'(32'h0F00_0003);
		qi[4]=32'h0000_0033; qp[4]=30'(32'h0F00_0004);
		qi[5]=32'h0000_2083; qp[5]=30'(32'h0F00_0005);
		qi[6]=32'h0000_0093; qp[6]=30'(32'h0F00_0006);
		qi[7]=32'h0000_0033; qp[7]=30'(32'h0F00_0007);
		loadq(23, 8);  repeat (10) @(negedge clk);

		phase = 0;
		repeat (2) @(negedge clk);
		$display("tb: OK（波形 build/wave/id1.fst）");
		$finish;
	end
endmodule
