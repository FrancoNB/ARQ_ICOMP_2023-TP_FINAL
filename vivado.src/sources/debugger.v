`timescale 1ns / 1ps

`include "debugger.vh"

module debugger
    #(
        parameter UART_BUS_SIZE          = `DEFAULT_DEBUGGER_UART_BUS_SIZE,
        parameter REGISTER_SIZE          = `DEFAULT_DEBUGGER_REGISTER_SIZE,
        parameter REGISTER_BANK_BUS_SIZE = `DEFAULT_DEBUGGER_REGISTER_BANK_BUS_SIZE,
        parameter MEMORY_SLOT_SIZE       = `DEFAULT_DEBUGGER_MEMORY_SLOT_SIZE,
        parameter MEMORY_DATA_BUS_SIZE   = `DEFAULT_DEBUGGER_MEMORY_DATA_BUS_SIZE
    )
    (
        input  wire                                  i_clk,
        input  wire                                  i_reset,
        input  wire                                  i_uart_empty,
        input  wire                                  i_uart_full,
        input  wire                                  i_instruction_memory_empty,
        input  wire                                  i_instruction_memory_full,
        input  wire                                  i_mips_end_program,
        input  wire [UART_BUS_SIZE - 1 : 0]          i_uart_data_rd,
        input  wire [REGISTER_BANK_BUS_SIZE - 1 : 0] i_registers_conntent,
        input  wire [MEMORY_DATA_BUS_SIZE - 1 : 0]   i_memory_conntent,
        output wire                                  o_uart_wr,
        output wire                                  o_uart_rd,
        output wire                                  o_mips_instruction_wr,
        output wire                                  o_mips_flush,
        output wire                                  o_mips_clear_program,
        output wire                                  o_mips_enabled,
        output wire [UART_BUS_SIZE - 1 : 0]          o_uart_data_wr,
        output wire [REGISTER_SIZE - 1 : 0]          o_mips_instruction
    );

    localparam BYTES_PER_INSTRUCTION        = REGISTER_SIZE / `BYTE_SIZE;
    localparam BYTES_COUNTER_SIZE           = $clog2(BYTES_PER_INSTRUCTION);
    localparam UART_WR_BUFFER_SIZE          = UART_BUS_SIZE * 7;
    localparam UART_RD_BUFFER_SIZE          = UART_BUS_SIZE * 4;
    localparam UART_WR_BUFFER_POINTER_SIZE  = $clog2(UART_WR_BUFFER_SIZE / UART_BUS_SIZE);
    localparam UART_RD_BUFFER_POINTER_SIZE  = $clog2(UART_RD_BUFFER_SIZE / UART_BUS_SIZE);
    localparam REGISTER_POINTER_SIZE        = $clog2(REGISTER_BANK_BUS_SIZE / REGISTER_SIZE);
    localparam MEMORY_POINTER_SIZE          = $clog2(MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE);

    reg [3 : 0]                               state, state_next, return_state, return_state_next;
    reg                                       mips_flush, mips_enabled, mips_instruction_wr, mips_clear_program;
    reg                                       mips_flush_next, mips_enabled_next, mips_instruction_wr_next, mips_clear_program_next;
    reg                                       uart_wr, uart_rd;
    reg                                       uart_wr_next, uart_rd_next;
    reg [UART_BUS_SIZE - 1 : 0]               uart_data_wr, uart_data_wr_next;
    reg [REGISTER_SIZE - 1 : 0]               mips_instruction, mips_instruction_next;
    reg                                       execution_by_steps, execution_by_steps_next;
    reg                                       execution_debug, execution_debug_next;
    reg [UART_WR_BUFFER_SIZE - 1 : 0]         uart_wr_buffer, uart_wr_buffer_next;
    reg [UART_WR_BUFFER_POINTER_SIZE - 1 : 0] uart_wr_buffer_pointer, uart_wr_buffer_pointer_next;
    reg [UART_RD_BUFFER_SIZE - 1 : 0]         uart_rd_buffer, uart_rd_buffer_next;
    reg [UART_RD_BUFFER_POINTER_SIZE - 1 : 0] uart_rd_buffer_pointer, uart_rd_buffer_pointer_next;
    reg                                       uart_rd_available, uart_rd_available_next;
    reg [UART_BUS_SIZE - 1 : 0]               clk_counter, clk_counter_next;
    reg [REGISTER_POINTER_SIZE - 1 : 0]       register_pointer, register_pointer_next;
    reg [MEMORY_POINTER_SIZE - 1 : 0]         memory_pointer, memory_pointer_next;

    always @(posedge i_clk or posedge i_reset) 
    begin
        if (i_reset)
            begin
                state                  <= `DEBUGGER_STATE_IDLE;
                return_state           <= `DEBUGGER_STATE_IDLE;
                mips_enabled           <= `LOW;
                mips_instruction_wr    <= `LOW;
                mips_flush             <= `LOW;
                mips_clear_program     <= `LOW;
                uart_wr                <= `LOW;
                uart_rd                <= `LOW;
                uart_data_wr           <= `CLEAR(UART_BUS_SIZE);
                mips_instruction       <= `CLEAR(REGISTER_SIZE);
                execution_by_steps     <= `LOW;
                execution_debug        <= `LOW;
                uart_wr_buffer         <= `CLEAR(UART_WR_BUFFER_SIZE);
                uart_wr_buffer_pointer <= `CLEAR(UART_WR_BUFFER_POINTER_SIZE);
                uart_rd_buffer         <= `CLEAR(UART_RD_BUFFER_SIZE);
                uart_rd_buffer_pointer <= `CLEAR(UART_RD_BUFFER_POINTER_SIZE);
                uart_rd_available      <= `LOW;
                clk_counter            <= `CLEAR(BYTES_COUNTER_SIZE);
                register_pointer       <= `CLEAR(REGISTER_POINTER_SIZE);
                memory_pointer         <= `CLEAR(MEMORY_POINTER_SIZE);
            end
        else
            begin
                state                  <= state_next;
                return_state           <= return_state_next;
                mips_enabled           <= mips_enabled_next;
                mips_flush             <= mips_flush_next;
                mips_clear_program     <= mips_clear_program_next;
                mips_instruction_wr    <= mips_instruction_wr_next;
                uart_wr                <= uart_wr_next;
                uart_rd                <= uart_rd_next;
                uart_data_wr           <= uart_data_wr_next;
                mips_instruction       <= mips_instruction_next;
                execution_by_steps     <= execution_by_steps_next;
                execution_debug        <= execution_debug_next;
                uart_wr_buffer         <= uart_wr_buffer_next;
                uart_wr_buffer_pointer <= uart_wr_buffer_pointer_next;
                uart_rd_buffer         <= uart_rd_buffer_next;
                uart_rd_buffer_pointer <= uart_rd_buffer_pointer_next;
                uart_rd_available      <= uart_rd_available_next;
                clk_counter            <= clk_counter_next;
                register_pointer       <= register_pointer_next;
                memory_pointer         <= memory_pointer_next;
            end
    end
    
    always @(*)
    begin
        state_next                  = state;
        return_state_next           = return_state;
        mips_enabled_next           = mips_enabled;
        mips_instruction_wr_next    = mips_instruction_wr;
        mips_flush_next             = mips_flush;
        mips_clear_program_next     = mips_clear_program;
        uart_wr_next                = uart_wr;
        uart_rd_next                = uart_rd;
        uart_data_wr_next           = uart_data_wr;
        mips_instruction_next       = mips_instruction;
        execution_by_steps_next     = execution_by_steps;
        execution_debug_next        = execution_debug;
        uart_wr_buffer_next         = uart_wr_buffer;
        uart_wr_buffer_pointer_next = uart_wr_buffer_pointer;
        uart_rd_buffer_next         = uart_rd_buffer;
        uart_rd_buffer_pointer_next = uart_rd_buffer_pointer;
        uart_rd_available_next      = uart_rd_available;
        clk_counter_next            = clk_counter;
        register_pointer_next       = register_pointer;
        memory_pointer_next         = memory_pointer;
    
        case (state)
            /* ---------------------------------------------------- Estado Inicial ---------------------------------------------------- */

            `DEBUGGER_STATE_IDLE:
            begin
                mips_enabled_next        = `LOW;
                mips_flush_next          = `LOW;
                mips_instruction_wr_next = `LOW;
                uart_wr_next             = `LOW;
                mips_clear_program_next  = `LOW;

                if (uart_rd_available)
                    begin
                        case (uart_rd_buffer)
                            "L": 
                            begin
                                return_state_next = `DEBUGGER_STATE_LOAD;
                                state_next        = `DEBUGGER_STATE_UART_RD;
                            end

                            "F":
                            begin
                                mips_flush_next         = `HIGH;
                                mips_clear_program_next = `HIGH;
                            end

                            "E":
                            begin
                                execution_by_steps_next = `LOW;
                                execution_debug_next    = `LOW;
                                mips_enabled_next       = `HIGH;
                                mips_flush_next         = `HIGH;
                                state_next              = `DEBUGGER_STATE_RUN;
                            end

                            "S":
                            begin
                                clk_counter_next        = { { (UART_BUS_SIZE - 1) { 1'b0 } }, 1'b1 };
                                execution_by_steps_next = `HIGH;
                                execution_debug_next    = `LOW;
                                mips_enabled_next       = `HIGH;
                                mips_flush_next         = `HIGH;
                                state_next              = `DEBUGGER_STATE_RUN;
                            end

                            "D":
                            begin
                                clk_counter_next        = { { (UART_BUS_SIZE - 1) { 1'b0 } }, 1'b1 };
                                execution_by_steps_next = `LOW;
                                execution_debug_next    = `HIGH;
                                mips_enabled_next       = `HIGH;
                                mips_flush_next         = `HIGH;
                                state_next              = `DEBUGGER_STATE_RUN;
                            end

                            default:
                            begin
                                uart_wr_buffer_next = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_UNKNOWN_COMMAND};
                                return_state_next   = `DEBUGGER_STATE_IDLE;
                                state_next          = `DEBUGGER_STATE_UART_WR;
                            end
                        endcase
                    end
                else
                    begin
                        return_state_next = `DEBUGGER_STATE_IDLE;
                        state_next        = `DEBUGGER_STATE_UART_RD;
                    end
            end

            /* ---------------------------------------------------- Cargar Programa ---------------------------------------------------- */

            `DEBUGGER_STATE_LOAD:
            begin
                if (!i_instruction_memory_full)
                    begin
                        if (i_instruction_memory_empty)
                            begin
                                if (uart_rd_available)
                                    begin
                                        mips_instruction_wr_next = `HIGH;
                                        mips_instruction_next    = uart_rd_buffer;
                                    end
                                else
                                    begin
                                        mips_instruction_wr_next = `LOW;

                                        if (mips_instruction == `INSTRUCTION_HALT)
                                            state_next = `DEBUGGER_STATE_IDLE;
                                        else
                                            begin
                                                return_state_next   = `DEBUGGER_STATE_LOAD;
                                                state_next          = `DEBUGGER_STATE_UART_RD;
                                            end
                                    end
                            end
                        else
                            begin
                                uart_wr_buffer_next = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_ALREADY_PROGRAM_LOAD};
                                return_state_next   = `DEBUGGER_STATE_IDLE;
                                state_next          = `DEBUGGER_STATE_UART_WR;
                            end
                    end
                else
                    begin
                        uart_wr_buffer_next = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_INSTRUCTION_MEMORY_FULL};
                        return_state_next   = `DEBUGGER_STATE_IDLE;
                        state_next          = `DEBUGGER_STATE_UART_WR;
                    end
            end

            /* ---------------------------------------------------- Ejecución del Programa ---------------------------------------------------- */

            `DEBUGGER_STATE_RUN:
            begin
                mips_flush_next = `LOW;

                if (!i_instruction_memory_empty)
                    begin
                        if (uart_rd_available && execution_by_steps)
                            begin
                                case (uart_rd_buffer)
                                    "S":
                                    begin
                                        state_next = `DEBUGGER_STATE_IDLE;
                                    end

                                    "N":
                                    begin
                                        clk_counter_next  = clk_counter + 1;
                                        mips_enabled_next = `HIGH;
                                    end

                                    default:
                                    begin
                                        uart_wr_buffer_next = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_UNKNOWN_COMMAND};
                                        return_state_next   = `DEBUGGER_STATE_IDLE;
                                        state_next          = `DEBUGGER_STATE_UART_WR;
                                    end
                                endcase
                            end
                        else if (execution_by_steps && !i_mips_end_program)
                            begin
                                if (mips_enabled)
                                    begin
                                        mips_enabled_next = `LOW;
                                        state_next        = `DEBUGGER_STATE_PRINT_REGISTERS;
                                    end
                                else
                                    begin
                                        return_state_next = `DEBUGGER_STATE_RUN;
                                        state_next        = `DEBUGGER_STATE_UART_RD;
                                    end

                            end
                        else if (execution_debug && !i_mips_end_program)
                            begin
                                if (mips_enabled)
                                    begin
                                        mips_enabled_next = `LOW;
                                        state_next        = `DEBUGGER_STATE_PRINT_REGISTERS;
                                    end
                                else
                                    begin
                                        clk_counter_next  = clk_counter + 1;
                                        mips_enabled_next = `HIGH;
                                    end   
                            end
                        else if (i_mips_end_program)
                            begin
                                if (mips_enabled)
                                    begin
                                        mips_enabled_next = `LOW;
                                        state_next        = `DEBUGGER_STATE_PRINT_REGISTERS;
                                    end
                                else
                                    begin
                                        uart_wr_buffer_next = {`DEBUGGER_INFO_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_INFO_END_PROGRAM};
                                        return_state_next   = `DEBUGGER_STATE_IDLE;
                                        state_next          = `DEBUGGER_STATE_UART_WR;
                                    end
                            end
                    end
                else
                    begin
                        uart_wr_buffer_next = {`DEBUGGER_ERROR_PREFIX, `DEBUGGER_NO_CICLE_MASK, `DEBUGGER_NO_ADDRESS_MASK, `DEBUGGER_ERROR_NO_PROGRAM_LOAD};
                        return_state_next   = `DEBUGGER_STATE_IDLE;
                        state_next          = `DEBUGGER_STATE_UART_WR;
                    end
            end

            /* ---------------------------------------------------- Envia Registros y datos en Memoria ---------------------------------------------------- */

            `DEBUGGER_STATE_PRINT_REGISTERS:
            begin
                if (register_pointer < REGISTER_BANK_BUS_SIZE / REGISTER_SIZE)
                    begin
                        uart_wr_buffer_next   = {`DEBUGGER_INFO_PREFIX, (execution_debug || execution_by_steps) ? clk_counter : `DEBUGGER_NO_CICLE_MASK , { { (UART_BUS_SIZE - REGISTER_POINTER_SIZE) { 1'b0 } }, register_pointer } , i_registers_conntent[register_pointer * REGISTER_SIZE +: REGISTER_SIZE] };
                        register_pointer_next = register_pointer + 1;
                        return_state_next     = `DEBUGGER_STATE_PRINT_REGISTERS;
                        state_next            = `DEBUGGER_STATE_UART_WR;
                    end
                else
                    begin
                        register_pointer_next = `CLEAR(REGISTER_POINTER_SIZE);
                        state_next            = `DEBUGGER_STATE_PRINT_MEMORY_DATA;
                    end
            end

            `DEBUGGER_STATE_PRINT_MEMORY_DATA:
            begin
                if (memory_pointer < MEMORY_DATA_BUS_SIZE / MEMORY_SLOT_SIZE)
                    begin
                        uart_wr_buffer_next = {`DEBUGGER_INFO_PREFIX, (execution_debug || execution_by_steps) ? clk_counter : `DEBUGGER_NO_CICLE_MASK , { { (UART_BUS_SIZE - MEMORY_POINTER_SIZE) { 1'b0 } }, memory_pointer } , i_memory_conntent[memory_pointer * MEMORY_SLOT_SIZE +: MEMORY_SLOT_SIZE] };
                        memory_pointer_next = memory_pointer + 1;
                        return_state_next   = `DEBUGGER_STATE_PRINT_MEMORY_DATA;
                        state_next          = `DEBUGGER_STATE_UART_WR;
                    end
                else
                    begin
                        memory_pointer_next = `CLEAR(MEMORY_POINTER_SIZE);
                        state_next          = `DEBUGGER_STATE_RUN;
                    end
            end

            /* ---------------------------------------------------- Escritura de UART ---------------------------------------------------- */

            `DEBUGGER_STATE_UART_WR:
            begin
                if (!i_uart_full)
                    begin
                        if (uart_wr_buffer_pointer < UART_WR_BUFFER_SIZE / UART_BUS_SIZE)
                            begin
                                uart_data_wr_next           = uart_wr_buffer[uart_wr_buffer_pointer * `BYTE_SIZE +: `BYTE_SIZE];
                                uart_wr_next                = `HIGH;
                                uart_wr_buffer_pointer_next = uart_wr_buffer_pointer + 1;
                                state_next                  = `DEBUGGER_STATE_UART_WR_RESET;
                            end
                        else
                            begin
                                uart_wr_buffer_pointer_next = `CLEAR(UART_WR_BUFFER_POINTER_SIZE);
                                state_next                  = return_state;
                            end
                    end
            end

            `DEBUGGER_STATE_UART_WR_RESET:
            begin
                uart_wr_next = `LOW;
                state_next   = `DEBUGGER_STATE_UART_WR;
            end

            /* ---------------------------------------------------- Lectura de UART ---------------------------------------------------- */

            `DEBUGGER_STATE_UART_RD:
            begin
                if (!i_uart_empty)
                    begin
                        if (uart_rd_buffer_pointer < UART_RD_BUFFER_SIZE / UART_BUS_SIZE)
                            begin
                                uart_rd_buffer[uart_rd_buffer_pointer * UART_BUS_SIZE +: UART_BUS_SIZE] = i_uart_data_rd;
                                uart_rd_next                                                            = `HIGH;
                                uart_rd_buffer_pointer_next                                             = uart_rd_buffer_pointer + 1;
                                state_next                                                              = `DEBUGGER_STATE_UART_RD_RESET;
                                uart_rd_available_next                                                  = `LOW;
                            end
                        else
                            begin
                                uart_rd_available_next      = `HIGH;
                                uart_rd_buffer_pointer_next = `CLEAR(UART_RD_BUFFER_POINTER_SIZE);
                                state_next                  = return_state;
                            end
                    end
                else
                    state_next = return_state;
            end

            `DEBUGGER_STATE_UART_RD_RESET:
            begin
                uart_rd_next = `LOW;
                state_next   = `DEBUGGER_STATE_UART_RD;
            end
            
            /* ---------------------------------------------------------------------------------------------------------------------------- */

        endcase
    end

    assign o_uart_wr             = uart_wr;
    assign o_uart_rd             = uart_rd;
    assign o_mips_instruction    = mips_instruction;
    assign o_mips_instruction_wr = mips_instruction_wr;
    assign o_mips_flush          = mips_flush;
    assign o_mips_clear_program  = mips_clear_program;
    assign o_mips_enabled        = mips_enabled;
    assign o_uart_data_wr        = uart_data_wr;

endmodule