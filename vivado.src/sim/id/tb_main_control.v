`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_main_control;

    reg           i_bus_a_is_zero;
    reg  [5 : 0]  i_op;
    reg  [5 : 0]  i_funct;
    wire [14 : 0] o_ctrl_regs;

    main_control dut 
    (
        .i_bus_a_is_zero (i_bus_a_is_zero),
        .i_op            (i_op),
        .i_funct         (i_funct),
        .o_ctrl_regs     (o_ctrl_regs)
    );

    initial 
    begin
        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_ADD;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST ADD  ERROR");
        else
            $display("TEST ADD  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SUB;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SUB  ERROR");
        else
            $display("TEST SUB  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_AND;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST AND  ERROR");
        else
            $display("TEST AND  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_OR;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST OR   ERROR");
        else
            $display("TEST OR   PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_XOR;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST XOR  ERROR");
        else
            $display("TEST XOR  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_NOR;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST NOR  ERROR");
        else
            $display("TEST NOR  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLT;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SLT  ERROR");
        else
            $display("TEST SLT  PASS");
        
        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLL;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SLL  ERROR");
        else
            $display("TEST SLL  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRL;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SRL  ERROR");
        else
            $display("TEST SRL  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRA;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SRA  ERROR");
        else
            $display("TEST SRA  PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_ADDU;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST ADDU ERROR");
        else
            $display("TEST ADDU PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SUBU;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SUBU ERROR");
        else
            $display("TEST SUBU PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SLLV;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SLLV ERROR");
        else
            $display("TEST SLLV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRLV;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SRLV ERROR");
        else
            $display("TEST SRLV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_SRAV;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RD, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST SRAV ERROR");
        else
            $display("TEST SRAV PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_JALR;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST JALR ERROR");
        else
            $display("TEST JALR PASS");

        i_op    = `CODE_OP_R_TYPE;
        i_funct = `CODE_FUNCT_JR;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE }))
            $display("TEST JR   ERROR");
        else
            $display("TEST JR   PASS");
            
        i_funct = 0;
        
        i_op = `CODE_OP_LW;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LW   ERROR");
        else
            $display("TEST LW   PASS");
        
        i_op = `CODE_OP_SW;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_STORE_TYPE  }))
            $display("TEST SW   ERROR");
        else
            $display("TEST SW   PASS");

        i_op = `CODE_OP_BEQ;
        i_bus_a_is_zero = `LOW;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_BRANCH_TYPE }))
            $display("TEST BEQ1 ERROR");
        else
            $display("TEST BEQ1 PASS");

        i_op = `CODE_OP_BEQ;
        i_bus_a_is_zero = `HIGH;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_BRANCH_TYPE }))
            $display("TEST BEQ2 ERROR");
        else
            $display("TEST BEQ2 PASS");

        i_op = `CODE_OP_BNE;
        i_bus_a_is_zero = `HIGH;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_BRANCH_TYPE }))
            $display("TEST BNE1 ERROR");
        else
            $display("TEST BNE1 PASS");

        i_op = `CODE_OP_BNE;
        i_bus_a_is_zero = `LOW;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_BRANCH_TYPE }))
            $display("TEST BNE2 ERROR");
        else
            $display("TEST BNE2 PASS");

        i_op = `CODE_OP_ADDI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_ADDI }))
            $display("TEST ADDI ERROR");
        else
            $display("TEST ADDI PASS");

        i_op = `CODE_OP_J;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_DIR, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_JUMP_TYPE }))
            $display("TEST J    ERROR");
        else
            $display("TEST J    PASS");

        i_op = `CODE_OP_JAL;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_DIR, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_GPR_31, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_JUMP_TYPE }))
            $display("TEST JAL  ERROR");
        else
            $display("TEST JAL  PASS");

        i_op = `CODE_OP_ANDI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_ANDI }))
            $display("TEST ANDI ERROR");
        else
            $display("TEST ANDI PASS");
        
        i_op = `CODE_OP_ORI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_ORI  }))
            $display("TEST ORI  ERROR");
        else
            $display("TEST ORI  PASS");

        i_op = `CODE_OP_XORI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_XORI }))
            $display("TEST XORI ERROR");
        else
            $display("TEST XORI PASS");

        i_op = `CODE_OP_SLTI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_SLTI }))
            $display("TEST SLTI ERROR");
        else
            $display("TEST SLTI PASS");

        i_op = `CODE_OP_LUI;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_UPPER_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LUI  ERROR");
        else
            $display("TEST LUI  PASS");

        i_op = `CODE_OP_LB;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_BYTE, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LB   ERROR");
        else
            $display("TEST LB   PASS");

        i_op = `CODE_OP_LBU;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_BYTE, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LBU  ERROR");
        else
            $display("TEST LBU  PASS");

        i_op = `CODE_OP_LH;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LH   ERROR");
        else
            $display("TEST LH   PASS");

        i_op = `CODE_OP_LHU;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LHU  ERROR");
        else
            $display("TEST LHU  PASS");

        i_op = `CODE_OP_LWU;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE, `CODE_MAIN_CTR_REG_DST_RT, `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_LOAD_TYPE }))
            $display("TEST LWU  ERROR");
        else
            $display("TEST LWU  PASS");

        i_op = `CODE_OP_SB;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_STORE_TYPE  }))
            $display("TEST SB   ERROR");
        else
            $display("TEST SB   PASS");

        i_op = `CODE_OP_SH;
        #10;
        if (!(o_ctrl_regs === { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING, `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM, `CODE_ALU_CTR_STORE_TYPE  }))
            $display("TEST SH   ERROR");
        else
            $display("TEST SH   PASS");
        
        $finish;
    end

endmodule