// 简易时钟Testbench：仿真激励源（适配Quartus II + ModelSim）
`timescale 100ns/10ns// 时间单位/时间精度

module Top_Clock_Testbench;

// 1. 定义激励信号
reg         clk_50mhz;  // 50MHz仿真时钟
reg         rst_n;      // 复位信号
reg [4:0]   key_in;     // 按键输入

// 2. 定义观测信号（可选，方便仿真波形查看）
wire [5:0]  seg_en;
wire [6:0]  seg_data;
wire        buzzer_out;
//wire  [3:0] num_h1,num_h0,num_m1,num_m0,num_s1,num_s0;

// 3. 实例化顶层模块
Top_Clock u_Top_Clock(
    .clk_50mhz(clk_50mhz),
    .rst_n(rst_n),
    .key_in(key_in),
    .seg_en(seg_en),
    .seg_data(seg_data),
    .buzzer_out(buzzer_out)
);

// 4. 生成50MHz仿真时钟（周期20ns）
initial begin
    clk_50mhz = 1'b0;
    forever #10 clk_50mhz = ~clk_50mhz; // 每10ns翻转一次，对应50MHz
end

// 5. 生成复位信号与按键激励（模拟作业要求的功能）
initial begin
    // 初始状态
    rst_n = 1'b0;    // 复位有效
    key_in = 5'b11111; // 按键未按下（高电平）
    #2;            // 复位200ns
    rst_n = 1'b1;    // 释放复位
    #50000000;        // 等待1秒（仿真时间），正常走时
/*
    // 模拟：模式切换（按下KEY0）
    key_in[0] = 1'b0;
    #300000;          // 按键保持20ms
    key_in[0] = 1'b1;
    #10000000;        // 切换到正计时模式，运行1秒

    // 模拟：设置确认（按下KEY1）
    key_in[1] = 1'b0;
    #300000;
    key_in[1] = 1'b1;
    #5000000;         // 进入设置模式，调整时间

    // 模拟：小时+（按下KEY2）
    key_in[2] = 1'b0;
    #300000;
    key_in[2] = 1'b1;
    #5000000;

    // 模拟：倒计时模式切换+倒计时到0（触发蜂鸣器）
    key_in[0] = 1'b0;
    #300000;
    key_in[0] = 1'b1;
    #100000000;       // 运行10秒，等待倒计时到0
*/
    // 仿真结束
    $stop;
end

endmodule