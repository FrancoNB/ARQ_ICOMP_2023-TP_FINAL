`ifndef __COMMON_VH__
`define __COMMON_VH__
    `define HIGH 1'b1
    `define LOW  1'b0

    `define CLEAR(len) { len {`LOW}}
    `define SET  (len) { len {`HIGH}}
`endif // __COMMON_VH__