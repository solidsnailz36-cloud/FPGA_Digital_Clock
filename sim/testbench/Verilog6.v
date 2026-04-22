// 简化测试文件 - 确保能运行
`timescale 10ns/1ns

module Top_Clock_Testbench;

// 基本信号
reg         clk_50mhz;
reg         rst_n;
reg [4:0]   key_in;
wire [5:0]  seg_en;
wire [6:0]  seg_data;
wire        buzzer_out;

// 实例化
Top_Clock u_Top_Clock(
    .clk_50mhz(clk_50mhz),
    .rst_n(rst_n),
    .key_in(key_in),
    .seg_en(seg_en),
    .seg_data(seg_data),
    .buzzer_out(buzzer_out)
);

// 简单时钟
initial clk_50mhz = 0;
always #1 clk_50mhz = ~clk_50mhz;  // 10ns半周期 → 20ns周期=50MHz

// 简单测试
initial begin
    $display("=== 简单测试开始 ===");
    
    // 复位
    rst_n = 0;
    key_in = 5'b11111;
    #20;  // 200ns
    rst_n = 1;
    
    // 观察数码管输出
    #100000;  // 1ms
    
    // 按一次键
    key_in[0] = 0;
    #2000;    // 20us
    key_in[0] = 1;
    
    // 运行一段时间
    #500000;  // 5ms
    
    $display("=== 测试完成 ===");
    $stop;
end

// 监控数码管
always @(posedge clk_50mhz) begin
    if(seg_en != 6'b111111) begin
        $display("时间=%t, seg_en=%b, seg_data=%b", 
                $time*10, seg_en, seg_data);
    end
end

endmodule