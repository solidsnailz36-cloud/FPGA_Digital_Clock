// quick_buzzer_test.v - 快速测试
`timescale 100ns/10ns
module quick_test;
    reg clk=0, rst=0, trig=0;
    wire buzzer;
    
    Buzzer_Driver dut(clk, rst, trig, buzzer);
    
    always #5000 clk = ~clk;
    
    initial begin
        #10000; rst=1;
        #10000; trig=1; #10000; trig=0;
        #200000000;  // 20ms观察
        $stop;
    end
endmodule