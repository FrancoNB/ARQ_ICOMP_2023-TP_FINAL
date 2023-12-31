`ifndef __DEBUGGER_VH__
`define __DEBUGGER_VH__
    `include "common.vh"

    `define DEFAULT_DEBUGGER_UART_BUS_SIZE          8
    `define DEFAULT_DEBUGGER_IN_BUS_SIZE            `DEFAULT_DEBUGGER_UART_BUS_SIZE * 4
    `define DEFAULT_DEBUGGER_OUT_BUS_SIZE           `DEFAULT_DEBUGGER_UART_BUS_SIZE * 7
    `define DEFAULT_DEBUGGER_REGISTER_SIZE          `ARQUITECTURE_BITS
    `define DEFAULT_DEBUGGER_MEMORY_SLOT_SIZE       `ARQUITECTURE_BITS
    `define DEFAULT_DEBUGGER_REGISTER_BANK_BUS_SIZE `DEFAULT_DEBUGGER_REGISTER_SIZE * 32
    `define DEFAULT_DEBUGGER_MEMORY_DATA_BUS_SIZE   `ARQUITECTURE_BITS * 32

`endif // __DEBUGGER_VH__