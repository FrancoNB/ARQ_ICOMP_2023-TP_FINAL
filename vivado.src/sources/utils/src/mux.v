`timescale 1ns / 1ps

`include "mux.vh"

module mux
    #(
        parameter CHANNELS = `DEFAULT_MUX_CHANNELS,
        parameter BUS_SIZE = `DEFAULT_MUX_BUS_SIZE
    )
    (
        input  wire [CHANNELS - 1 : 0] selector,
        input  wire [BUS_SIZE - 1 : 0] data_in [CHANNELS - 1 : 0], 
        output wire [BUS_SIZE - 1 : 0] data_out 
    );
          
    assign data_out = data_in[selector];

endmodule