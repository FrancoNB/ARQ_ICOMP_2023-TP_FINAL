`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_id;

    localparam REGISTERS_BANK_SIZE   = 32;
    localparam PC_SIZE               = 32;
    localparam BUS_SIZE              = 32;

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
    wire [1 : 0]                                  o_alu_src;
    wire [2 : 0]                                  o_alu_op;
    // Señales de datos de salida    
    wire [BUS_SIZE - 1 : 0]                       o_bus_a;
    wire [BUS_SIZE - 1 : 0]                       o_bus_b;
    wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc;
    wire [4 : 0]                                  o_rs;
    wire [4 : 0]                                  o_rt;
    wire [4 : 0]                                  o_rd;
    wire [5 : 0]                                  o_funct;
    wire [BUS_SIZE - 1 : 0]                       o_imm_ext_signed;
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
        .i_clk              (i_clk),
        .i_reset            (i_reset),
        .i_reg_write_enable (i_reg_write_enable),
        .i_ctr_reg_src      (i_ctr_reg_src),
        .i_reg_addr_wr      (i_reg_addr_wr),
        .i_reg_bus_wr       (i_reg_bus_wr),
        .i_instruction      (i_instruction),
        .i_next_seq_pc      (i_next_seq_pc),
        .o_next_pc_src      (o_next_pc_src),
        .o_reg_write        (o_reg_write),
        .o_mem_write        (o_mem_write),
        .o_reg_dst          (o_reg_dst),
        .o_mem_to_reg       (o_mem_to_reg),
        .o_alu_src          (o_alu_src),
        .o_alu_op           (o_alu_op),
        .o_bus_a            (o_bus_a),
        .o_bus_b            (o_bus_b),
        .o_next_not_seq_pc  (o_next_not_seq_pc),
        .o_rs               (o_rs),
        .o_rt               (o_rt),
        .o_rd               (o_rd),
        .o_funct            (o_funct),
        .o_imm_ext_signed   (o_imm_ext_signed),
        .o_bus_debug        (o_bus_debug)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)
    
    reg [5:0]  instructions [19:0];
    reg [5:0]  functs       [16:0];
    reg [13:0] valid_out;

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
                    `CODE_FUNCT_JR   : valid_out = { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                    `CODE_FUNCT_JALR : valid_out = { NEXT_PC_SRC_NOT_SEQ, JMP_REG, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                    default          : valid_out = { NEXT_PC_SRC_SEQ,     NOT_JMP, REG_WRITE_ENABLE,  REG_DST_RD,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B, ALU_OP_R_TYPE };
                endcase
            `CODE_OP_LW   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_SW   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            `CODE_OP_BEQ  : valid_out = {  o_bus_a == 0 ? { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH } : { NEXT_PC_SRC_SEQ, NOT_JMP }, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_BRANCH_TYPE };
            `CODE_OP_BNE  : valid_out = {  o_bus_a != 0 ? { NEXT_PC_SRC_NOT_SEQ, JMP_BRANCH } : { NEXT_PC_SRC_SEQ, NOT_JMP }, REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_BRANCH_TYPE };
            `CODE_OP_ADDI : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_ADDI        };
            `CODE_OP_J    : valid_out = { NEXT_PC_SRC_NOT_SEQ,  JMP_DIR,                                                      REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_JUMP_TYPE   };
            `CODE_OP_JAL  : valid_out = { NEXT_PC_SRC_NOT_SEQ,  JMP_DIR,                                                      REG_WRITE_ENABLE,  REG_DST_GPR_31,  MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_BUS_B,     ALU_OP_JUMP_TYPE   };
            `CODE_OP_ANDI : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ANDI        };
            `CODE_OP_ORI  : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_ORI         };
            `CODE_OP_XORI : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_USIG_INM,  ALU_OP_XORI        };
            `CODE_OP_SLTI : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_SLTI        };
            `CODE_OP_LUI  : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_ALU_RESULT, MEM_WRITE_DISABLE, ALU_SRC_UPPER_INM, ALU_OP_LOAD_TYPE   };
            `CODE_OP_LB   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_BYTE,       MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LBU  : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_BYTE,       MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LH   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_HALF_WORD,  MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LHU  : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_HALF_WORD,  MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_LWU  : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_ENABLE,  REG_DST_RT,      MEM_TO_REG_MEM_RESULT, MEM_WRITE_DISABLE, ALU_SRC_SIG_INM,   ALU_OP_LOAD_TYPE   };
            `CODE_OP_SB   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            `CODE_OP_SH   : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_ENABLE,  ALU_SRC_SIG_INM,   ALU_OP_STORE_TYPE  };
            default       : valid_out = { NEXT_PC_SRC_SEQ,      NOT_JMP,                                                      REG_WRITE_DISABLE, REG_DST_NOTHING, MEM_TO_REG_NOTHING,    MEM_WRITE_DISABLE, ALU_SRC_NOTHING,   ALU_OP_UNDEFINED   };
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

                        if (o_rs === i_instruction[25:21] && o_rt === i_instruction[20:16] && o_rd === i_instruction[15:11] && o_funct === i_instruction[5:0] &&
                            o_imm_ext_signed === { { 16 { i_instruction[15] } }, i_instruction[15: 0] } && o_next_pc_src === valid_out[13] && o_reg_write === valid_out[10] && o_mem_write === valid_out[5] &&
                             o_reg_dst === valid_out[9:8] && o_mem_to_reg === valid_out[7:6] && o_alu_src === valid_out[4:3] && o_alu_op === valid_out[2:0])
                            $display("TEST %0d - %0d PASS", i, j);
                        else
                            begin
                                $display("\nTEST %0d - %0d ERROR", i, j);

                                $display("Valid_reg_out : %b", { valid_out[13], valid_out[10: 0] });
                                $display("Obtain_reg_out: %b", { o_next_pc_src, o_reg_write, o_mem_write, o_reg_dst, o_mem_to_reg, o_alu_src, o_alu_op });

                                $display("Valid_rs : %b", i_instruction[25:21]);
                                $display("Obtain_rs: %b", o_rs);

                                $display("Valid_rt : %b", i_instruction[20:16]);
                                $display("Obtain_rt: %b", o_rt);

                                $display("Valid_rd : %b", i_instruction[15:11]);
                                $display("Obtain_rd: %b", o_rd);

                                $display("Valid_funct : %b", i_instruction[5:0]);
                                $display("Obtain_funct: %b", o_funct);

                                $display("Valid_imm_ext_signed : %b",  { { 16 { i_instruction[15] } }, i_instruction[15: 0] } );
                                $display("Obtain_imm_ext_signed: %b\n", o_imm_ext_signed);
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

                        if (o_rs === i_instruction[25:21] && o_rt === i_instruction[20:16] && o_rd === i_instruction[15:11] && o_funct === i_instruction[5:0] &&
                            o_imm_ext_signed === { { 16 { i_instruction[15] } }, i_instruction[15: 0] } && o_next_pc_src === valid_out[13] && o_reg_write === valid_out[10] && o_mem_write === valid_out[5] &&
                             o_reg_dst === valid_out[9:8] && o_mem_to_reg === valid_out[7:6] && o_alu_src === valid_out[4:3] && o_alu_op === valid_out[2:0])
                            $display("TEST %0d PASS", i);
                        else
                            begin
                                $display("\nTEST %0d ERROR", i);

                                $display("Valid_reg_out : %b", { valid_out[13], valid_out[10: 0] });
                                $display("Obtain_reg_out: %b", { o_next_pc_src, o_reg_write, o_mem_write, o_reg_dst, o_mem_to_reg, o_alu_src, o_alu_op });

                                $display("Valid_rs : %b", i_instruction[25:21]);
                                $display("Obtain_rs: %b", o_rs);

                                $display("Valid_rt : %b", i_instruction[20:16]);
                                $display("Obtain_rt: %b", o_rt);

                                $display("Valid_rd : %b", i_instruction[15:11]);
                                $display("Obtain_rd: %b", o_rd);

                                $display("Valid_funct : %b", i_instruction[5:0]);
                                $display("Obtain_funct: %b", o_funct);

                                $display("Valid_imm_ext_signed : %b",  { { 16 { i_instruction[15] } }, i_instruction[15: 0] } );
                                $display("Obtain_imm_ext_signed: %b\n", o_imm_ext_signed);
                            end

                    i_next_seq_pc = i_next_seq_pc + 4;
                end

            i = i + 1;
        end

        $finish;
    end

endmodule
