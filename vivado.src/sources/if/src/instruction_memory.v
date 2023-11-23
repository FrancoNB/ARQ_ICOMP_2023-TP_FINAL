`timescale 1ns / 1ps

`include "instruction_memory.vh"

module instruction_memory 
    #(
        parameter REG_SIZE = `DEFAULT_INSTRUCTION_MEMORY_REG_SIZE,
        parameter MEM_SIZE = `DEFAULT_INSTRUCTION_MEMORY_MEM_SIZE
    )
    (
        input  wire                            i_clk,
        input  wire                            i_reset,
        input  wire                            i_instruction_write,
        input  wire                            i_start,
        input  wire [$clog2(MEM_SIZE) - 1 : 0] i_pc,
        input  wire [REG_SIZE - 1 : 0]         i_instruction,
        output wire [REG_SIZE - 1 : 0]         o_instruction
    );

    localparam TOTAL_INSTRUCTIONS = MEM_SIZE / REG_SIZE;

    reg [`BITS_FOR_STATE_COUNTER_INSTRUCTION_MEMORY - 1 : 0] state, state_next;
    reg [REG_SIZE - 1 : 0]                                   instruction_output, instruction_output_next;
    reg [MEM_SIZE - 1 : 0]                                   instruction_buffer, instruction_buffer_next;
    reg [$clog2(TOTAL_INSTRUCTIONS) - 1 : 0]                 total_instructions, total_instructions_next;

    always @(posedge i_clk or posedge i_reset) 
    begin
        if (i_reset) 
            begin
                state              <= `STATE_INSTRUCTION_MEMORY_IDLE;
                instruction_buffer <= `CLEAR(MEM_SIZE);
                instruction_output <= `CLEAR(REG_SIZE);
                total_instructions <= TOTAL_INSTRUCTIONS;
            end 
        else 
            begin
                state              <= state_next;
                instruction_buffer <= instruction_buffer_next;
                total_instructions <= total_instructions_next;
                instruction_output <= instruction_output_next;
            end
    end

    always @* begin
        state_next              = state;
        instruction_buffer_next = instruction_buffer;
        total_instructions_next = total_instructions;
        instruction_output_next = instruction_output;

        case (state)
            `STATE_INSTRUCTION_MEMORY_IDLE: 
            begin
                if (i_instruction_write) 
                    state_next = `STATE_INSTRUCTION_MEMORY_WRITE_INSTRUCTION;
            end

            `STATE_INSTRUCTION_MEMORY_WRITE_INSTRUCTION: 
            begin
                instruction_buffer_next = { i_instruction, instruction_buffer[MEM_SIZE - 1 : REG_SIZE] };

                if (i_instruction == `INSTRUCTION_HALT) 
                    begin     
                        instruction_buffer_next = instruction_buffer_next >> (REG_SIZE * (total_instructions - 1));
                        state_next              = `STATE_INSTRUCTION_MEMORY_READY_TO_EXECUTE;
                    end 
                else 
                    begin
                        total_instructions_next = total_instructions - 1;
                        state_next              = `STATE_INSTRUCTION_MEMORY_IDLE;
                    end
            end

            `STATE_INSTRUCTION_MEMORY_READY_TO_EXECUTE: 
            begin
                instruction_output_next = instruction_buffer[0 +: REG_SIZE];
                
                if (i_start)
                    state_next = `STATE_INSTRUCTION_MEMORY_SEND_INSTRUCTION;
            end

            `STATE_INSTRUCTION_MEMORY_SEND_INSTRUCTION: 
                instruction_output_next = instruction_buffer[i_pc +: REG_SIZE];
        endcase
    end

    assign o_instruction = instruction_output;

endmodule
