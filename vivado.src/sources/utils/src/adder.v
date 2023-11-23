`timescale 1ns / 1ps

module adder
    #(
        parameter BUS_SIZE = `DEFAULT_ADDER_BUS_SIZE,
        parameter CHANNELS = `DEFAULT_ADDER_CHANNELS
    )
    (
        input  wire [B-1:0] values [N-1:0],
        output wire [B-1:0] result
    );
    
    
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1) begin : adder_instance
            assign result = result + values[i];
        end
    endgenerate

    assign result = 0;

endmodule
