`timescale 1ns / 1ps

`include "tb.vh"

module tb_main_control;

    localparam OP_CTR_BUS_SIZE = 6;
    localparam OP_ALU_BUS_SIZE = 2;

    reg [OP_CTR_BUS_SIZE - 1 : 0]  i_op;
    wire                           o_wb_reg_write;
    wire                           o_wb_mem_to_reg;
    wire                           o_mem_branch;
    wire                           o_mem_read;
    wire                           o_mem_write;
    wire                           o_ex_dest;
    wire                           o_ex_alu_src;
    wire [OP_ALU_BUS_SIZE - 1 : 0] o_ex_alu_op;

    main_control 
    #(
        .OP_CTR_BUS_SIZE (OP_CTR_BUS_SIZE), 
        .OP_ALU_BUS_SIZE (OP_ALU_BUS_SIZE)
    ) 
    dut 
    (
        .i_op            (i_op),
        .o_wb_reg_write  (o_wb_reg_write),
        .o_wb_mem_to_reg (o_wb_mem_to_reg),
        .o_mem_branch    (o_mem_branch),
        .o_mem_read      (o_mem_read),
        .o_mem_write     (o_mem_write),
        .o_ex_dest       (o_ex_dest),
        .o_ex_alu_src    (o_ex_alu_src),
        .o_ex_alu_op     (o_ex_alu_op)
    );

    initial 
    begin
        i_op = 6'b101011; // lw opcode
        #10;
        if (!(o_ex_dest === `LOW && o_ex_alu_src === `LOW && o_ex_alu_op === 2'b00 &&
              o_mem_branch === `LOW && o_mem_read === `HIGH && o_mem_write === `LOW &&
              o_wb_reg_write === `HIGH && o_wb_mem_to_reg === `LOW))
            $display("TEST 1 ERROR");
        else
            $display("TEST 1 PASS");

        i_op = 6'b000100; // beq opcode
        #10;
        if (!(o_ex_dest === `UNDEF && o_ex_alu_src === `HIGH && o_ex_alu_op === 2'b01 &&
              o_mem_branch === `HIGH && o_mem_read === `LOW && o_mem_write === `LOW &&
              o_wb_reg_write === `LOW && o_wb_mem_to_reg === `UNDEF))
            $display("TEST 2 ERROR");
        else
            $display("TEST 2 PASS");

        i_op = 6'b000000; // r-type opcode
        #10;
        if (!(o_ex_dest === `HIGH && o_ex_alu_src === `HIGH && o_ex_alu_op === 2'b10 &&
              o_mem_branch === `LOW && o_mem_read === `LOW && o_mem_write === `LOW &&
              o_wb_reg_write === `HIGH && o_wb_mem_to_reg === `HIGH))
            $display("TEST 3 ERROR");
        else
            $display("TEST 3 PASS");

        i_op = 6'b100011; // sw opcode
        #10;
        if (!(o_ex_dest === `UNDEF && o_ex_alu_src === `LOW && o_ex_alu_op === 2'b00 &&
              o_mem_branch === `LOW && o_mem_read === `LOW && o_mem_write === `HIGH &&
              o_wb_reg_write === `LOW && o_wb_mem_to_reg === `UNDEF))
            $display("TEST 4 ERROR");
        else
            $display("TEST 4 PASS");

        $finish;
    end

endmodule