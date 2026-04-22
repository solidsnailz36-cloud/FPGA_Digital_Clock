// 7段数码管驱动模块：6位动态扫描（共阴数码管）
module Seven_Seg_Driver(
    input         clk_1khz,   // 1kHz扫描时钟
    input         rst_n,      // 低电平有效复位
    input [3:0]   num_h1,     // 小时十位（0-2）
    input [3:0]   num_h0,     // 小时个位（0-9）
    input [3:0]   num_m1,     // 分钟十位（0-5）
    input [3:0]   num_m0,     // 分钟个位（0-9）
    input [3:0]   num_s1,     // 秒十位（0-5）
    input [3:0]   num_s0,     // 秒个位（0-9）
    output reg [5:0] seg_en,  // 6位位选（低电平有效，选通对应数码管）
    output reg [6:0] seg_data // 7段位选（a-g，高位到低位：g f e d c b a）
);

// 步骤1：定义共阴数码管段码表（0-9）
reg [6:0] seg_code[0:9];
initial begin
    seg_code[0] = 7'b0111111; // 数字0
    seg_code[1] = 7'b0000110; // 数字1
    seg_code[2] = 7'b1011011; // 数字2
    seg_code[3] = 7'b1001111; // 数字3
    seg_code[4] = 7'b1100110; // 数字4
    seg_code[5] = 7'b1101101; // 数字5
    seg_code[6] = 7'b1111101; // 数字6
    seg_code[7] = 7'b0000111; // 数字7
    seg_code[8] = 7'b1111111; // 数字8
    seg_code[9] = 7'b1101111; // 数字9
end

// 步骤2：扫描计数器（0-5，依次选通6位数码管）
reg [2:0] scan_cnt;
always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        scan_cnt <= 3'd0;
    end else begin
        if(scan_cnt >= 3'd5) begin
            scan_cnt <= 3'd0;
        end else begin
            scan_cnt <= scan_cnt + 3'd1;
        end
    end
end

// 步骤3：动态扫描逻辑（选通数码管+输出段码）
always @(*) begin
    if(!rst_n) begin
        seg_en = 6'b111111;
        seg_data = 7'b0000000;
    end else begin
        case(scan_cnt)
            3'd0: begin // 第1位：小时十位
                seg_en = 6'b111110;
                seg_data = seg_code[num_h1];
            end
            3'd1: begin // 第2位：小时个位
                seg_en = 6'b111101;
                seg_data = seg_code[num_h0];
            end
            3'd2: begin // 第3位：分钟十位
                seg_en = 6'b111011;
                seg_data = seg_code[num_m1];
            end
            3'd3: begin // 第4位：分钟个位
                seg_en = 6'b110111;
                seg_data = seg_code[num_m0];
            end
            3'd4: begin // 第5位：秒十位
                seg_en = 6'b101111;
                seg_data = seg_code[num_s1];
            end
            3'd5: begin // 第6位：秒个位
                seg_en = 6'b011111;
                seg_data = seg_code[num_s0];
            end
            default: begin
                seg_en = 6'b111111;
                seg_data = 7'b0000000;
            end
        endcase
    end
end

endmodule