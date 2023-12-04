`timescale 1ns / 1ps

`include "if_id.vh"

module if_id
    #(
        parameter PC_SIZE  = `DEFAULT_PC_SIZE,
        parameter BUS_SIZE = `DEFAULT_ID_BUS_SIZE
    )
    (
        input  wire                    i_clk,
        input  wire                    i_reset,
        input  wire                    i_enable,
        input  wire [PC_SIZE - 1 : 0]  i_next_seq_pc,
        input  wire [BUS_SIZE - 1 : 0] i_instruction,
        output wire [PC_SIZE - 1 : 0]  o_next_seq_pc,
        output wire [BUS_SIZE - 1 : 0] o_instruction
    );

    reg [PC_SIZE - 1 : 0]          next_seq_pc;
    reg [BUS_SIZE - 1 : 0] instruction;

    always @(posedge i_clk or posedge i_reset) 
    begin
        if (i_reset)
            begin
                next_seq_pc <= `CLEAR(PC_SIZE);
                instruction <= `CLEAR(BUS_SIZE);
            end
        else if (i_enable)
            begin
                next_seq_pc <= next_seq_pc;
                instruction <= instruction;
            end
    end

    assign o_next_seq_pc = next_seq_pc;
    assign o_instruction = instruction;

endmodule