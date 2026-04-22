// 按键处理模块：消抖+功能解析（低电平按键有效）
module Key_Process(
    input         clk_1khz,   // 1kHz扫描时钟（消抖采样）
    input         rst_n,      // 低电平有效复位
    input [4:0]   key_in,     // 5个按键输入（[0]模式切换、[1]设置确认、[2]小时+、[3]分钟+、[4]秒+）
    output reg    mode_switch,// 模式切换触发（上升沿有效）
    output reg    set_confirm,// 设置确认触发（上升沿有效）
    output reg [2:0] key_add // 加减按键（[0]小时+、[1]分钟+、[2]秒+）
);

// 步骤1：按键同步与消抖（20ms稳定采样：1kHz×20=20次）
reg [4:0] key_sync [1:0];  // 按键同步寄存器（消除亚稳态）
reg [4:0] key_filter;      // 消抖后按键值
reg [4:0] key_last;        // 上一时刻按键值
reg [5:0] cnt_filter;      // 消抖计数器

always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        key_sync[0] <= 5'b11111;
        key_sync[1] <= 5'b11111;
        key_filter <= 5'b11111;
        cnt_filter <= 6'd0;
    end else begin
        // 按键同步：两级寄存器缓存
        key_sync[0] <= key_in;
        key_sync[1] <= key_sync[0];
        // 按键电平稳定时，计数器累加
        if(key_sync[0] == key_sync[1]) begin
            if(cnt_filter >= 6'd20) begin  // 20ms稳定，保存消抖结果
                key_filter <= key_sync[1];
                cnt_filter <= 6'd0;
            end else begin
                cnt_filter <= cnt_filter + 6'd1;
            end
        end else begin  // 电平不稳定，计数器清零
            cnt_filter <= 6'd0;
        end
    end
end

// 步骤2：按键功能解析（捕捉下降沿：按键按下触发）
always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        mode_switch <= 1'b0;
        set_confirm <= 1'b0;
        key_add <= 3'b000;
        key_last <= 5'b11111;
    end else begin
        key_last <= key_filter;  // 保存上一时刻消抖结果
        // 模式切换按键（key_in[0]）
        mode_switch <= (key_last[0] == 1'b1) && (key_filter[0] == 1'b0);
        // 设置确认按键（key_in[1]）
        set_confirm <= (key_last[1] == 1'b1) && (key_filter[1] == 1'b0);
        // 加按键：小时+、分钟+、秒+（key_in[2]、[3]、[4]）
        key_add[0] <= (key_last[2] == 1'b1) && (key_filter[2] == 1'b0);
        key_add[1] <= (key_last[3] == 1'b1) && (key_filter[3] == 1'b0);
        key_add[2] <= (key_last[4] == 1'b1) && (key_filter[4] == 1'b0);
        // 减按键：复用加按键，释放时触发（简化作业硬件需求）
    end
end

endmodule