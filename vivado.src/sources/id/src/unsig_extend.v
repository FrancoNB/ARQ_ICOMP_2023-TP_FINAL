`timescale 1ns / 1ps

`include "unsig_extend.vh"

module unsig_extend
    #(
        REG_IN_SIZE  = `DEFAULT_UNSIG_EXTEND_IN_REG_SIZE,
        REG_OUT_SIZE = `DEFAULT_UNSIG_EXTEND_OUT_REG_SIZE
    )
    (
        input  wire [REG_IN_SIZE - 1 : 0]  i_reg,
        output wire [REG_OUT_SIZE - 1 : 0] o_reg
    );

    assign o_reg = { { (REG_OUT_SIZE - REG_IN_SIZE) { 1'b0 } }, i_reg };

endmodule