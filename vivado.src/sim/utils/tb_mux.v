`timescale 1ns / 1ps

module tb_mux;

    localparam CHANNELS_2 = 2;
    localparam CHANNELS_4 = 4;
    localparam BUS_SIZE = 32;

    reg [CHANNELS_2 - 1 : 0] selector_2;
    reg [CHANNELS_2 * BUS_SIZE - 1 : 0] data_in_2;
    wire [BUS_SIZE - 1 : 0] data_out_2;

    reg [CHANNELS_4 - 1 : 0] selector_4;
    reg [CHANNELS_4 * BUS_SIZE - 1 : 0] data_in_4;
    wire [BUS_SIZE - 1 : 0] data_out_4;

    mux #(CHANNELS_2, BUS_SIZE) mux_2 (
        .selector(selector_2),
        .data_in(data_in_2),
        .data_out(data_out_2)
    );

    mux #(CHANNELS_4, BUS_SIZE) mux_4 (
        .selector(selector_4),
        .data_in(data_in_4),
        .data_out(data_out_4)
    );
    
    integer i = 0;

    initial begin
        $display("Comprobando el mux de 2 canales...");

        // Inicializar data_in_2 con datos secuenciales
        for (i = 0; i < CHANNELS_2; i = i + 1) begin
            data_in_2[BUS_SIZE * i +: BUS_SIZE] = $random;
        end

        selector_2 = 0;
        #10;
        if (data_out_2 !== data_in_2[BUS_SIZE * selector_2 +: BUS_SIZE])
            $display("TEST 1 NO PASS. data_out_2 = %b, expected = %b", data_out_2, data_in_2[BUS_SIZE * selector_2 +: BUS_SIZE]);
        else $display("TEST 1 PASS.");

        selector_2 = 1;
        #10;
        if (data_out_2 !== data_in_2[BUS_SIZE * selector_2 +: BUS_SIZE])
            $display("TEST 2 NO PASS. data_out_2 = %b, expected = %b", data_out_2, data_in_2[BUS_SIZE * selector_2 +: BUS_SIZE]);
        else $display("TEST 2 PASS.");

        $display("Comprobando el mux de 4 canales...");

        for (i = 0; i < CHANNELS_4; i = i + 1) begin
            data_in_4[BUS_SIZE * i +: BUS_SIZE] = $random;
        end

        selector_4 = 0;
        #10;
        if (data_out_4 !== data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE])
            $display("TEST 3 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE]);
        else $display("TEST 3 PASS.");

        selector_4 = 1;
        #10;
        if (data_out_4 !== data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE])
            $display("TEST 4 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE]);
        else $display("TEST 4 PASS.");

        selector_4 = 2;
        #10;
        if (data_out_4 !== data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE])
            $display("TEST 5 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE]);
        else $display("TEST 5 PASS.");
        
        selector_4 = 3;
        #10;
        if (data_out_4 !== data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE])
            $display("TEST 6 NO PASS. data_out_4 = %b, expected = %b", data_out_4, data_in_4[BUS_SIZE * selector_4 +: BUS_SIZE]);
        else $display("TEST 6 PASS.");
        
        $finish;
    end

endmodule
