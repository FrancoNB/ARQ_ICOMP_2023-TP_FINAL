`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

// Registers

`define R0  5'b00000
`define R1  5'b00001
`define R2  5'b00010
`define R3  5'b00011
`define R4  5'b00100
`define R5  5'b00101
`define R6  5'b00110
`define R7  5'b00111
`define R8  5'b01000
`define R9  5'b01001
`define R10 5'b01010
`define R11 5'b01011
`define R12 5'b01100
`define R13 5'b01101
`define R14 5'b01110
`define R15 5'b01111
`define R16 5'b10000
`define R17 5'b10001
`define R18 5'b10010
`define R19 5'b10011
`define R20 5'b10100
`define R21 5'b10101
`define R22 5'b10110
`define R23 5'b10111
`define R24 5'b11000
`define R25 5'b11001
`define R26 5'b11010
`define R27 5'b11011
`define R28 5'b11100
`define R29 5'b11101
`define R30 5'b11110
`define R31 5'b11111

// Instruction types

`define INST_TYPE_R(RS, RT, RD, SHAMT, FUNCT) { `CODE_OP_R_TYPE, RS, RT, RD, SHAMT, FUNCT }
`define INST_TYPE_I(OPCODE, RS, RT, IMM)      { OPCODE,          RS, RT, IMM }
`define INST_TYPE_J(OPCODE, ADDR)             { OPCODE,          ADDR }
`define HALT                                  { 32 { 1'b1 } }
`define NOP                                   { 32 { 1'b0 } }

// R-Type instructions

`define JR(RS1)             `INST_TYPE_R( RS1,      5'b00000, 5'b00000, 5'b00000, `CODE_FUNCT_JR   ) // PC = Rs1
`define JALR(RS1)           `INST_TYPE_R( RS1,      5'b00000, 5'b00000, 5'b00000, `CODE_FUNCT_JALR ) // R31 = PC + 4; PC = Rs1
`define SLL(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SLL  ) // Rd = Rs1 << Shamt
`define SRL(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SRL  ) // Rd = Rs1 >> Shamt
`define SRA(RD, RS2, SHAMT) `INST_TYPE_R( 5'b00000, RS2,      RD,       SHAMT,    `CODE_FUNCT_SRA  ) // Rd = Rs1 >>> Shamt
`define ADD(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_ADD  ) // Rd = Rs1 + Rs2
`define ADDU(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_ADDU ) // Rd = Rs1 + Rs2
`define SUB(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SUB  ) // Rd = Rs1 - Rs2
`define SUBU(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SUBU ) // Rd = Rs1 - Rs2
`define AND(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_AND  ) // Rd = Rs1 & Rs2
`define OR(RD, RS1, RS2)    `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_OR   ) // Rd = Rs1 | Rs2
`define XOR(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_XOR  ) // Rd = Rs1 ^ Rs2
`define NOR(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_NOR  ) // Rd = ~(Rs1 | Rs2)
`define SLT(RD, RS1, RS2)   `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SLT  ) // Rd = Rs1 < Rs2
`define SLLV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SLLV ) // Rd = Rs1 << Rs2
`define SRLV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SRLV ) // Rd = Rs1 >> Rs2
`define SRAV(RD, RS1, RS2)  `INST_TYPE_R( RS1,      RS2,      RD,       5'b00000, `CODE_FUNCT_SRAV ) // Rd = Rs1 >>> Rs2

// I-Type instructions

`define BEQ(RS1, RS2, INM)  `INST_TYPE_I( `CODE_OP_BEQ,  RS1,      RS2,      INM ) // PC += (Rs1 == Rs2 ? sigextend(Inm) : 0)
`define BNE(RS1, RS2, INM)  `INST_TYPE_I( `CODE_OP_BNE,  RS1,      RS2,      INM ) // PC += (Rs1 != Rs2 ? sigextend(Inm) : 0)
`define LB(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LB,   RS1,      RD,       INM ) // Rd = sigextend(Mem[Rs1 + unsigextend(Inm)])
`define LH(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LH,   RS1,      RD,       INM ) // Rd = sigextend(Mem[Rs1 + unsigextend(Inm)])
`define LW(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_LW,   RS1,      RD,       INM ) // Rd = Mem[Rs1 + unsigextend(Inm)]
`define LWU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LWU,  RS1,      RD,       INM ) // Rd = Mem[Rs1 + unsigextend(Inm)]
`define LBU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LBU,  RS1,      RD,       INM ) // Rd = unsigextend(Mem[Rs1 + unsigextend(Inm)])
`define LHU(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_LHU,  RS1,      RD,       INM ) // Rd = unsigextend(Mem[Rs1 + unsigextend(Inm)])
`define SB(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SB,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[7:0]
`define SH(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SH,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[15:0]
`define SW(RD, RS1, INM)    `INST_TYPE_I( `CODE_OP_SW,   RS1,      RD,       INM ) // Mem[Rs1 + unsigextend(Inm)] = Rd[31:0]
`define ADDI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_ADDI, RS1,      RD,       INM ) // Rd = Rs1 + sigextend(Inm)
`define ANDI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_ANDI, RS1,      RD,       INM ) // Rd = Rs1 & Inm
`define ORI(RD, RS1, INM)   `INST_TYPE_I( `CODE_OP_ORI,  RS1,      RD,       INM ) // Rd = Rs1 | Inm
`define XORI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_XORI, RS1,      RD,       INM ) // Rd = Rs1 ^ Inm
`define LUI(RD, INM)        `INST_TYPE_I( `CODE_OP_LUI,  5'b00000, RD,       INM ) // Rd = Inm << 16
`define SLTI(RD, RS1, INM)  `INST_TYPE_I( `CODE_OP_SLTI, RS1,      RD,       INM ) // Rd = Rs1 < sigextend(Inm) ? 1 : 0

// J-Type instructions

`define J(ADDR)             `INST_TYPE_J( `CODE_OP_J,   ADDR ) // PC = extend(Addr)
`define JAL(ADDR)           `INST_TYPE_J( `CODE_OP_JAL, ADDR ) // R31 = PC + 4; PC = extend(Addr)

// Utils

`define GET_REG(BANK, R) BANK[R * DATA_BUS_SIZE +: DATA_BUS_SIZE]
`define GET_MEM(MEMORY, DIR) MEMORY[DIR * DATA_BUS_SIZE +: DATA_BUS_SIZE]

module tb_mips;

    localparam PC_BUS_SIZE = 32;
    localparam DATA_BUS_SIZE = 32;
    localparam INSTRUCTION_BUS_SIZE = 32;
    localparam INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES = 4;
    localparam INSTRUCTION_MEMORY_SIZE_IN_WORDS = 64;
    localparam REGISTERS_BANK_SIZE = 32;
    localparam DATA_MEMORY_ADDR_SIZE = 5;

    reg                                                     i_clk;
    reg                                                     i_reset;
    reg                                                     i_enable;
    reg                                                     i_start;
    reg                                                     i_ins_mem_wr;
    reg  [INSTRUCTION_BUS_SIZE - 1 : 0]                     i_ins;
    wire                                                    o_ins_mem_full;
    wire                                                    o_ins_mem_emty;
    wire [REGISTERS_BANK_SIZE * DATA_BUS_SIZE - 1 : 0]      o_registers;
    wire [2**DATA_MEMORY_ADDR_SIZE * DATA_BUS_SIZE - 1 : 0] o_mem_data;

    mips
    #(
        .PC_BUS_SIZE                           (PC_BUS_SIZE),
        .DATA_BUS_SIZE                         (DATA_BUS_SIZE),
        .INSTRUCTION_BUS_SIZE                  (INSTRUCTION_BUS_SIZE),
        .INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES (INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES),
        .INSTRUCTION_MEMORY_SIZE_IN_WORDS      (INSTRUCTION_MEMORY_SIZE_IN_WORDS),
        .REGISTERS_BANK_SIZE                   (REGISTERS_BANK_SIZE),
        .DATA_MEMORY_ADDR_SIZE                 (DATA_MEMORY_ADDR_SIZE)
    )
    dut
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_enable       (i_enable),
        .i_start        (i_start),
        .i_ins_mem_wr   (i_ins_mem_wr),
        .i_ins          (i_ins),
        .o_ins_mem_full (o_ins_mem_full),
        .o_ins_mem_emty (o_ins_mem_emty),
        .o_registers    (o_registers),
        .o_mem_data     (o_mem_data)
    );

    `CLK_TOGGLE(i_clk, `CLK_PERIOD)

    reg [INSTRUCTION_BUS_SIZE - 1 : 0] first_program  [28 : 0];
    reg [INSTRUCTION_BUS_SIZE - 1 : 0] second_program [29 : 0];
    reg [INSTRUCTION_BUS_SIZE - 1 : 0] third_program  [17 : 0];

    reg [2**DATA_MEMORY_ADDR_SIZE * DATA_BUS_SIZE - 1 : 0] mem_last;
    reg [REGISTERS_BANK_SIZE * DATA_BUS_SIZE - 1 : 0]      reg_last;

    initial
    begin
        first_program[0]  = `ADDI(`R4, `R0, 16'd7123);
        first_program[1]  = `ADDI(`R3, `R0, 16'd85);
        first_program[2]  = `ADDU(`R5, `R4, `R3);
        first_program[3]  = `SUBU(`R6, `R4, `R3);
        first_program[4]  = `AND(`R7, `R4, `R3);
        first_program[5]  = `OR(`R8, `R4, `R3);
        first_program[6]  = `XOR(`R9, `R4, `R3);
        first_program[7]  = `NOR(`R10, `R3, `R4);
        first_program[8]  = `SLT(`R11, `R3, `R4);
        first_program[9]  = `SLL(`R12, `R10, 5'd2);
        first_program[10] = `SRL(`R13, `R10, 5'd2);
        first_program[11] = `SRA(`R14, `R10, 5'd2);
        first_program[12] = `SLLV(`R15, `R10, `R11);
        first_program[13] = `SRLV(`R16, `R10, `R11);
        first_program[14] = `SRAV(`R17, `R10, `R11);
        first_program[15] = `SB(`R13, `R0, 16'd4);
        first_program[16] = `SH(`R13, `R0, 16'd8);
        first_program[17] = `SW(`R13, `R0, 16'd12);
        first_program[18] = `LB(`R18, `R0, 16'd12);
        first_program[19] = `ANDI(`R19, `R18, 16'd6230);
        first_program[20] = `LH(`R20, `R0, 16'd12);
        first_program[21] = `ORI(`R21, `R20, 16'd6230);
        first_program[22] = `LW(`R22, `R0, 16'd12);
        first_program[23] = `XORI(`R23, `R22, 16'd6230);
        first_program[24] = `LWU(`R24, `R0, 16'd12);
        first_program[25] = `LUI(`R25, 16'd6230);
        first_program[26] = `LBU(`R26, `R0, 16'd12);
        first_program[27] = `SLTI(`R27, `R19, 16'd22614);
        first_program[28] = `HALT;
    end

    initial
    begin
        second_program[0]  = `J(26'd5);
        second_program[1]  = `ADDI(`R3, `R0, 16'd85);
        second_program[2]  = `NOP;
        second_program[3]  = `NOP;
        second_program[4]  = `NOP;
        second_program[5]  = `JAL(26'd8);
        second_program[6]  = `ADDI(`R4, `R0, 16'd95);
        second_program[7]  = `NOP;
        second_program[8]  = `ADDI(`R5, `R0, 16'd56);
        second_program[9]  = `JR(`R5);
        second_program[10] = `ADDI(`R2, `R0, 16'd2);
        second_program[11] = `NOP;
        second_program[12] = `NOP;
        second_program[13] = `NOP;
        second_program[14] = `ADDI(`R6, `R0, 16'd80);
        second_program[15] = `JALR(`R6);
        second_program[16] = `ADDI(`R1, `R0, 16'd10);
        second_program[17] = `NOP;
        second_program[18] = `NOP;
        second_program[19] = `NOP;
        second_program[20] = `ADDI(`R7, `R0, 16'd15);
        second_program[21] = `ADDI(`R8, `R0, 16'd8);
        second_program[22] = `ADDI(`R8, `R8, 16'd1);
        second_program[23] = `SW(`R7, `R8, 16'd0);
        second_program[24] = `BNE(`R8, `R7, -16'd3);
        second_program[25] = `BEQ(`R8, `R7, 16'd2);
        second_program[26] = `ADDI(`R9, `R0, 16'd8);
        second_program[27] = `ADDI(`R10, `R0, 16'd8);
        second_program[28] = `ADDI(`R11, `R0, 16'd8);
        second_program[29] = `HALT;
    end

    initial
    begin
        third_program[0]  = `ADDI(`R3, `R0, 16'd85);
        third_program[1]  = `JAL(26'd14);
        third_program[2]  = `ADDI(`R4, `R0, 16'd86);
        third_program[3]  = `J(26'd16);
        third_program[4]  = `NOP;
        third_program[5]  = `NOP;
        third_program[6]  = `NOP;
        third_program[7]  = `NOP;
        third_program[8]  = `NOP;
        third_program[9]  = `NOP;
        third_program[10] = `NOP;
        third_program[11] = `NOP;
        third_program[12] = `NOP;
        third_program[13] = `NOP;
        third_program[14] = `ADDI(`R5, `R0, 16'd87);
        third_program[15] = `JALR(`R31);
        third_program[16] = `ADDI(`R6, `R0, 16'd88);
        third_program[17] = `HALT;
    end
    
    integer i, j;

    initial 
    begin
        $srandom(61981512);
        
        i_reset      = 1'b1;
        i_enable     = 1'b0;
        i_start      = 1'b0;
        i_ins_mem_wr = 1'b0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        i = 0;
        j = 1;

        repeat(29)
        begin
                                        i_ins        = first_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- FIRST  PROGRAM -----------------------------------\n");

        i_start  = 1'b1;
        i_enable = 1'b1;
        
        `TICKS_DELAY_1(`CLK_PERIOD);
        
        i_start  = 1'b0; 
         
        `TICKS_DELAY(`CLK_PERIOD, 30);

        i_reset      = 1'b1;
        i_enable     = 1'b0;
        i_start      = 1'b0;
        i_ins_mem_wr = 1'b0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        i = 0;
        j = 1;

        repeat(30)
        begin
                                        i_ins        = second_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- SECOND PROGRAM -----------------------------------\n");

        i_start  = 1'b1;
        i_enable = 1'b1;
        
        `TICKS_DELAY_1(`CLK_PERIOD);
        
        i_start  = 1'b0; 
        
        `TICKS_DELAY(`CLK_PERIOD, 60);

        i_reset      = 1'b1;
        i_enable     = 1'b0;
        i_start      = 1'b0;
        i_ins_mem_wr = 1'b0;

        `RANDOM_TICKS_DELAY_MAX_20(`CLK_PERIOD) i_reset = 0;

        i = 0;
        j = 1;

        repeat(18)
        begin
                                        i_ins        = third_program[i];
                                        i_ins_mem_wr = 1'b1;
            `TICKS_DELAY_1(`CLK_PERIOD) i_ins_mem_wr = 1'b0;
                                        i            = i + 1;  
        end

        $display("\n----------------------------------- THIRD  PROGRAM -----------------------------------\n");

        i_start  = 1'b1;
        i_enable = 1'b1;

        `TICKS_DELAY_1(`CLK_PERIOD);

        i_start  = 1'b0;

        `TICKS_DELAY(`CLK_PERIOD, 30);

        $display("\n--------------------------------------------------------------------------------------\n");

        $finish;
    end
        
    always @(posedge i_clk)
    begin
        if (i_reset)
            begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    `GET_REG(reg_last, i) = 0;

                for (i = 0; i < 2**DATA_MEMORY_ADDR_SIZE; i = i + 1)
                    `GET_MEM(mem_last, i) = 0;
            end
        else if (i_enable)
           begin
                for (i = 0; i < REGISTERS_BANK_SIZE; i = i + 1)
                    if (`GET_REG(o_registers, i) != `GET_REG(reg_last, i))
                        begin
                            $display("[Cicle %d] R %d  | %h | -> | %h |", j, i, `GET_REG(reg_last, i), `GET_REG(o_registers, i));
                            `GET_REG(reg_last, i) = `GET_REG(o_registers, i);
                        end
                
                for (i = 0; i < 2**DATA_MEMORY_ADDR_SIZE; i = i + 1)
                    if (`GET_MEM(o_mem_data, i) != `GET_MEM(mem_last, i))
                        begin
                            $display("[Cicle %d] M(%d) | %h | -> | %h |", j, i, `GET_MEM(mem_last, i), `GET_MEM(o_mem_data, i));
                            `GET_MEM(mem_last, i) = `GET_MEM(o_mem_data, i);
                        end
                
                j = j + 1;
            end
    end
endmodule