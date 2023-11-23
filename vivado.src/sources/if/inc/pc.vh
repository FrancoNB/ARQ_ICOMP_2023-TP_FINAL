`ifndef __PC_VH__
`define __PC_VH__
    `define DEFAULT_PC_SIZE 32

    `define NUMBER_OF_STATE_PC        4
    `define BITS_FOR_STATE_COUNTER_PC $clog2(`NUMBER_OF_STATE_PC)

    `define STATE_PC_IDLE        2'b00
    `define STATE_PC_INCREMENT   2'b01
    `define STATE_PC_NOT_LOAD    2'b10
    `define STATE_PC_PROGRAM_END 2'b11

`endif // __PC_VH__