`timescale 1ns / 1ps

`include "main_control.vh"

module main_control
    (
        input  wire          i_bus_a_not_equal_bus_b,
        input  wire          i_instruction_is_nop,
        input  wire [5 : 0]  i_op,
        input  wire [5 : 0]  i_funct,
        output wire [19 : 0] o_ctrl_regs
    );
    
    // b19           : next_pc_src
    // b18, b17      : jmp_ctrl

    // b16, b15      : reg_dst
    // b14           : alu_src_a
    // b13, b12, b11 : alu_src_b
    // b10, b9, b8   : code_alu_op

    // b7, b6, b5    : mem_rd_src
    // b4, b3        : mem_wr_src
    // b2            : mem_write

    // b1            : wb
    // b0            : mem_to_reg

    reg [19 : 0] ctrl_regs; 

    always @(*) 
    begin
        if (!i_instruction_is_nop)
            case (i_op)
                `CODE_OP_R_TYPE :
                    case (i_funct)
                        `CODE_FUNCT_JR    : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING };
                        `CODE_FUNCT_JALR  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_NEXT_SEQ_PC, `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SLL   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SRL   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        `CODE_FUNCT_SRA   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_SHAMT,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                        default           : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_RD,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_R_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                    endcase
                `CODE_OP_LW   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_WORD,          `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_SW   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_WORD,     `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_BEQ  : ctrl_regs = { !i_bus_a_not_equal_bus_b ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_BRANCH_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_BNE  : ctrl_regs = {  i_bus_a_not_equal_bus_b ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_BRANCH_TYPE, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_ADDI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_ADDI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_J    : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_BUS_B,       `CODE_ALU_CTR_JUMP_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_JAL  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                               `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NEXT_SEQ_PC, `CODE_ALU_CTR_JUMP_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_ANDI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_ANDI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_ORI  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_ORI,         `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_XORI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_USIG_INM,    `CODE_ALU_CTR_XORI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_SLTI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_SLTI,        `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_LUI  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_UPPER_INM,   `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT };
                `CODE_OP_LB   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_SIG_BYTE,      `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LBU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_USIG_BYTE,     `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LH   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_SIG_HALFWORD,  `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LHU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_USIG_HALFWORD, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_LWU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_RT,      `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_LOAD_TYPE,   `CODE_MAIN_CTR_MEM_RD_SRC_WORD,          `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_ENABLE,  `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT };
                `CODE_OP_SB   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_BYTE,     `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                `CODE_OP_SH   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_BUS_A,   `CODE_ALU_CTR_SRC_B_SIG_INM,     `CODE_ALU_CTR_STORE_TYPE,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_HALFWORD, `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
                default       : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                               `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING,     `CODE_ALU_CTR_UNDEFINED ,  `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING,       `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING    };
            endcase
        else
            ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_ALU_CTR_SRC_A_NOTHING, `CODE_ALU_CTR_SRC_B_NOTHING, `CODE_ALU_CTR_UNDEFINED, `CODE_MAIN_CTR_MEM_RD_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WR_SRC_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_MAIN_CTR_WB_DISABLE, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING };
    end

    assign o_ctrl_regs = ctrl_regs;

endmodule