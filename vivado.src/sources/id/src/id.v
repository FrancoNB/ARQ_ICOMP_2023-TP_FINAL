`timescale 1ns / 1ps

`include "id.vh"

module id
    #(
        parameter REGISTERS_BANK_SIZE = `DEFAULT_REGISTERS_BANK_SIZE,
        parameter PC_SIZE             = `DEFAULT_PC_SIZE,
        parameter BUS_SIZE            = `DEFAULT_ID_BUS_SIZE
    )
    (
        /* input controls wires */
        input  wire                                          i_clk,
        input  wire                                          i_reset,
        input  wire                                          i_reg_write_enable,
        input  wire                                          i_ctr_reg_src,
        /* input data wires */
        input  wire [$clog2(REGISTERS_BANK_SIZE) - 1 : 0]    i_reg_addr_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_reg_bus_wr,
        input  wire [BUS_SIZE - 1 : 0]                       i_instruction,
        input  wire [PC_SIZE - 1 : 0]                        i_next_seq_pc,
        /* output controls wires */
        output wire                                          o_next_pc_src,
        output wire                                          o_reg_write,
        output wire                                          o_mem_write,
        output wire [1 : 0]                                  o_reg_dst,
        output wire [1 : 0]                                  o_mem_to_reg,
        output wire [1 : 0]                                  o_alu_src,
        output wire [2 : 0]                                  o_alu_op,
        /* output data wires */
        output wire [BUS_SIZE - 1 : 0]                       o_bus_a,
        output wire [BUS_SIZE - 1 : 0]                       o_bus_b,
        output wire [PC_SIZE - 1 : 0]                        o_next_not_seq_pc,
        output wire [4 : 0]                                  o_rs,
        output wire [4 : 0]                                  o_rt,
        output wire [4 : 0]                                  o_rd,
        output wire [5 : 0]                                  o_funct,
        output wire [BUS_SIZE - 1 : 0]                       o_imm_ext_signed,
        /* debug wires */
        output wire [REGISTERS_BANK_SIZE * BUS_SIZE - 1 : 0] o_bus_debug
    );

    wire                    is_zero_result;
    wire [1 : 0]            jmp_ctrl;
    wire [13 : 0]           main_ctrl_regs;
    wire [10 : 0]           next_stage_ctrl_regs; 
    wire [BUS_SIZE - 1 : 0] imm_ext_signed_shifted;
    wire [BUS_SIZE - 1 : 0] dir_shifted;
    wire [5 : 0]            op;
    wire [15 : 0]           imm;
    wire [25 : 0]           dir;
    wire [BUS_SIZE - 1 : 0] branch_pc_dir, jump_pc_dir;

    assign op              = i_instruction[31:26];
    assign o_rs            = i_instruction[25:21];
    assign dir             = i_instruction[25:0];
    assign o_rt            = i_instruction[20:16];
    assign o_rd            = i_instruction[15:11];
    assign imm             = i_instruction[15:0];
    assign o_funct         = i_instruction[5:0];

    assign jump_pc_dir     = { i_next_seq_pc[31:28], dir_shifted[27:0] };
    
    assign o_next_pc_src   = main_ctrl_regs[13];
    assign jmp_ctrl        = main_ctrl_regs[12:11];

    assign o_reg_write     = next_stage_ctrl_regs[10];
    assign o_reg_dst       = next_stage_ctrl_regs[9:8];
    assign o_mem_to_reg    = next_stage_ctrl_regs[7:6];
    assign o_mem_write     = next_stage_ctrl_regs[5];
    assign o_alu_src       = next_stage_ctrl_regs[4:3];
    assign o_alu_op        = next_stage_ctrl_regs[2:0];

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

    is_zero 
    #(
        .BUS_SIZE (BUS_SIZE)
    )
    is_zero_unit 
    (
        .in      (o_bus_a),
        .is_zero (is_zero_result)
    );

    main_control main_control_unit 
    (
        .i_bus_a_is_zero (is_zero_result),
        .i_op            (op),
        .i_funct         (o_funct),
        .o_ctrl_regs     (main_ctrl_regs)
    );

    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_ext_imm_signed_unit 
    (
        .in  (o_imm_ext_signed),
        .out (imm_ext_signed_shifted)
    );

    shift_left 
    #(
        .BUS_SIZE   (BUS_SIZE), 
        .SHIFT_LEFT (2)
    ) 
    shift_left_dir_unit 
    (
        .in  (dir),
        .out (dir_shifted)
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
        .sum (branch_pc_dir)
    );

    mux 
    #(
        .CHANNELS(2), 
        .BUS_SIZE(11)
    ) 
    mux_2_unit
    (
        .selector (i_ctr_reg_src),
        .data_in  ({11'b0, main_ctrl_regs[10:0]}),
        .data_out (next_stage_ctrl_regs)
    );

    mux 
    #(
        .CHANNELS(3), 
        .BUS_SIZE(BUS_SIZE)
    ) 
    mux_3_unit
    (
        .selector (jmp_ctrl),
        .data_in  ({branch_pc_dir, o_bus_a, jump_pc_dir}),
        .data_out (o_next_not_seq_pc)
    );

endmodule