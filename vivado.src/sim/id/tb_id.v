`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module id_tb;

    parameter REGISTERS_BANK_SIZE = 32;
    parameter PC_SIZE             = 32;
    parameter BUS_SIZE            = 32;

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

    initial 
    begin
        $srandom(99595291);

        

        $finish;
    end

endmodule
