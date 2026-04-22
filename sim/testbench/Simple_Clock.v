`timescale 1ns/1ns

module test_seven_seg_tb;

reg clk_1khz;
reg rst_n;
reg [3:0] num_h1, num_h0, num_m1, num_m0, num_s1, num_s0;
wire [5:0] seg_en;
wire [6:0] seg_data;

// 实例化要测试的模块√
Seven_Seg_Driver uut(
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .num_h1(num_h1),
    .num_h0(num_h0),
    .num_m1(num_m1),
    .num_m0(num_m0),
    .num_s1(num_s1),
    .num_s0(num_s0),
    .seg_en(seg_en),
    .seg_data(seg_data)
);

// 生成1kHz时钟
initial clk_1khz = 0;
always #500000 clk_1khz = ~clk_1khz;  // 1ms周期

// 测试流程
initial begin
    // 复位
    rst_n = 0;
    num_h1 = 4'd1; num_h0 = 4'd2;
    num_m1 = 4'd3; num_m0 = 4'd4;
    num_s1 = 4'd5; num_s0 = 4'd6;
    #1000000;
    rst_n = 1;
    
    // 观察扫描过程
    $display("=== 开始测试数码管驱动 ===");
    
    // 运行完整扫描周期
    #6000000;  // 6ms，完整扫描一遍
    
    // 改变显示数字
    num_h1 = 4'd0; num_h0 = 4'd9;
    num_m1 = 4'd5; num_m0 = 4'd9;
    num_s1 = 4'd5; num_s0 = 4'd9;
    #6000000;
    
    $display("=== 测试完成 ===");
    $stop;
end

// 监控输出
always @(posedge clk_1khz) begin
    $display("时间: %t ms, seg_en=%b, seg_data=%b, 显示数字=%d",
             $time/1000000.0, seg_en, seg_data, 
             {num_h1, num_h0, num_m1, num_m0, num_s1, num_s0});
end

endmodule