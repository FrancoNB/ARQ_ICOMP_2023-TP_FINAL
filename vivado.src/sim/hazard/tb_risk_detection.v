`timescale 1ns / 1ps

`include "tb.vh"
`include "codes.vh"

module tb_risk_detection;

    reg  [4:0] i_if_id_rt, i_if_id_rs, i_if_id_rd;
    reg  [5:0] i_if_id_op;
    reg  [4:0] i_id_ex_rt, i_id_ex_rd;
    reg  [5:0] i_id_ex_op;
    wire        o_not_load, o_halt, o_ctr_reg_src;

    risk_detection dut 
    (
        .i_if_id_rt      (i_if_id_rt),
        .i_if_id_rs      (i_if_id_rs),
        .i_if_id_rd      (i_if_id_rd),
        .i_if_id_op      (i_if_id_op),
        .i_id_ex_rt      (i_id_ex_rt),
        .i_id_ex_rd      (i_id_ex_rd),
        .i_id_ex_op      (i_id_ex_op),
        .o_not_load      (o_not_load),
        .o_halt          (o_halt),
        .o_ctr_reg_src   (o_ctr_reg_src)
    );

    initial 
    begin
        i_if_id_op = 0;
        
        i_if_id_rs = 4;
        i_id_ex_rt = 4; 
        i_id_ex_op = `CODE_OP_LB;

        #10;
        if (o_not_load !== 1'b1)
            $display("Failed test for Load Hazard");
        else
            $display("Successful test for Load Hazard");

        i_if_id_rs = 3;
        i_id_ex_rd = 3; 
        i_id_ex_op = `CODE_OP_R_TYPE;

        #10;
        if (o_not_load !== 1'b1)
            $display("Failed test for Aritmetic Hazard");
        else
            $display("Successful test for Aritmetic Hazard");

        i_if_id_rs = 1;
        i_id_ex_rt = 1;
        i_id_ex_op = `CODE_OP_ADDI;

        #10;
        if (o_not_load !== 1'b1)
            $display("Failed test for Aritmetic Immediate Hazard");
        else
            $display("Successful test for Aritmetic Immediate Hazard");

        i_if_id_op = `CODE_OP_HALT;

        #10;
        if (o_halt !== 1'b1)
            $display("Failed test for Halt");
        else
            $display("successful test for Halt");

        $finish;
    end
endmodule