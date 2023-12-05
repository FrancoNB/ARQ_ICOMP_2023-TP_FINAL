`timescale 1ns / 1ps

`include "risk_detection.vh"

module risk_detection
    (
        input  wire [4 : 0] i_if_id_rt,
        input  wire [4 : 0] i_if_id_rs,
        input  wire [4 : 0] i_if_id_rd,
        input  wire [5 : 0] i_if_id_op,
        input  wire [4 : 0] i_id_ex_rt,
        input  wire [4 : 0] i_id_ex_rd,
        input  wire [5 : 0] i_id_ex_op,
        output wire         o_not_load,
        output wire         o_halt,
        output wire         o_reg_src
    );
    
    wire         load_hazard;
    wire         aritmetic_hazard;
    wire         aritmetic_inmediate_hazard;

    assign load_hazard = (i_id_ex_rt == i_if_id_rs   || i_id_ex_rt == i_if_id_rd)  && 
                         (i_id_ex_op == `CODE_OP_LW  || i_id_ex_op == `CODE_OP_LB  || 
                          i_id_ex_op == `CODE_OP_LBU || i_id_ex_op == `CODE_OP_LH  || 
                          i_id_ex_op == `CODE_OP_LHU || i_id_ex_op == `CODE_OP_LUI ||
                          i_id_ex_op == `CODE_OP_LWU);

    assign aritmetic_hazard = (i_id_ex_rd == i_if_id_rs || i_id_ex_rd == i_if_id_rt) &&
                               i_id_ex_rd != 0          && i_id_ex_op == `CODE_OP_R_TYPE;

    assign aritmetic_inmediate_hazard = (i_id_ex_rt == i_if_id_rs    || i_id_ex_rt == i_if_id_rd)   && 
                                        (i_id_ex_op == `CODE_OP_ADDI || i_id_ex_op == `CODE_OP_ANDI || 
                                         i_id_ex_op == `CODE_OP_ORI  || i_id_ex_op == `CODE_OP_XORI ||
                                         i_id_ex_op == `CODE_OP_SLTI);
    
    assign o_halt     = i_if_id_op == `CODE_OP_HALT;
    assign o_not_load = load_hazard || aritmetic_hazard || aritmetic_inmediate_hazard;
    assign o_reg_src  = o_not_load;

endmodule