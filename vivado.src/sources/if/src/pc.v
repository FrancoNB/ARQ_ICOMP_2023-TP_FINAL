`timescale 1ns / 1ps

`include "pc.vh"

module pc
    #(
        parameter PC_SIZE = `DEFAULT_PC_SIZE
    )
    (
        input  wire                   i_clk, 
        input  wire                   i_reset,
        input  wire                   i_start,
        input  wire                   i_halt,
        input  wire                   i_not_load,
        input  wire                   i_enable,
        input  wire [PC_SIZE - 1 : 0] i_next_pc,
        output wire [PC_SIZE - 1 : 0] o_pc
    );

    reg [`BITS_FOR_STATE_COUNTER_PC - 1 : 0] state, state_next; 
    reg [PC_SIZE - 1 : 0]                    pc, pc_next;

    always @ (posedge i_clk or posedge i_reset) 
    begin
        if(i_reset)
            begin
                state <= `STATE_PC_IDLE;
                pc    <= `CLEAR(PC_SIZE);
            end
        else
            begin
                state <= state_next;
                pc    <= pc_next;
            end
    end

    always @ (*) 
    begin
        state_next = state;
        pc_next    = pc;

        case(state)
            `STATE_PC_IDLE: 
                begin
                    pc_next = `CLEAR(PC_SIZE);

                    if(i_start)
                        state_next = `STATE_PC_INCREMENT;
                end

            `STATE_PC_INCREMENT:
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
                                            pc_next    = i_next_pc;
                                            state_next = `STATE_PC_INCREMENT;
                                        end
                                end
                        end
                end
            
            `STATE_PC_NOT_LOAD:
                state_next = `STATE_PC_INCREMENT;

            `STATE_PC_PROGRAM_END:
            begin
                pc_next = `CLEAR(PC_SIZE);

                if(i_halt)
                    state_next = `STATE_PC_PROGRAM_END;
                else 
                    begin
                        if(i_start)
                            state_next = `STATE_PC_INCREMENT;
                        else
                            state_next = `STATE_PC_IDLE;
                    end
            end

        endcase
    end

    assign o_pc = pc;

endmodule