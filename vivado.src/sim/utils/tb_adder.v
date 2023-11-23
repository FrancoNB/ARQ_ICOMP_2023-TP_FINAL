`timescale 1ns / 1ps

module tb_adder;

    parameter BUS_SIZE = 32;

    reg [BUS_SIZE-1:0] a;
    reg [BUS_SIZE-1:0] b;
    wire [BUS_SIZE-1:0] sum;

    adder #(BUS_SIZE) dut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        repeat (10) 
        begin
            a = $random;
            b = $random;

            $display("Input: a = %h, b = %h", a, b);
            #10;
            
            if (sum !== a + b)
                $display("TEST ERROR: sum = %h, expected = %h", sum, a + b);
            else
                $display("TEST PASS: sum = %h", sum);
        end
        
        $finish;
    end

endmodule
