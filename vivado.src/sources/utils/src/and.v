`timescale 1ns / 1ps

`include "and.vh"

module _and
    #(
        parameter CHANNELS = `DEFAULT_AND_CHANNELS
    )
    (
        input  wire [CHANNELS - 1 : 0] in,
        output wire                    out
    );

    assign out = &in; 

endmodule