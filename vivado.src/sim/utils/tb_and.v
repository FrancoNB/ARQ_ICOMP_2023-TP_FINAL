`timescale 1ns / 1ps

`include "tb.vh"

module tb_and;

    localparam CHANNELS = 4;

    reg  [CHANNELS - 1 : 0] in_data;
    wire                    out_result;

    _and 
    #(
        .CHANNELS (CHANNELS)
    ) 
    dut 
    (
        .in  (in_data),
        .out (out_result)
    );

    initial 
    begin
        in_data = { CHANNELS {`HIGH} };
        #10;
        if (out_result !== `HIGH) 
            $display("TEST 1 ERROR.");
        else
            $display("TEST 1 PASS.");

        in_data = { { (CHANNELS - 1) {`HIGH} }, `LOW };
        #10;
        if (out_result !== `LOW)
            $display("TEST 2 ERROR.");
        else
            $display("TEST 2 PASS.");

        $finish;
    end

endmodule