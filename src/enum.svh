`ifndef _ENUM_SVH_
`define _ENUM_SVH_

typedef enum logic[1:0] {WbuCsrOp_Null,WbuCsrOp_Write,WbuCsrOp_Trap,WbuCsrOp_Ret} WbuCsrOp;
typedef enum logic[1:0] {InstrValid_Idle,InstrValid_Valid,InstrValid_Fall,InstrValid_Un4b} InstrValid;
`endif
