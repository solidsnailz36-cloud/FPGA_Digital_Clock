// 蜂鸣器驱动模块：重构逻辑，解决Error (10200)，适配Quartus II语法规范
module Buzzer_Driver(
    input         clk_1khz,   // 1kHz时钟
    input         rst_n,      // 低电平有效复位
    input         buzzer_trig,// 蜂鸣器触发信号（高电平有效）
    output reg    buzzer_out  // 蜂鸣器输出
);

reg [15:0] buzzer_cnt; // 蜂鸣器频率/时长计数器
reg       buzzer_en;  // 蜂鸣器使能标志（1：响铃，0：关闭）

// 步骤1：单独处理buzzer_en的置位与关闭（时序逻辑，仅由时钟/复位触发）
// 置位：buzzer_trig高电平触发；关闭：计数到10秒（1kHz×10=10秒）
always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        buzzer_en <= 1'b0;
        buzzer_cnt <= 16'd0;
    end else begin
        // 蜂鸣器触发：置位使能标志，清零计数器
        if(buzzer_trig) begin
            buzzer_en <= 1'b1;
            buzzer_cnt <= 16'd0;
        end
        // 蜂鸣器运行中：计数器累加，10秒后关闭
        else if(buzzer_en) begin
            if(buzzer_cnt >= 16'd4999) begin // 计数到10000，对应10秒
                buzzer_en <= 1'b0;
                buzzer_cnt <= 16'd0;
            end else begin
                buzzer_cnt <= buzzer_cnt + 16'd1;
            end
        end
        // 未触发/已关闭：保持初始状态
        else begin
            buzzer_en <= 1'b0;
            buzzer_cnt <= 16'd0;
        end
    end
end

// 步骤2：单独处理蜂鸣器间断响逻辑（500Hz频率，仅在使能时翻转）
always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        buzzer_out <= 1'b0;
    end else if(buzzer_en) begin
        // 1kHz时钟分频为500Hz（每1000个时钟翻转一次，对应500Hz）
        if(buzzer_cnt % 16'd2 == 0) begin // 简化分频，确保间断响
            buzzer_out <= ~buzzer_out;
        end
    end else begin
        buzzer_out <= 1'b0;
    end
end

endmodule