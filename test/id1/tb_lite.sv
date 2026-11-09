`include "interface.svh"

// Id1Lite：19 条白名单（I 型 9 + R 型 10）+ 不支持指令 + 随机指令
module tb_lite;
	PipeInstr   in;
	PipeId1Lite out;
	Id1Lite dut(.in(in), .out(out));

	int err = 0;

	typedef struct {
		logic [31:0] ins;
		Ex1Al  al;
		logic  r2;
		string nm;
	} CaseL;

	CaseL dir[19] = '{
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

	initial begin
		// 定向用例
		foreach (dir[i]) begin
			in.valid      = Id1Valid_Valid;
			in.data.instr = dir[i].ins;
			#1;
			if (out.valid !== 1'b1 || out.data.al !== dir[i].al ||
			    out.data.r1 !== 1'b1 || out.data.rd !== 1'b1 || out.data.r2 !== dir[i].r2) begin
				$display("FAIL %-5s valid=%b al=%b r1=%b r2=%b rd=%b",
					dir[i].nm, out.valid, out.data.al, out.data.r1, out.data.r2, out.data.rd);
				err++;
			end
		end

		// 不在白名单里的指令：valid 必须为 0
		begin
			logic [31:0] bad[4] = '{32'h0000_0083, 32'h0200_0033, 32'h0000_0037, 32'h0000_0073};
			string  nm[4] = '{"LB", "MUL", "LUI", "ECALL"};
			for (int i = 0; i < 4; i++) begin
				in.valid = Id1Valid_Valid; in.data.instr = bad[i]; #1;
				if (out.valid !== 1'b0) begin $display("FAIL unsupported %s", nm[i]); err++; end
			end
		end

		// 随机指令：valid=1 时 al/r1/rd/r2 必须与白名单一致
		for (int i = 0; i < 20000; i++) begin
			in.valid      = Id1Valid'($urandom_range(3, 1));
			in.data.instr = $urandom;
			#1;
			if (out.valid === 1'b1) begin
				if (out.data.r1 !== 1'b1 || out.data.rd !== 1'b1) begin
					$display("FAIL rand r1/rd"); err++;
				end
				case (out.data.al)
					Ex1Al_Add, Ex1Al_Sub, Ex1Al_Sll, Ex1Al_Slt, Ex1Al_Sltu,
					Ex1Al_Xor, Ex1Al_Srl, Ex1Al_Sra, Ex1Al_Or, Ex1Al_And : ;
					default: begin $display("FAIL rand al=%b", out.data.al); err++; end
				endcase
				if (out.data.r2 !== ((in.data.instr[6:0] == 7'b0110011) ? 1'b1 : 1'b0)) begin
					$display("FAIL rand r2: instr=%h", in.data.instr); err++;
				end
			end
		end

		if (err == 0) $display("tb_lite: ALL OK");
		else          $display("tb_lite: %0d FAIL", err);
		$finish;
	end
endmodule
