`timescale 1ns / 1ps

`include "tb.vh"

module tb_id;

    localparam REGISTERS_BANK_SIZE   = 32;
    localparam PC_SIZE               = 32;
    localparam BUS_SIZE              = 32;
    
    // Señales de reloj y reset
    reg                                           i_clk;
    reg                                           i_reset;
    // Señales de control de entrada    
    reg                                           i_reg_write_enable;
    reg                                           i_ctr_reg_src;
    // Señales de datos de entrada    
    reg [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]     i_reg_addr_wr;
    reg [BUS_SIZE - 1 : 0]                        i_reg_bus_wr;
    reg [BUS_SIZE - 1 : 0]                        i_instruction;
    reg [PC_SIZE - 1 : 0]                         i_next_seq_pc;
    // Señales de control de salida    
    wire                                          o_next_pc_src;
    wire                                          o_reg_write;
    wire                                          o_mem_write;
    wire [1 : 0]                                  o_reg_dst;
    wire [1 : 0]                                  o_mem_to_reg;
    wire                                          o_alu_src_a;
    wire [1 : 0]                                  o_alu_src_b;
    wire [2 : 0]                                  o_alu_op;
    // Señales de datos de salida    
    wire [BUS_SIZE - 1 : 0]                       o_bus_a;
    wire [BUS_SIZE - 1 : 0]                       o_bus_b;
    wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc;
    wire [4 : 0]                                  o_rs;
    wire [4 : 0]                                  o_rt;
    wire [4 : 0]                                  o_rd;
    wire [5 : 0]                                  o_funct;
    wire [BUS_SIZE - 1 : 0]                       o_shamt_ext_unsigned;
    wire [BUS_SIZE - 1 : 0]                       o_inm_ext_signed;
    wire [BUS_SIZE - 1 : 0]                       o_inm_upp;
    wire [BUS_SIZE - 1 : 0]                       o_inm_ext_unsigned;
    // Señales de depuración
    wire [REGISTERS_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug;

    // Instancia del módulo
    id
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .PC_SIZE             (PC_SIZE),
        .BUS_SIZE            (BUS_SIZE)
    ) 
    dut
    (
        .i_clk                (i_clk),
        .i_reset              (i_reset),
        .i_reg_write_enable   (i_reg_write_enable),
        .i_ctr_reg_src        (i_ctr_reg_src),
        .i_reg_addr_wr        (i_reg_addr_wr),
        .i_reg_bus_wr         (i_reg_bus_wr),
        .i_instruction        (i_instruction),
        .i_next_seq_pc        (i_next_seq_pc),
        .o_next_pc_src        (o_next_pc_src),
        .o_reg_write          (o_reg_write),
        .o_mem_write          (o_mem_write),
        .o_reg_dst            (o_reg_dst),
        .o_mem_to_reg         (o_mem_to_reg),
        .o_alu_src_a          (o_alu_src_a),
        .o_alu_src_b          (o_alu_src_b),
        .o_alu_op             (o_alu_op),
        .o_bus_a              (o_bus_a),
        .o_bus_b              (o_bus_b),
        .o_next_not_seq_pc    (o_next_not_seq_pc),
        .o_rs                 (o_rs),
        .o_rt                 (o_rt),
        .o_rd                 (o_rd),
        .o_funct              (o_funct),
        .o_shamt_ext_unsigned (o_shamt_ext_unsigned),
        .o_inm_ext_signed     (o_inm_ext_signed),
        .o_inm_upp            (o_inm_upp),
        .o_inm_ext_unsigned   (o_inm_ext_unsigned),
        .o_bus_debug          (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)
    
    reg [5:0]  instructions [19:0];
    reg [5:0]  functs       [16:0];
    reg [14:0] valid_out;

    integer i = 0;
    integer j = 0;

    initial
    begin
        instructions[0]  = `CODE_OP_R_TYPE;
        instructions[1]  = `CODE_OP_BEQ;
        instructions[2]  = `CODE_OP_BNE;
        instructions[3]  = `CODE_OP_J;
        instructions[4]  = `CODE_OP_JAL;
        instructions[5]  = `CODE_OP_LB;
        instructions[6]  = `CODE_OP_LH;
        instructions[7]  = `CODE_OP_LW;
        instructions[8]  = `CODE_OP_LWU;
        instructions[9]  = `CODE_OP_LBU;
        instructions[10] = `CODE_OP_LHU;
        instructions[11] = `CODE_OP_SB;
        instructions[12] = `CODE_OP_SH;
        instructions[13] = `CODE_OP_SW;
        instructions[14] = `CODE_OP_ADDI;
        instructions[15] = `CODE_OP_ANDI;
        instructions[16] = `CODE_OP_ORI;
        instructions[17] = `CODE_OP_XORI;
        instructions[18] = `CODE_OP_LUI;
        instructions[19] = `CODE_OP_SLTI;

        functs[0]  = `CODE_FUNCT_JR;
        functs[1]  = `CODE_FUNCT_JALR;
        functs[2]  = `CODE_FUNCT_SLL;
        functs[3]  = `CODE_FUNCT_SRL;
        functs[4]  = `CODE_FUNCT_SRA;
        functs[5]  = `CODE_FUNCT_ADD;
        functs[6]  = `CODE_FUNCT_ADDU;
        functs[7]  = `CODE_FUNCT_SUB;
        functs[8]  = `CODE_FUNCT_SUBU;
        functs[9]  = `CODE_FUNCT_AND;
        functs[10] = `CODE_FUNCT_OR;
        functs[11] = `CODE_FUNCT_XOR;
        functs[12] = `CODE_FUNCT_NOR;
        functs[13] = `CODE_FUNCT_SLT;
        functs[14] = `CODE_FUNCT_SLLV;
        functs[15] = `CODE_FUNCT_SRLV;
        functs[16] = `CODE_FUNCT_SRAV;
    end
    
    task automatic set_valid_out();
        case (instructions[i])
            `CODE_OP_R_TYPE :
                case (functs[j])
                    `CODE_FUNCT_JR    : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    `CODE_FUNCT_JALR  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_REG, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    `CODE_FUNCT_SLL   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RD,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    `CODE_FUNCT_SRL   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RD,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    `CODE_FUNCT_SRA   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RD,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_SHAMT, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                    default           : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,     `CODE_MAIN_CTR_NOT_JMP, `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RD,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A, `CODE_ALU_CTR_SRC_B_BUS_B, `CODE_ALU_CTR_R_TYPE };
                endcase
            `CODE_OP_LW   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_SW   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            `CODE_OP_BEQ  : valid_out = { o_bus_a == 0 ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_BUS_B,     `CODE_ALU_CTR_BRANCH_TYPE };
            `CODE_OP_BNE  : valid_out = { o_bus_a != 0 ? { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ, `CODE_MAIN_CTR_JMP_BRANCH } : { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ, `CODE_MAIN_CTR_NOT_JMP }, `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_BUS_B,     `CODE_ALU_CTR_BRANCH_TYPE };
            `CODE_OP_ADDI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_ADDI        };
            `CODE_OP_J    : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                   `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_BUS_B,     `CODE_ALU_CTR_JUMP_TYPE   };
            `CODE_OP_JAL  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_NOT_SEQ,  `CODE_MAIN_CTR_JMP_DIR,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_GPR_31,  `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_BUS_B,     `CODE_ALU_CTR_JUMP_TYPE   };
            `CODE_OP_ANDI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_ANDI        };
            `CODE_OP_ORI  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_ORI         };
            `CODE_OP_XORI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_USIG_INM,  `CODE_ALU_CTR_XORI        };
            `CODE_OP_SLTI : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_SLTI        };
            `CODE_OP_LUI  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_ALU_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_UPPER_INM, `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LB   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_BYTE,       `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LBU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_BYTE,       `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LH   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LHU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_HALF_WORD,  `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_LWU  : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_ENABLE,  `CODE_MAIN_CTR_REG_DST_RT,      `CODE_MAIN_CTR_MEM_TO_REG_MEM_RESULT, `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_LOAD_TYPE   };
            `CODE_OP_SB   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            `CODE_OP_SH   : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_ENABLE,  `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_SIG_INM,   `CODE_ALU_CTR_STORE_TYPE  };
            default       : valid_out = { `CODE_MAIN_CTR_NEXT_PC_SRC_SEQ,      `CODE_MAIN_CTR_NOT_JMP,                                                                                   `CODE_MAIN_CTR_REG_WRITE_DISABLE, `CODE_MAIN_CTR_REG_DST_NOTHING, `CODE_MAIN_CTR_MEM_TO_REG_NOTHING,    `CODE_MAIN_CTR_MEM_WRITE_DISABLE, `CODE_ALU_CTR_SRC_A_BUS_A,`CODE_ALU_CTR_SRC_B_NOTHING,   `CODE_ALU_CTR_UNDEFINED   };
        endcase
    endtask

    initial 
    begin
        $srandom(99595291);

        i_reset = 1;
        i_reg_write_enable = 0;
        i_ctr_reg_src = 0;
        i_reg_addr_wr = 0;
        i_reg_bus_wr = 0;
        i_instruction = 0;
        i_next_seq_pc = 0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        repeat (20)
        begin
            if (i == 0)
                begin
                    repeat (17) 
                    begin
                        set_valid_out();

                        i_instruction = $urandom; 
                        i_instruction = { instructions[i], i_instruction[19:0] , functs[j] };  
                        
                        `TICKS_DELAY_1(`CLK_PERIOD);

                        if (o_rs === i_instruction[25:21] && o_rt === i_instruction[20:16] && o_rd === i_instruction[15:11] && 
                            o_funct === i_instruction[5:0] && o_inm_ext_unsigned === { { 16 { 1'b0 } }, i_instruction[15:0] } &&
                            o_shamt_ext_unsigned === { { 27 { 1'b0 } }, i_instruction[10:6] } && o_inm_upp === (i_instruction[15:0] << 16) &&
                            o_inm_ext_signed === { { 16 { i_instruction[15] } }, i_instruction[15:0] } && 
                            o_next_pc_src === valid_out[14] && o_reg_write === valid_out[11] && o_mem_write === valid_out[6] &&
                            o_reg_dst === valid_out[10:9] && o_mem_to_reg === valid_out[8:7] && o_alu_src_a === valid_out[5] &&
                            o_alu_src_b === valid_out[4:3] && o_alu_op === valid_out[2:0])
                            $display("TEST %0d - %0d PASS", i, j);
                        else
                            begin
                                $display("\nTEST %0d - %0d ERROR", i, j);

                                $display("Valid_reg_out : %b", { valid_out[14], valid_out[11:0] });
                                $display("Obtain_reg_out: %b", { o_next_pc_src, o_reg_write, o_mem_write, o_reg_dst, o_mem_to_reg, o_alu_src_a, o_alu_src_b, o_alu_op });

                                $display("Valid_rs : %b", i_instruction[25:21]);
                                $display("Obtain_rs: %b", o_rs);

                                $display("Valid_rt : %b", i_instruction[20:16]);
                                $display("Obtain_rt: %b", o_rt);

                                $display("Valid_rd : %b", i_instruction[15:11]);
                                $display("Obtain_rd: %b", o_rd);

                                $display("Valid_funct : %b", i_instruction[5:0]);
                                $display("Obtain_funct: %b", o_funct);

                                $display("Valid_imm_ext_signed : %b",  { { 16 { i_instruction[15] } }, i_instruction[15: 0] } );
                                $display("Obtain_imm_ext_signed: %b", o_inm_ext_signed);

                                $display("Valid_imm_ext_unsigned : %b", { { 16 { 1'b0 } }, i_instruction[15:0] });
                                $display("Obtain_imm_ext_unsigned: %b", o_inm_ext_unsigned);

                                $display("Valid_shamt_ext_unsigned : %b", { { 27 { 1'b0 } }, i_instruction[10:6] });
                                $display("Obtain_shamt_ext_unsigned: %b", o_shamt_ext_unsigned);

                                $display("Valid_inm_upp : %b", i_instruction[15:0] << 16);
                                $display("Obtain_inm_upp: %b\n", o_inm_upp);
                            end

                        i_next_seq_pc = i_next_seq_pc + 4; 
 
                        j = j + 1; 
                    end
                end
            else
                begin
                    set_valid_out();

                    i_instruction = $urandom;
                    i_instruction = { instructions[i], i_instruction[25:0]};
                    
                    `TICKS_DELAY_1(`CLK_PERIOD);

                    if (o_rs === i_instruction[25:21] && o_rt === i_instruction[20:16] && o_rd === i_instruction[15:11] && 
                        o_funct === i_instruction[5:0] && o_inm_ext_unsigned === { { 16 { 1'b0 } }, i_instruction[15:0] } &&
                        o_shamt_ext_unsigned === { { 27 { 1'b0 } }, i_instruction[10:6] } && o_inm_upp === (i_instruction[15:0] << 16) &&
                        o_inm_ext_signed === { { 16 { i_instruction[15] } }, i_instruction[15:0] } && 
                        o_next_pc_src === valid_out[14] && o_reg_write === valid_out[11] && o_mem_write === valid_out[6] &&
                        o_reg_dst === valid_out[10:9] && o_mem_to_reg === valid_out[8:7] && o_alu_src_a === valid_out[5] &&
                         o_alu_src_b === valid_out[4:3] && o_alu_op === valid_out[2:0])
                        $display("TEST %0d PASS", i);
                    else
                        begin
                            $display("\nTEST %0d ERROR", i);

                            $display("Valid_reg_out : %b", { valid_out[14], valid_out[11:0] });
                            $display("Obtain_reg_out: %b", { o_next_pc_src, o_reg_write, o_mem_write, o_reg_dst, o_mem_to_reg, o_alu_src_a, o_alu_src_b, o_alu_op });

                            $display("Valid_rs : %b", i_instruction[25:21]);
                            $display("Obtain_rs: %b", o_rs);

                            $display("Valid_rt : %b", i_instruction[20:16]);
                            $display("Obtain_rt: %b", o_rt);

                            $display("Valid_rd : %b", i_instruction[15:11]);
                            $display("Obtain_rd: %b", o_rd);

                            $display("Valid_funct : %b", i_instruction[5:0]);
                            $display("Obtain_funct: %b", o_funct);

                            $display("Valid_imm_ext_signed : %b",  { { 16 { i_instruction[15] } }, i_instruction[15:0] } );
                            $display("Obtain_imm_ext_signed: %b", o_inm_ext_signed);

                            $display("Valid_imm_ext_unsigned : %b", { { 16 { 1'b0 } }, i_instruction[15:0] });
                            $display("Obtain_imm_ext_unsigned: %b", o_inm_ext_unsigned);

                            $display("Valid_shamt_ext_unsigned : %b", { { 27 { 1'b0 } }, i_instruction[10:6] });
                            $display("Obtain_shamt_ext_unsigned: %b", o_shamt_ext_unsigned);

                            $display("Valid_inm_upp : %b", i_instruction[15: 0] << 16);
                            $display("Obtain_inm_upp: %b\n", o_inm_upp);
                        end

                    i_next_seq_pc = i_next_seq_pc + 4;
                end

            i = i + 1;
        end

        $finish;
    end

endmodule
