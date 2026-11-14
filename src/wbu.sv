`include "interface.svh"
module wbu (
	input logic clk,rst,
	pipeWb.in   pipeWb,
	ImmeData.wbu immeData
);
	logic [1:0] valid;
	PackRd rd[1:0];
	PackSr sr;
	always_ff @(posedge clk) valid <= rst? 2'b00:pipeWb.valid;
	always_ff @(posedge clk) rd <= pipeWb.rd;
	always_ff @(posedge clk) sr <= pipeWb.sr;

	logic [31:1][31:0] gpr;
	always_ff @(posedge clk) begin
		if(valid[0]&&rd[0].addr!=0) gpr[rd[0].addr] <= rd[0].data;
		if(valid[1]&&rd[1].addr!=0) gpr[rd[1].addr] <= rd[1].data;
	end

	assign immeData.dataWbu.rd[0]		= rd[0].data;
	assign immeData.dataWbu.rd[1]		= rd[1].data;
	assign immeData.dataWbu.sr			= sr.srData;
	assign immeData.dataWbu.valid		= '1;
	assign immeData.dataWbu.hit[0][0]	= immeData.addr[0][0]==rd[0].addr;
	assign immeData.dataWbu.hit[0][1]	= immeData.addr[0][1]==rd[1].addr;
	assign immeData.dataWbu.hit[1][0]	= immeData.addr[1][0]==rd[0].addr;
	assign immeData.dataWbu.hit[1][1]	= immeData.addr[1][1]==rd[1].addr;

	assign immeData.dataGprs.r1[0]	= gpr[immeData.addr[0][0]];
	assign immeData.dataGprs.r1[1]	= gpr[immeData.addr[1][0]];
	assign immeData.dataGprs.r2[0]	= gpr[immeData.addr[0][1]];
	assign immeData.dataGprs.r2[1]	= gpr[immeData.addr[1][1]];
	// assign immeData.dataGprs.sr		= //TODO :还没定要怎么索引
endmodule
