`include "interface.svh"
module ifb (
    input logic clk,rst,
    PipeIf2Ifb.Ifb if2,
    PipeIfbId1.Ifb id1
);
    PipeInstr [7:0] fifo;
    
endmodule
