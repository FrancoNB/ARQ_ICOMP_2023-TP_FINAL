`ifndef __TB_VH__
`define __TB_VH__
    `include "common.vh"
    
    `define CLK_PERIOD       10

    `define CLK_TOGGLE(clk, period) \
        initial clk = 0; \
        always #(period / 2) clk = ~clk;
    
    `define TICKS_DELAY(clk_period, ticks) #(ticks * clk_period)
    
    `define TICKS_DELAY_1(clk_period)  `TICKS_DELAY(clk_period, 1)
    `define TICKS_DELAY_5(clk_period)  `TICKS_DELAY(clk_period, 5)
    `define TICKS_DELAY_10(clk_period) `TICKS_DELAY(clk_period, 10)
    
    `define RANDOM_TICKS_DELAY(clk_period, max_ticks) \
        #(($urandom_range(max_ticks - 1) + 1) * clk_period)

    `define RANDOM_TICKS_DELAY_MAX_10(clk_period) `RANDOM_TICKS_DELAY(clk_period, 10)
    `define RANDOM_TICKS_DELAY_MAX_20(clk_period) `RANDOM_TICKS_DELAY(clk_period, 20)
    `define RANDOM_TICKS_DELAY_MAX_30(clk_period) `RANDOM_TICKS_DELAY(clk_period, 30)
`endif // __TB_VH__