`ifndef __COMMON_VH__
`define __COMMON_VH__
    `define ARQUITECTURE_BITS 32

    `define HIGH 1'b1
    `define LOW  1'b0

    `define CLEAR(len) { len {`LOW}}
    `define SET  (len) { len {`HIGH}}

    `define INSTRUCTION_HALT `CLEAR(`ARQUITECTURE_BITS)
`endif // __COMMON_VH__