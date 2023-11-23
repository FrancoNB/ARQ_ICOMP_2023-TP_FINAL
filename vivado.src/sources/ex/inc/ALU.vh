`ifndef __ALU_VH__
`define __ALU_VH__
    `define OP_ADD   6'b100000
    `define OP_SUB   6'b100010
    `define OP_AND   6'b100100
    `define OP_OR    6'b100101
    `define OP_XOR   6'b100110
    `define OP_SRA   6'b000011
    `define OP_SRL   6'b000010
    `define OP_NOR   6'b100111
    
    `define OP_CODE_WIDTH 6
    `define IO_BUS_WIDTH 8
`endif // __ALU_VH__