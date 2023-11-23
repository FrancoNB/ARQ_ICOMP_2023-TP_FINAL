`timescale 1ns / 1ps

module tb_pc;

    parameter PC_SIZE = 32;

    reg i_clk;
    reg i_reset;
    reg i_start;
    reg i_halt;
    reg i_not_load;
    reg i_enable;
    reg [PC_SIZE - 1 : 0] i_next_pc;

    wire [PC_SIZE - 1 : 0] o_pc;

    pc #(PC_SIZE) dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_start(i_start),
        .i_halt(i_halt),
        .i_not_load(i_not_load),
        .i_enable(i_enable),
        .i_next_pc(i_next_pc),
        .o_pc(o_pc)
    );

    always #5 i_clk = ~i_clk;

    initial begin
        i_clk = 0;
        i_reset = 1;
        i_start = 0;
        i_halt = 0;
        i_not_load = 0;
        i_next_pc = 0;

        #10 i_reset = 0;
        
        #10 i_enable = 1;
        #10 i_start = 1;
        #10 i_start = 0;
        
        repeat(10)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 10) $display("ERROR TEST 1"); else $display("PASS TEST 1");
        
        #10 i_enable = 0;

        repeat(10)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 10) $display("ERROR TEST 2"); else $display("PASS TEST 2");
        
        #10 i_enable = 1;
        #10 i_halt = 1;
        #10 i_halt = 0;
        
        repeat(5)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 0) $display("ERROR TEST 3"); else $display("PASS TEST 3");
        
        #10 i_start = 1;
        #10 i_start = 0;
        
        repeat(10)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 35) $display("ERROR TEST 4"); else $display("PASS TEST 4");
        
        #10 i_not_load = 1;
        
        repeat(5)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 35) $display("ERROR TEST 5"); else $display("PASS TEST 5");
        
        #10 i_not_load = 0;
        
        repeat(5)
        begin
            #10 i_next_pc = i_next_pc + 1;
        end
        
        #10;
        if (o_pc != 45) $display("ERROR TEST 6"); else $display("PASS TEST 6");
        
        #10 i_halt = 1;
        #10;

        #10;
        if (o_pc != 0) $display("ERROR TEST 7"); else $display("PASS TEST 7");
        
        $finish;
    end

endmodule
