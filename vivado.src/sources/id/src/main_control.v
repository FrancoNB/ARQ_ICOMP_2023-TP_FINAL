`timescale 1ns / 1ps

`include "main_control.vh"

module main_control
    (
        input  wire          i_bus_a_is_zero,
        input  wire [5 : 0]  i_op,
        input  wire [5 : 0]  i_funct,
        output wire [13 : 0] o_ctrl_regs
    );
    
    // b13        : next_pc_src
    // b12, b11   : jmp_ctrl
    // b10        : reg_write 
    // b9, b8     : reg_dst
    // b7, b6     : mem_to_reg
    // b5         : mem_write
    // b4, b3     : alu_src
    // b2, b1, b0 : code_alu_op
    
    reg [13 : 0] ctrl_regs; 

    always @(*) 
    begin
        case (i_op)
            `CODE_OP_R_TYPE :
                case (i_funct)
                    `CODE_FUNCT_JR   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    `CODE_FUNCT_JALR : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    default          : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RD,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B, `CODE_ALU_CTR_R_TYPE };
                endcase
            `CODE_OP_LW   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_SW   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            `CODE_OP_BEQ  : ctrl_regs = {  i_bus_a_is_zero ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B,     `CODE_ALU_CTR_BRANCH_TYPE };
            `CODE_OP_BNE  : ctrl_regs = { ~i_bus_a_is_zero ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B,     `CODE_ALU_CTR_BRANCH_TYPE };
            `CODE_OP_ADDI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_ADDI        };
            `CODE_OP_J    : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                       `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B,     `CODE_ALU_CTR_JUMP_TYPE   };
            `CODE_OP_JAL  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_BUS_B,     `CODE_ALU_CTR_JUMP_TYPE   };
            `CODE_OP_ANDI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_USIG_INM,  `CODE_ALU_CTR_ANDI        };
            `CODE_OP_ORI  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_USIG_INM,  `CODE_ALU_CTR_ORI         };
            `CODE_OP_XORI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_USIG_INM,  `CODE_ALU_CTR_XORI        };
            `CODE_OP_SLTI : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_SLTI        };
            `CODE_OP_LUI  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_UPPER_INM, `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LB   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_BYTE,       `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LBU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_BYTE,       `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LH   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LHU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LWU  : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_SB   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            `CODE_OP_SH   : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            default       : ctrl_regs = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                       `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_NOTHING,   `CODE_ALU_CTR_UNDEFINED   };
        endcase
    end

    assign o_ctrl_regs = ctrl_regs;

endmodule