`timescale 1ns / 1ps

`include "short_circuit.vh"

module short_circuit
    #(
        parameter MEM_ADDR_SIZE = `DEFAULT_SHORT_CIRCUIT_MEM_ADDR_SIZE
    )
    (   
        input  wire                         i_mem_wb,
        input  wire                         i_wb_wb,
        input  wire [4 : 0]                 i_ex_rs,
        input  wire [4 : 0]                 i_ex_rt,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_mem_addr,
        input  wire [MEM_ADDR_SIZE - 1 : 0] i_wb_addr,
        output wire [1 : 0]                 o_sc_data_a_src,
        output wire [1 : 0]                 o_sc_data_b_src
    );

    assign o_sc_data_a_src = i_mem_addr == i_ex_rs && i_mem_wb ? 2'b10 : 
                             i_wb_addr  == i_ex_rs && i_wb_wb  ? 2'b01 : 
                                                                 2'b00;

    assign o_sc_data_b_src = i_mem_addr == i_ex_rt && i_mem_wb ? 2'b10 :
                             i_wb_addr  == i_ex_rt && i_wb_wb  ? 2'b01 :
                                                                 2'b00;

endmodule