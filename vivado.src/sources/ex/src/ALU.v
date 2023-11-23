`timescale 1ns / 1ps

`include "alu.vh"

module alu
    #(
        parameter IO_BUS_WIDTH  = `IO_BUS_WIDTH,
        parameter CTR_BUS_WIDTH = `CTR_BUS_WIDTH
    )
    (
        input         [CTR_BUS_WIDTH - 1 : 0] ctr_code, 
        input  signed [IO_BUS_WIDTH - 1 : 0]  data_a,
        input  signed [IO_BUS_WIDTH - 1 : 0]  data_b,
        output signed [IO_BUS_WIDTH - 1 : 0]  out_data
    );
    
    reg[IO_BUS_WIDTH - 1 : 0] result;

    always@(*)
    begin
        case(ctr_code)
            `CTR_SLL   : result = data_a << data_b;
            `CTR_SRL   : result = data_a >> data_b;
            `CTR_SRA   : result = data_a >>> data_b;
            `CTR_ADD   : result = data_a + data_b;
            `CTR_SUB   : result = data_a - data_b;
            `CTR_AND   : result = data_a & data_b;
            `CTR_OR    : result = data_a | data_b;
            `CTR_XOR   : result = data_a ^ data_b;
            `CTR_NOR   : result = ~(data_a | data_b);
            `CTR_SLT   : result = data_a < data_b;
            `CTR_SLLV  : result = data_a << data_b;
            `CTR_SRLV  : result = data_a >> data_b;
            `CTR_SRAV  : result = data_a >>> data_b;
            `CTR_SLL16 : result = data_a << 16;
            `CTR_NEQ   : result = (data_a == data_b);
            default    : result = {IO_BUS_WIDTH {1'bz}};
        endcase
    end
    
    assign out_data = result; 
    
endmodule