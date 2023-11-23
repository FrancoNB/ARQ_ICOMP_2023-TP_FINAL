`ifndef __ALU_VH__
`define __ALU_VH__
    `define CTR_SLL   4'b0000 // Shift left logical
    `define CTR_SRL   4'b0001 // Shift right logical
    `define CTR_SRA   4'b0010 // Shift right arithmetic
    `define CTR_ADD   4'b0011 // Sum
    `define CTR_SUB   4'b0100 // Substract 
    `define CTR_AND   4'b0101 // Logical and
    `define CTR_OR    4'b0110 // Logical or
    `define CTR_XOR   4'b0111 // Logical xor
    `define CTR_NOR   4'b1000 // Logical nor
    `define CTR_SLT   4'b1001 // Set if less than
    `define CTR_SLLV  4'b1010 // Shift left logical
    `define CTR_SRLV  4'b1011 // Shift right logical
    `define CTR_SRAV  4'b1100 // Shift right arithmetic
    `define CTR_SLL16 4'b1101 // Shift left logical 16
    `define CTR_NEQ   4'b1110 // Equal
    
    `define CTR_BUS_WIDTH 4
    `define IO_BUS_WIDTH  8
`endif // __ALU_VH__