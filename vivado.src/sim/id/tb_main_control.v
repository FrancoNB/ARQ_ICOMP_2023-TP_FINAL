`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_main_control;

    /* o_next_pc_src */
    localparam NEXT_PC_SRC_SEQ       = 1'b0;
    localparam NEXT_PC_SRC_NOT_SEQ   = 1'b1;
    /* o_jmp_ctrl */
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

    reg           i_bus_a_is_zero;
    reg  [5 : 0]  i_op;
    reg  [5 : 0]  i_funct;
    wire [13 : 0] o_ctrl_regs;

    main_control dut 
    (
        .i_bus_a_is_zero (i_bus_a_is_zero),
        .i_op           (i_op),
        .i_funct        (i_funct),
        .o_ctrl_regs    (o_ctrl_regs)
    );

    initial 
    begin
        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_ADD;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST ADD  ERROR");
        else
            $display("TEST ADD  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SUB;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SUB  ERROR");
        else
            $display("TEST SUB  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_AND;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST AND  ERROR");
        else
            $display("TEST AND  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_OR;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST OR   ERROR");
        else
            $display("TEST OR   PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_XOR;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST XOR  ERROR");
        else
            $display("TEST XOR  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_NOR;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST NOR  ERROR");
        else
            $display("TEST NOR  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLT;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SLT  ERROR");
        else
            $display("TEST SLT  PASS");
        
        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLL;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SLL  ERROR");
        else
            $display("TEST SLL  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRL;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SRL  ERROR");
        else
            $display("TEST SRL  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRA;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SRA  ERROR");
        else
            $display("TEST SRA  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_ADDU;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST ADDU ERROR");
        else
            $display("TEST ADDU PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SUBU;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SUBU ERROR");
        else
            $display("TEST SUBU PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLLV;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SLLV ERROR");
        else
            $display("TEST SLLV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRLV;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SRLV ERROR");
        else
            $display("TEST SRLV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRAV;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RD, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST SRAV ERROR");
        else
            $display("TEST SRAV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_JALR;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST JALR ERROR");
        else
            $display("TEST JALR PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_JR;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE }))
            $display("TEST JR   ERROR");
        else
            $display("TEST JR   PASS");
            
        i_funct = 0;
        
        i_op = `CODE_OP_LW;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LW   ERROR");
        else
            $display("TEST LW   PASS");
        
        i_op = `CODE_OP_SW;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM, ALU_OP_STORE_TYPE  }))
            $display("TEST SW   ERROR");
        else
            $display("TEST SW   PASS");

        i_op = `CODE_OP_BEQ;
        i_bus_a_is_zero = `LOW;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_BRANCH_TYPE }))
            $display("TEST BEQ1 ERROR");
        else
            $display("TEST BEQ1 PASS");

        i_op = `CODE_OP_BEQ;
        i_bus_a_is_zero = `HIGH;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_BRANCH_TYPE }))
            $display("TEST BEQ2 ERROR");
        else
            $display("TEST BEQ2 PASS");

        i_op = `CODE_OP_BNE;
        i_bus_a_is_zero = `HIGH;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_BRANCH_TYPE }))
            $display("TEST BNE1 ERROR");
        else
            $display("TEST BNE1 PASS");

        i_op = `CODE_OP_BNE;
        i_bus_a_is_zero = `LOW;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_BRANCH_TYPE }))
            $display("TEST BNE2 ERROR");
        else
            $display("TEST BNE2 PASS");

        i_op = `CODE_OP_ADDI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_ADDI }))
            $display("TEST ADDI ERROR");
        else
            $display("TEST ADDI PASS");

        i_op = `CODE_OP_J;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_DIR, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_JUMP_TYPE }))
            $display("TEST J    ERROR");
        else
            $display("TEST J    PASS");

        i_op = `CODE_OP_JAL;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_NOT_SEQ, JMP_DIR, REG_WRITE_ENABLE, REG_DST_GPR_31, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_JUMP_TYPE }))
            $display("TEST JAL  ERROR");
        else
            $display("TEST JAL  PASS");

        i_op = `CODE_OP_ANDI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ANDI }))
            $display("TEST ANDI ERROR");
        else
            $display("TEST ANDI PASS");
        
        i_op = `CODE_OP_ORI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ORI  }))
            $display("TEST ORI  ERROR");
        else
            $display("TEST ORI  PASS");

        i_op = `CODE_OP_XORI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_XORI }))
            $display("TEST XORI ERROR");
        else
            $display("TEST XORI PASS");

        i_op = `CODE_OP_SLTI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_SLTI }))
            $display("TEST SLTI ERROR");
        else
            $display("TEST SLTI PASS");

        i_op = `CODE_OP_LUI;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_UPPER_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LUI  ERROR");
        else
            $display("TEST LUI  PASS");

        i_op = `CODE_OP_LB;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_BYTE, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LB   ERROR");
        else
            $display("TEST LB   PASS");

        i_op = `CODE_OP_LBU;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_BYTE, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LBU  ERROR");
        else
            $display("TEST LBU  PASS");

        i_op = `CODE_OP_LH;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_HALF_WORD, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LH   ERROR");
        else
            $display("TEST LH   PASS");

        i_op = `CODE_OP_LHU;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_HALF_WORD, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LHU  ERROR");
        else
            $display("TEST LHU  PASS");

        i_op = `CODE_OP_LWU;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_ENABLE, REG_DST_RT, MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM, ALU_OP_LOAD_TYPE }))
            $display("TEST LWU  ERROR");
        else
            $display("TEST LWU  PASS");

        i_op = `CODE_OP_SB;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM, ALU_OP_STORE_TYPE  }))
            $display("TEST SB   ERROR");
        else
            $display("TEST SB   PASS");

        i_op = `CODE_OP_SH;
        #10;
        if (!(o_ctrl_regs === { NEXT_PC_SRC_SEQ, NOT_JMP, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING, MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM, ALU_OP_STORE_TYPE  }))
            $display("TEST SH   ERROR");
        else
            $display("TEST SH   PASS");
        
        $finish;
    end

endmodule