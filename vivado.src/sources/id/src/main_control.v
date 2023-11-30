`timescale 1ns / 1ps

`include "main_control.vh"

module main_control
    (
        input  wire          i_bus_a_is_zero,
        input  wire [5 : 0]  i_op,
        input  wire [5 : 0]  i_funct,
        output wire [13 : 0] o_ctrl_regs
    );

    /* o_next_pc_src */
    localparam NEXT_PC_SRC_SEQ       = 1'b0;
    localparam NEXT_PC_SRC_NOT_SEQ   = 1'b1;
    /* o_next_pc_src, o_jmp_ctrl */
    localparam NOT_JMP               = 2'bxx;
    localparam JMP_DIR               = 2'b10;
    localparam JMP_REG               = 2'b01;
    localparam JMP_BRANCH            = 2'b00;
    /* o_reg_write */
    localparam REG_WRITE_ENABLE      = 1'b1;
    localparam REG_WRITE_DISABLE     = 1'b0;
    /* o_reg_dst */
    localparam REG_DST_RD            = 2'b01;
    localparam REG_DST_GPR_31        = 2'b10;
    localparam REG_DST_RT            = 2'b00;
    localparam REG_DST_NOTHING       = 2'bxx;
    /* o_mem_to_reg */
    localparam MEM_TO_REG_ALU_RESULT = 2'b00;
    localparam MEM_TO_REG_MEM_RESULT = 2'b01;
    localparam MEM_TO_REG_HALF_WORD  = 2'b10;
    localparam MEM_TO_REG_BYTE       = 2'b11;
    localparam MEM_TO_REG_NOTHING    = 2'bxx;
    /* o_mem_write */
    localparam MEM_WRITE_ENABLE      = 1'b1;
    localparam MEM_WRITE_DISABLE     = 1'b0;
    /* o_alu_src */
    localparam ALU_SRC_BUS_B         = 2'b00;
    localparam ALU_SRC_SIG_INM       = 2'b01;
    localparam ALU_SRC_USIG_INM      = 2'b10;
    localparam ALU_SRC_UPPER_INM     = 2'b11;
    localparam ALU_SRC_NOTHING       = 2'bxx;
    /* o_alu_op */
    localparam ALU_OP_R_TYPE         = 3'b110;
    localparam ALU_OP_LOAD_TYPE      = 3'b000;
    localparam ALU_OP_STORE_TYPE     = 3'b000;
    localparam ALU_OP_BRANCH_TYPE    = 3'b001;
    localparam ALU_OP_JUMP_TYPE      = 3'bxxx;
    localparam ALU_OP_ADDI           = 3'b000;
    localparam ALU_OP_ANDI           = 3'b010;
    localparam ALU_OP_ORI            = 3'b011;
    localparam ALU_OP_XORI           = 3'b100;
    localparam ALU_OP_SLTI           = 3'b101;
    localparam ALU_OP_UNDEFINED      = 3'bxxx;
    
    // b13        : next_pc_src
    // b12, b11   : jmp_ctrl
    // b10        : reg_write 
    // b9, b8     : reg_dst
    // b7, b6     : mem_to_reg
    // b5         : mem_write
    // b4, b3     : alu_src
    // b2, b1, b0 : alu_op
    
    reg [13 : 0] ctrl_regs; 

    always @(*) 
    begin
        case (i_op)
            `CODE_OP_R_TYPE :
                case (i_funct)
                    `CODE_FUNCT_JR   : ctrl_regs = { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                    `CODE_FUNCT_JALR : ctrl_regs = { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                    default          : ctrl_regs = { NEXT_PC_SRC_SEQ,     NOT_JMP, REG_WRITE_ENABLE,  REG_DST_RD,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                endcase
            `CODE_OP_LW   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_SW   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            `CODE_OP_BEQ  : ctrl_regs = {  i_bus_a_is_zero ? { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH } : { NEXT_PC_SRC_SEQ, NOT_JMP }, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_BRANCH_TYPE };
            `CODE_OP_BNE  : ctrl_regs = { ~i_bus_a_is_zero ? { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH } : { NEXT_PC_SRC_SEQ, NOT_JMP }, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_BRANCH_TYPE };
            `CODE_OP_ADDI : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_ADDI        };
            `CODE_OP_J    : ctrl_regs = { NEXT_PC_SRC_NOT_SEQ,  JMP_DIR,                                                         REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_JUMP_TYPE   };
            `CODE_OP_JAL  : ctrl_regs = { NEXT_PC_SRC_NOT_SEQ,  JMP_DIR,                                                         REG_WRITE_ENABLE,  REG_DST_GPR_31,  MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_JUMP_TYPE   };
            `CODE_OP_ANDI : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ANDI        };
            `CODE_OP_ORI  : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ORI         };
            `CODE_OP_XORI : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_XORI        };
            `CODE_OP_SLTI : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_SLTI        };
            `CODE_OP_LUI  : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_UPPER_INM, ALU_OP_LOAD_TYPE   };
            `CODE_OP_LB   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_BYTE,       MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LBU  : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_BYTE,       MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LH   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_HALF_WORD,  MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LHU  : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_HALF_WORD,  MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LWU  : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_SB   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            `CODE_OP_SH   : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            default       : ctrl_regs = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                         REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_NOTHING,   ALU_OP_UNDEFINED   };
        endcase
    end

    assign o_ctrl_regs = ctrl_regs;

endmodule