`include "interface.svh"
`define DEBUG
module ifb (
    input logic clk,rst,
    PipeIf2Ifb.Ifb if2,
    PipeIfbId1.Ifb id1
);
    PipeInstr [1:0] instr;
    logic pipeReady;
    assign if2.flush = id1.flush;
    always_ff @(posedge clk)if(rst || pipeReady || id1.flush)instr[0].valid  <= (rst || id1.flush)?Id1Valid_Idle:if2.instr[0].valid;
    always_ff @(posedge clk)if(rst || pipeReady || id1.flush)instr[1].valid  <= (rst || id1.flush)?Id1Valid_Idle:if2.instr[1].valid;
    always_ff @(posedge clk)if(pipeReady)instr[0].data   <= if2.instr[0].data;
    always_ff @(posedge clk)if(pipeReady)instr[1].data   <= if2.instr[1].data;

    PipeInstr [7:0] fifo;
    logic [2:0]fifoR0,fifoR1,fifoR2,fifoRn1,fifoRn2;
    logic fifoRoutValid,fifoRinValid;//约定不可能出现0无效1有效的情况
    logic [2:0]fifoW0,fifoW1,fifoW2;
    logic fifoWvalid;
    assign fifoR1 = fifoR0 + 1;
    assign fifoR2 = fifoR0 + 2;
    assign id1.instr[0] = fifo[fifoR0];
    assign id1.instr[1] = fifo[fifoR1];
    assign fifoRoutValid= id1.instr[0].valid!=Id1Valid_Idle;
    assign fifoRinValid = |id1.consume;
    assign fifoRn1 = fifoR1;
    assign fifoRn2 = id1.instr[1].valid!=Id1Valid_Idle ? fifoR2 : fifoR1;
    // always_ff @(posedge clk)if(rst || (fifoRoutValid && fifoRinValid))fifoR0 <= id1.consume[1]?(fifoRn2 & {3{~rst}}):(fifoRn1 & {3{~rst}});//因为不这样做可能延长关键路径
    always_ff @(posedge clk)
        if(rst)fifoR0 <= 0;
        else if(id1.flush)fifoR0 <= fifoW0;
        else if((fifoRoutValid && fifoRinValid))fifoR0 <= id1.consume[1]?fifoRn2:fifoRn1;

    assign fifoW1 = fifoW0 + 1;
    assign fifoW2 = fifoW0 + 2;
    assign fifoWvalid = fifo[fifoW0].valid==Id1Valid_Idle && fifo[fifoW1].valid==Id1Valid_Idle;
    always_ff @(posedge clk)begin
        if(rst || id1.flush)foreach(fifo[i])fifo[i].valid<=Id1Valid_Idle;
        else begin
            if(id1.consume[0])fifo[fifoR0].valid<=Id1Valid_Idle;
            if(id1.consume[1])fifo[fifoR1].valid<=Id1Valid_Idle;
            if(fifoWvalid)begin
                fifo[fifoW0] <= instr[0];
                fifo[fifoW1] <= instr[1];
            end
        end
    end
    assign pipeReady = (instr[0].valid==Id1Valid_Idle && instr[1].valid==Id1Valid_Idle) || fifoWvalid;
    assign if2.ready = pipeReady;
    always_ff @(posedge clk) begin
        if(rst) fifoW0 <= 0;
        else if(fifoWvalid && instr[0].valid!=Id1Valid_Idle && ~id1.flush) fifoW0 <= instr[1].valid!=Id1Valid_Idle ? fifoW2 : fifoW1;
    end
`ifdef DEBUG
    logic debug_fifoValid[7:0];always_comb foreach(fifo[i])debug_fifoValid[i] = fifo[i].valid!=Id1Valid_Idle;
`endif
endmodule
