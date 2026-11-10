`include "interface.svh"

// Id1Full：定向用例 + 随机指令的“控制字段不得为 X”检查
module tb_full;
	PipeInstr   in;
	PipeId1Full out;
	Id1Full dut(.in(in), .out(out));

	int err = 0;

	typedef struct {
		logic [31:0] ins;
		Id2Imm   imm;
		Ex1Al    al;
		Ex1Bj    bj;
		Ex3Res   res;
		WbuCsrOp wbu;
		logic r1, r2, rd;
		string nm;
	} CaseF;

	CaseF dir[17] = '{
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

	initial begin
		// 定向用例
		in.data.pc = 30'h2000_0000;
		foreach (dir[i]) begin
			in.valid      = Id1Valid_Valid;
			in.data.instr = dir[i].ins;
			#1;
			if (out.valid !== 1'b1 ||
			    out.data.imm  !== dir[i].imm || out.data.al !== dir[i].al ||
			    out.data.bj   !== dir[i].bj  || out.data.res !== dir[i].res ||
			    out.data.wbuCsr !== dir[i].wbu ||
			    out.data.r1 !== dir[i].r1 || out.data.r2 !== dir[i].r2 || out.data.rd !== dir[i].rd) begin
				$display("FAIL %-8s imm=%b al=%b bj=%b res=%b wbu=%b r1=%b r2=%b rd=%b",
					dir[i].nm, out.data.imm, out.data.al, out.data.bj, out.data.res,
					out.data.wbuCsr, out.data.r1, out.data.r2, out.data.rd);
				err++;
			end
		end

		// Idle 槽：无论指令是什么，valid 必须为 0
		in.valid = Id1Valid_Idle; in.data.instr = 32'hdead_beef; #1;
		if (out.valid !== 1'b0) begin $display("FAIL idle"); err++; end

		// 随机指令：valid 只由 in.valid 决定；控制字段不得为 X
		for (int i = 0; i < 20000; i++) begin
			in.valid      = Id1Valid'($urandom_range(3, 1));   // Valid / Fall / Un4b
			in.data.instr = $urandom;
			in.data.pc    = 30'($urandom);
			#1;
			if (out.valid !== 1'b1) begin $display("FAIL rand valid"); err++; end
			if (out.pc !== in.data.pc) begin $display("FAIL rand pc"); err++; end
			if ($isunknown(out.data.res) || $isunknown(out.data.bj) || $isunknown(out.data.wbuCsr)) begin
				$display("FAIL rand X on control: instr=%h res=%b bj=%b wbu=%b",
					in.data.instr, out.data.res, out.data.bj, out.data.wbuCsr);
				err++;
			end
		end

		if (err != 0) $display("tb_full: %0d FAIL", err);
		$finish;
	end
endmodule
