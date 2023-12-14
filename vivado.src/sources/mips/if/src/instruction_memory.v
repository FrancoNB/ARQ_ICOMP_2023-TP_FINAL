`timescale 1ns / 1ps

`include "instruction_memory.vh"

module instruction_memory 
    #(
        parameter WORD_SIZE_IN_BYTES = `DEFAULT_INSTRUCTION_MEMORY_WORD_SIZE_IN_BYTES,
        parameter MEM_SIZE_IN_WORDS  = `DEFAULT_INSTRUCTION_MEMORY_MEM_SIZE_IN_WORDS
    )
    (
        input  wire                              i_clk,
        input  wire                              i_reset,
        input  wire                              i_clear,
        input  wire                              i_instruction_write,
        input  wire [POINTER_SIZE - 1 : 0]       i_pc,
        input  wire [WORD_SIZE_IN_BITS - 1 : 0]  i_instruction,
        output wire                              o_full,
        output wire                              o_empty,
        output wire [WORD_SIZE_IN_BITS - 1 : 0]  o_instruction
    );

    localparam WORD_SIZE_IN_BITS   = WORD_SIZE_IN_BYTES * `BYTE_SIZE;
    localparam MEM_SIZE_IN_BITS    = MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BITS + WORD_SIZE_IN_BITS;
    localparam POINTER_SIZE        = $clog2(MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BYTES);
    localparam MAX_POINTER_DIR     = MEM_SIZE_IN_WORDS * WORD_SIZE_IN_BYTES;

    reg [`BITS_FOR_STATE_COUNTER_INSTRUCTION_MEMORY - 1 : 0] state, state_next;
    reg [WORD_SIZE_IN_BITS - 1 : 0]                          instruction_output;
    reg [POINTER_SIZE - 1 : 0]                               write_pointer, write_pointer_next;
    reg [MEM_SIZE_IN_BITS - 1 : 0]                           memory_buffer, memory_buffer_next;
    reg                                                      full, empty, full_next, empty_next;
    reg                                                      write_operation_started;
    
    always @(posedge i_clk or posedge i_reset or posedge i_clear) 
    begin
        if (i_reset || i_clear) 
            begin
                state                   <= `STATE_INSTRUCTION_MEMORY_WRITE;
                memory_buffer           <= `CLEAR(MEM_SIZE_IN_BITS);
                instruction_output      <= `CLEAR(WORD_SIZE_IN_BITS);
                full                    <= `LOW;
                empty                   <= `HIGH;
                write_operation_started <= `LOW;
                write_pointer           <= `CLEAR(POINTER_SIZE);
            end 
        else 
            begin
                state         <= state_next;
                memory_buffer <= memory_buffer_next;
                write_pointer <= write_pointer_next;
                full          <= full_next;
                empty         <= empty_next;
            end
    end

    always @(negedge i_clk)
    begin
        write_operation_started = `LOW;
    end

    always @(*) begin
        state_next         = state;
        memory_buffer_next = memory_buffer;
        write_pointer_next = write_pointer;
        full_next          = full;
        empty_next         = empty;

        case (state)
            `STATE_INSTRUCTION_MEMORY_WRITE: 
            begin
                if(~full && i_instruction_write && ~write_operation_started)
                    begin
                        empty_next = `LOW;
                        write_operation_started = `HIGH;
                        
                        memory_buffer_next = { i_instruction, memory_buffer[MEM_SIZE_IN_BITS - 1 : WORD_SIZE_IN_BITS] };

                        if (i_instruction == `INSTRUCTION_HALT) 
                            begin     
                                memory_buffer_next = memory_buffer_next >> (WORD_SIZE_IN_BITS * ((MAX_POINTER_DIR - write_pointer) / WORD_SIZE_IN_BYTES ));
                                state_next         = `STATE_INSTRUCTION_MEMORY_READ;
                            end 
                        else 
                            begin
                                if(write_pointer == MAX_POINTER_DIR)
                                    full_next = `HIGH;
                                else
                                    begin
                                        write_pointer_next = write_pointer + WORD_SIZE_IN_BYTES;
                                    end
                            end
                    end
            end

            `STATE_INSTRUCTION_MEMORY_READ:
            begin
                if (~empty)
                    instruction_output = memory_buffer[i_pc * `BYTE_SIZE +: WORD_SIZE_IN_BITS];
            end

        endcase
    end

    assign o_instruction = instruction_output;
    assign o_full        = full;
    assign o_empty       = empty;

endmodule
