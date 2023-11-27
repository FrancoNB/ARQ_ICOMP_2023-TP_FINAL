`timescale 1ns / 1ps

`include "id.vh"

module id
    #(
        parameter REGISTERS_BANK_SIZE = `DEFAULT_REGISTERS_BANK_SIZE,
        parameter PC_SIZE             = `DEFAULT_PC_SIZE,
        parameter BUS_SIZE            = `DEFAULT_ID_BUS_SIZE,
        parameter INSTRUCTION_SIZE    = `DEFAULT_ID_INSTRUCTION_SIZE,
        parameter OP_ALU_BUS_SIZE     = `DEFAULT_MAIN_CONTROL_OP_ALU_BUS_SIZE
    )
    (
        input  wire                                          i_clk,
        input  wire                                          i_reset,
        input  wire                                          i_reg_write_enable,
        input  wire                                          i_ctr_reg_src,
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]    i_reg_addr_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_reg_bus_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_instruction,
        input  wire [PC_SIZE - 1 : 0]                        i_next_seq_pc,
        output wire                                          o_wb_reg_write,
        output wire                                          o_wb_mem_to_reg,
        output wire                                          o_mem_branch,
        output wire                                          o_mem_read,
        output wire                                          o_mem_write,
        output wire                                          o_ex_dest,
        output wire                                          o_ex_alu_src,
        output wire                                          o_next_pc_src,
        output wire [BUS_SIZE - 1 : 0]                       o_bus_a,
        output wire [BUS_SIZE - 1 : 0]                       o_bus_b,
        output wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc,
        output wire [4 : 0]                                  o_rs,
        output wire [4 : 0]                                  o_rt,
        output wire [4 : 0]                                  o_rd,
        output wire [5 : 0]                                  o_funct,
        output wire [BUS_SIZE - 1 : 0]                       o_imm_ext_signed,
        output wire [OP_ALU_BUS_SIZE - 1 : 0]                o_ex_alu_op,
        output wire [REGISTERS_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug
    );

    wire                    is_zero_result;
    wire [8 : 0]            main_crt_reg_out, mux_ctr_reg_out;
    wire [BUS_SIZE - 1 : 0] imm_ext_signed_shifted;
    wire [5 : 0]            op;
    wire [15 : 0]           imm;

    assign o_rs            = i_instruction[25:21];
    assign o_rt            = i_instruction[20:16];
    assign o_rd            = i_instruction[15:11];
    assign o_funct         = i_instruction[5:0];
    assign op              = i_instruction[31:26];
    assign imm             = i_instruction[15:0];
    assign o_wb_reg_write  = mux_ctr_reg_out[0];
    assign o_wb_mem_to_reg = mux_ctr_reg_out[1];
    assign o_mem_branch    = mux_ctr_reg_out[2];
    assign o_mem_read      = mux_ctr_reg_out[3];
    assign o_mem_write     = mux_ctr_reg_out[4];
    assign o_ex_dest       = mux_ctr_reg_out[5];
    assign o_ex_alu_src    = mux_ctr_reg_out[6];
    assign o_ex_alu_op     = { mux_ctr_reg_out[7], mux_ctr_reg_out[8] };

    registers_bank 
    #(
        .REGISTERS_BANK_SIZE (REGISTERS_BANK_SIZE),
        .REGISTERS_SIZE      (BUS_SIZE)
    ) 
    registers_bank_unit 
    (
        .i_clk          (i_clk),
        .i_reset        (i_reset),
        .i_write_enable (i_reg_write_enable),
        .i_addr_a       (o_rs),
        .i_addr_b       (o_rt),
        .i_addr_wr      (i_reg_addr_wr),
        .i_bus_wr       (i_reg_bus_wr),
        .o_bus_a        (o_bus_a),
        .o_bus_b        (o_bus_b),
        .o_bus_debug    (o_bus_debug)
    );

    sig_extend 
    #(
        .REG_IN_SIZE  (`DEFAULT_SIG_EXTEND_IN_REG_SIZE), 
        .REG_OUT_SIZE (BUS_SIZE)
    ) 
    sig_extend_unit 
    (
        .i_reg (imm),
        .o_reg (o_imm_ext_signed)
    );

    main_control 
    #(
        .OP_CTR_BUS_SIZE (`DEFAULT_MAIN_CONTROL_OP_CTR_BUS_SIZE), 
        .OP_ALU_BUS_SIZE (OP_ALU_BUS_SIZE)
    ) 
    main_control_unit 
    (
        .i_op            (op),
        .o_wb_reg_write  (main_crt_reg_out[0]),
        .o_wb_mem_to_reg (main_crt_reg_out[1]),
        .o_mem_branch    (main_crt_reg_out[2]),
        .o_mem_read      (main_crt_reg_out[3]),
        .o_mem_write     (main_crt_reg_out[4]),
        .o_ex_dest       (main_crt_reg_out[5]),
        .o_ex_alu_src    (main_crt_reg_out[6]),
        .o_ex_alu_op     ({ main_crt_reg_out[7], main_crt_reg_out[8] })
    );

    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_unit 
    (
        .in  (o_imm_ext_signed),
        .out (imm_ext_signed_shifted)
    );

    adder 
    #
    (
        .BUS_SIZE (BUS_SIZE)
    ) 
    adder_unit 
    (
        .a   (i_next_seq_pc),
        .b   (imm_ext_signed_shifted),
        .sum (o_next_not_seq_pc)
    );

    is_zero 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_zero_unit 
    (
        .in      (o_bus_a),
        .is_zero (is_zero_result)
    );

    _and 
    #(
        .CHANNELS (2)
    ) 
    _and_unit 
    (
        .in  ({is_zero_result, o_mem_branch}),
        .out (o_next_pc_src)
    );

    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(9)
    ) 
    mux_2_unit
    (
        .selector (i_ctr_reg_src),
        .data_in  ({9'b0, main_crt_reg_out}),
        .data_out (mux_ctr_reg_out)
    );

endmodule