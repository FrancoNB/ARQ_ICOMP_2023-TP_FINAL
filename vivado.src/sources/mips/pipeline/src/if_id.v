`timescale 1ns / 1ps

`include "if_id.vh"

module if_id
    #(
        parameter PC_SIZE          = `DEFAULT_PC_SIZE,
        parameter INSTRUCTION_SIZE = `DEFAULT_ID_INSTRUCTION_SIZE
    )
    (
        input  wire                            i_clk,
        input  wire                            i_reset,
        input  wire                            i_enable,
        input  wire                            i_flush,
        input  wire [PC_SIZE - 1 : 0]          i_next_seq_pc,
        input  wire [INSTRUCTION_SIZE - 1 : 0] i_instruction,
        output wire [PC_SIZE - 1 : 0]          o_next_seq_pc,
        output wire [INSTRUCTION_SIZE - 1 : 0] o_instruction
    );

    reg [PC_SIZE - 1 : 0]          next_seq_pc;
    reg [INSTRUCTION_SIZE - 1 : 0] instruction;

    always @(posedge i_clk or posedge i_reset or posedge i_flush) 
    begin
        if (i_reset || i_flush)
            begin
                next_seq_pc <= `CLEAR(PC_SIZE);
                instruction <= `CLEAR(INSTRUCTION_SIZE);
            end
        else if (i_enable)
            begin
                next_seq_pc <= i_next_seq_pc;
                instruction <= i_instruction;
            end
    end

    assign o_next_seq_pc = next_seq_pc;
    assign o_instruction = instruction;

endmodule