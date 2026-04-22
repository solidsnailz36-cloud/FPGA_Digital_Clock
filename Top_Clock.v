// 顶层模块：整合所有子模块，作为工程入口
module Top_Clock(
    input         clk_50mhz,  // 50MHz系统时钟输入
    input         rst_n,      // 低电平有效复位
    input [4:0]   key_in,     // 5个按键输入
    output [5:0]  seg_en,     // 6位数码管位选
    output [6:0]  seg_data,   // 7位数码管段选
	 output        buzzer_out  // 蜂鸣器输出
);

// 中间信号定义（连接各子模块）
wire clk_1khz, clk_1hz;
wire mode_switch, set_confirm;
wire [2:0] key_add;
wire buzzer_trig;
wire [3:0] num_h1, num_h0, num_m1, num_m0, num_s1, num_s0;  // 改为wire
// 实例化分频模块
Clock_Divider u_Clock_Divider(
    .clk_50mhz(clk_50mhz),
    .rst_n(rst_n),
    .clk_1khz(clk_1khz),
    .clk_1hz(clk_1hz)
);

// 实例化按键处理模块
Key_Process u_Key_Process(
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .key_in(key_in),
    .mode_switch(mode_switch),
    .set_confirm(set_confirm),
    .key_add(key_add)
    //.key_sub(key_sub)
);

// 实例化时钟核心逻辑模块
Clock_Core u_Clock_Core(
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .mode_switch(mode_switch),
    .set_confirm(set_confirm),
    .key_add(key_add),
    //.key_sub(key_sub),
    .buzzer_trig(buzzer_trig),
    .num_h1(num_h1),.num_h0(num_h0),
    .num_m1(num_m1),.num_m0(num_m0),
    .num_s1(num_s1),.num_s0(num_s0)
);

// 实例化7段数码管驱动模块
Seven_Seg_Driver u_Seven_Seg_Driver(
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .num_h1(num_h1),.num_h0(num_h0),
    .num_m1(num_m1),.num_m0(num_m0),
    .num_s1(num_s1),.num_s0(num_s0),
    .seg_en(seg_en),
    .seg_data(seg_data)
);

// 实例化蜂鸣器驱动模块
Buzzer_Driver u_Buzzer_Driver(
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .buzzer_trig(buzzer_trig),
    .buzzer_out(buzzer_out)
);

endmodule