`timescale 1ns / 1ps

`include "pc.vh"

module pc
    #(
        parameter PC_SIZE = `DEFAULT_PC_SIZE
    )
    (
        input  wire                   i_clk, 
        input  wire                   i_reset,
        input  wire                   i_halt,
        input  wire                   i_not_load,
        input  wire                   i_enable,
        input  wire                   i_flush,
        input  wire                   i_clear,                        
        input  wire [PC_SIZE - 1 : 0] i_next_pc,
        output wire [PC_SIZE - 1 : 0] o_pc
    );

    reg [`BITS_FOR_STATE_COUNTER_PC - 1 : 0] state, state_next; 
    reg [PC_SIZE - 1 : 0]                    pc;

    always @ (negedge i_clk) 
    begin
        if(i_reset || i_flush || i_clear)
            state <= `STATE_PC_IDLE;
        else
            state <= state_next;
    end

    always @ (*) 
    begin
        state_next = state;

        case(state)
            `STATE_PC_IDLE: 
                begin
                    pc         = `CLEAR(PC_SIZE);
                    state_next = `STATE_PC_NEXT;
                end

            `STATE_PC_NEXT:
                begin
                    if (i_enable)
                        begin
                            if(i_halt)
                                state_next = `STATE_PC_PROGRAM_END;
                            else 
                                begin
                                    if(i_not_load)
                                        state_next = `STATE_PC_NOT_LOAD;
                                    else
                                        begin
                                            pc         = i_next_pc;
                                            state_next = `STATE_PC_NEXT;
                                        end
                                end
                        end
                end
            
            `STATE_PC_NOT_LOAD:
                state_next = `STATE_PC_NEXT;

            `STATE_PC_PROGRAM_END:
            begin
                if(~i_halt)
                    state_next = `STATE_PC_IDLE;
            end

        endcase
    end

    assign o_pc = pc;

endmodule