// 分频模块：50MHz→1kHz（数码管扫描）、50MHz→1Hz（时间脉冲）
module Clock_Divider(
    input         clk_50mhz,  // 输入50MHz系统时钟
    input         rst_n,      // 低电平有效复位信号
    output reg    clk_1khz,   // 输出1kHz数码管扫描时钟
    output reg    clk_1hz     // 输出1Hz时间计数时钟
);

// 分频计数器定义：50MHz→1kHz需计数24999，50MHz→1Hz需计数24999999
reg [16:0] cnt_1khz;  // 1kHz分频计数器（足够容纳24999）
reg [24:0] cnt_1hz;   // 1Hz分频计数器（足够容纳24999999）

// 1kHz分频逻辑（50MHz / (2*25000) = 1kHz，利用翻转实现分频）
always @(posedge clk_50mhz or negedge rst_n) begin
    if(!rst_n) begin  // 复位信号有效，计数器清零，时钟置低
        cnt_1khz <= 17'd0;
        clk_1khz <= 1'b0;
    end else begin
        if(cnt_1khz >= 17'd24999) begin  // 计数达到阈值，翻转时钟，清零计数器
            cnt_1khz <= 17'd0;
            clk_1khz <= ~clk_1khz;
        end else begin  // 未达到阈值，计数器累加
            cnt_1khz <= cnt_1khz + 17'd1;
        end
    end
end

// 1Hz分频逻辑（50MHz / (2*25000000) = 1Hz）
always @(posedge clk_50mhz or negedge rst_n) begin
    if(!rst_n) begin
        cnt_1hz <= 25'd0;
        clk_1hz <= 1'b0;
    end else begin
        if(cnt_1hz >= 25'd24999999) begin
            cnt_1hz <= 25'd0;
            clk_1hz <= ~clk_1hz;
        end else begin
            cnt_1hz <= cnt_1hz + 25'd1;
        end
    end
end

endmodule