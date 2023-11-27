`timescale 1ns / 1ps

`include "main_control.vh"

module main_control
    #(
        parameter OP_CTR_BUS_SIZE = `DEFAULT_MAIN_CONTROL_OP_CTR_BUS_SIZE,
        parameter OP_ALU_BUS_SIZE = `DEFAULT_MAIN_CONTROL_OP_ALU_BUS_SIZE
    )
    (
        input  wire [OP_CTR_BUS_SIZE - 1 : 0] i_op;
        output wire                           o_wb_reg_write;
        output wire                           o_wb_mem_to_reg;
        output wire                           o_mem_branch;
        output wire                           o_mem_read;
        output wire                           o_mem_write;
        output wire                           o_ex_dest;
        output wire                           o_ex_alu_src;
        output wire [OP_ALU_BUS_SIZE - 1 : 0] o_ex_alu_op;
    );

    assign o_ex_dest       = (op == `MAIN_CTR_OP_LW) ? `LOW : ((op == `MAIN_CTR_OP_R_TYPE) ? `HIGH : `UNDEF);
    assign o_ex_alu_src    = (op == `MAIN_CTR_OP_LW || op == `MAIN_CTR_OP_SW) ? `LOW : `HIGH;
    assign o_ex_alu_op     = (op == `MAIN_CTR_OP_LW || op == `MAIN_CTR_OP_SW) ? 2'b00 : ((op == `MAIN_CTR_OP_BEQ) ? 2'b01 : 2'b10);

    assign o_mem_branch    = (op == `MAIN_CTR_OP_BEQ) ? `HIGH : `LOW;
    assign o_mem_read      = (op == `MAIN_CTR_OP_LW)  ? `HIGH : `LOW;
    assign o_mem_write     = (op == `MAIN_CTR_OP_SW)  ? `HIGH : `LOW;

    assign o_wb_reg_write  = (op == `MAIN_CTR_OP_LW || op == `MAIN_CTR_OP_R_TYPE) ? `HIGH : `LOW;
    assign o_wb_mem_to_reg = (op == `MAIN_CTR_OP_LW) ? `LOW : ((op == `MAIN_CTR_OP_R_TYPE) ? `HIGH : `UNDEF);

endmodule