`ifndef __CODES_VH__
`define __CODES_VH__

    `define CODE_OP_R_TYPE  6'b000000 // R-Type instructions                             *

    `define CODE_OP_BEQ     6'b000100 // Branch if equal instruction                     *
    `define CODE_OP_BNE     6'b000101 // Branch if not equal instruction                 *    
    `define CODE_OP_J       6'b000010 // Jump instruction                                *
    `define CODE_OP_JAL     6'b000011 // Jump and link instruction                       *
    `define CODE_OP_LB      6'b100000 // Load byte instruction                           *
    `define CODE_OP_LH      6'b100001 // Load halfword instruction                       *
    `define CODE_OP_LW      6'b100011 // Load word instruction                           *
    `define CODE_OP_LWU     6'b100111 // Load word unsigned instruction                  *
    `define CODE_OP_LBU     6'b100100 // Load byte unsigned instruction                  *
    `define CODE_OP_LHU     6'b100101 // Load halfword unsigned instruction              *
    `define CODE_OP_SB      6'b101000 // Store byte instruction                          *
    `define CODE_OP_SH      6'b101001 // Store halfword instruction                      *
    `define CODE_OP_SW      6'b101011 // Store word instruction                          *
    `define CODE_OP_ADDI    6'b001000 // Add immediate instruction                       *
    `define CODE_OP_ANDI    6'b001100 // And immediate instruction                       *
    `define CODE_OP_ORI     6'b001101 // Or immediate instruction                        *
    `define CODE_OP_XORI    6'b001110 // Xor immediate instruction                       *
    `define CODE_OP_LUI     6'b001111 // Load upper immediate instruction                *
    `define CODE_OP_SLTI    6'b001010 // Set less than immediate instruction             *

    `define CODE_FUNCT_JR   6'b001000 // Jump register instruction                       *
    `define CODE_FUNCT_JALR 6'b001001 // Jump and link register instruction              *

    `define CODE_FUNCT_SLL  6'b000000 // Shift left logical instruction                  *
    `define CODE_FUNCT_SRL  6'b000010 // Shift right logical instruction                 *
    `define CODE_FUNCT_SRA  6'b000011 // Shift right arithmetic instruction              *
    `define CODE_FUNCT_ADD  6'b100000 // Add instruction                                 *
    `define CODE_FUNCT_ADDU 6'b100001 // Add unsigned instruction                        *
    `define CODE_FUNCT_SUB  6'b100010 // Subtract instruction                            *
    `define CODE_FUNCT_SUBU 6'b100011 // Subtract unsigned instruction                   *
    `define CODE_FUNCT_AND  6'b100100 // And instruction                                 *
    `define CODE_FUNCT_OR   6'b100101 // Or instruction                                  *
    `define CODE_FUNCT_XOR  6'b100110 // Xor instruction                                 *
    `define CODE_FUNCT_NOR  6'b100111 // Nor instruction                                 *
    `define CODE_FUNCT_SLT  6'b101010 // Set less than instruction                       *
    `define CODE_FUNCT_SLLV 6'b000100 // Shift left logical variable instruction         *
    `define CODE_FUNCT_SRLV 6'b000110 // Shift right logical variable instruction        *
    `define CODE_FUNCT_SRAV 6'b000111 // Shift right arithmetic variable instruction     *

`endif // __CODES_VH__