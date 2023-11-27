`ifndef __MAIN_CONTROL_VH__
`define __MAIN_CONTROL_VH__
    `include "common.vh"
    
    `define MAIN_CTR_OP_SW     6'b100011
    `define MAIN_CTR_OP_LW     6'b101011
    `define MAIN_CTR_OP_BEQ    6'b000100
    `define MAIN_CTR_OP_R_TYPE 6'b000000

    `define DEFAULT_MAIN_CONTROL_OP_CTR_BUS_SIZE 6
    `define DEFAULT_MAIN_CONTROL_OP_ALU_BUS_SIZE 2
`endif // __MAIN_CONTROL_VH__