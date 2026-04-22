// 时钟核心逻辑模块：3种模式+时间设置+定时+倒计时提醒
module Clock_Core(
    input         clk_1khz,    // 1kHz时钟
    input         rst_n,      // 低电平有效复位
    input         mode_switch,// 模式切换触发
    input         set_confirm,// 设置确认触发
    input [2:0]   key_add,    // 加减按键（小时+/分钟+/秒+）
    output reg    buzzer_trig,// 蜂鸣器触发信号
    output [3:0]  num_h1,num_h0,num_m1,num_m0,num_s1,num_s0 // 6位显示数字
);

// 步骤1：定义三种工作模式（作业要求）
parameter MODE_DISP   = 2'd0; // 模式1：显示当前时间
parameter MODE_UP     = 2'd1; // 模式2：正计时（从0累加）
parameter MODE_DOWN   = 2'd2; // 模式3：倒计时（从设置值递减）
parameter MODE_SET    = 2'd3;

reg [1:0] current_mode; // 当前工作模式
reg       set_flag;     // 设置模式标志（1：进入设置，0：退出设置）
reg       alarm_en;     // 定时响铃使能标志
reg [9:0]   i;

// 步骤2：定义时间寄存器（当前时间、定时时间）
reg [6:0] hour, min, sec;     // 时(0-23)、分(0-59)、秒(0-59)
reg [6:0] hourC, minC, secC;     // 时(0-23)、分(0-59)、秒(0-59)
reg [6:0] hourd, mind, secd;     // 时(0-23)、分(0-59)、秒(0-59)
reg [6:0] hourA, minA, secA;     // 时(0-23)、分(0-59)、秒(0-59)
reg [6:0] alarm_h, alarm_m,alarm_s;   // 定时时间（时、分）

// 新增：按键边沿检测寄存器
reg set_confirm_prev;
reg [2:0] key_add_prev;

// 步骤3：模式切换逻辑（循环切换：显示时间→正计时→倒计时→显示时间）
always @(posedge mode_switch or negedge rst_n) begin
    if(!rst_n) begin
        current_mode <= MODE_DISP;
    end else begin
        if(current_mode >= MODE_SET) begin
            current_mode <= MODE_DISP;
        end else begin
            current_mode <= current_mode + 2'd1;
        end
    end
end

// 步骤4：核心时间逻辑（分模式处理）
always @(posedge clk_1khz or negedge rst_n) begin
    if(!rst_n) begin
        // 复位初始化参数
        hour <= 7'd11; min <= 7'd59; sec <= 7'd0;
        hourC <= 7'd12; minC <= 7'd0; secC <= 7'd0;
        hourd <= 7'd0; mind <= 7'd0; secd <= 7'd3;
        hourA <= 7'd0; minA <= 7'd0; secA <= 7'd0;
        alarm_h <= 7'd12; alarm_m <= 7'd0; alarm_s <= 7'd59;
        buzzer_trig <= 1'b0;
        i <= 10'd1;
        set_flag <= 1'b0;
        alarm_en <= 1'b1;
        set_confirm_prev <= 1'b0;
        key_add_prev <= 3'b000;  // 初始化key_add边沿检测寄存器
    end else begin
        // 更新按键边沿检测寄存器
        set_confirm_prev <= set_confirm;
        key_add_prev <= key_add;
        
        // 蜂鸣器触发自动复位（持续1秒）
        if(i == 10'd1000) begin
            buzzer_trig <= 1'b0;
            i <= 10'd1;
            
            case(current_mode)
                // 模式1：显示当前时间（正常走时+定时响铃）
                MODE_DISP: begin
                    // 定时响铃判断（时分匹配，秒为0）
                    if((hour == alarm_h) && (min == alarm_m) && (sec == alarm_s)) begin
                        buzzer_trig <= 1'b1;
                    end
                end
                
                MODE_SET: begin
                    // 设置闹钟
                end
                
                // 模式2：正计时（从00:00:00累加，到99:59:59循环）
                MODE_UP: begin
                    if(!set_flag) begin
                        secA <= secA + 7'd1;
                        if(secA >= 7'd59) begin
                            secA <= 7'd0;
                            minA <= minA + 7'd1;
                            if(minA >= 7'd59) begin
                                minA <= 7'd0;
                                hourA <= hourA + 7'd1;
                                if(hourA >= 7'd99) hourA <= 7'd0;
                            end
                        end
                    end
                end
                
                // 模式3：倒计时（从设置值递减，到0触发蜂鸣器）
                MODE_DOWN: begin
                    if(!set_flag) begin
                        // 正确的倒计时递减
                        if((hourd > 0) || (mind > 0) || (secd > 0)) begin
                            if(secd > 0) begin
                                secd <= secd - 1;
                            end else begin
                                secd <= 7'd59;
                                if(mind > 0) begin
                                    mind <= mind - 1;
                                end else begin
                                    mind <= 7'd59;
                                    if(hourd > 0) hourd <= hourd - 1;
                                end
                            end
                        end else begin
                            buzzer_trig <= 1'b1;  // 倒计时结束
                        end
                    end
                end
            endcase
            
            // 正常走时逻辑
            sec <= sec + 7'd1;
            if(sec >= 7'd59) begin
                sec <= 7'd0;
                min <= min + 7'd1;
                if(min >= 7'd59) begin
                    min <= 7'd0;
                    hour <= hour + 7'd1;
                    if(hour >= 7'd23) hour <= 7'd0;
                end
            end
        end 
        
        case(current_mode)
            // 模式1：显示当前时间（正常走时+定时响铃）
            MODE_DISP: begin
                if(set_flag && alarm_en) begin
                    // 设置模式：调整当前时间
                    hourC <= hour; minC <= min; secC <= sec;
                    alarm_en <= ~alarm_en;
                end else if(set_flag && !alarm_en) begin
                    // 使用边沿检测，只在按键上升沿时调整
                    if(key_add[0] && !key_add_prev[0]) hourC <= (hourC >= 7'd23) ? 7'd0 : hourC + 7'd1;
                    if(key_add[1] && !key_add_prev[1]) minC <= (minC >= 7'd59) ? 7'd0 : minC + 7'd1;
                    if(key_add[2] && !key_add_prev[2]) secC <= (secC >= 7'd59) ? 7'd0 : secC + 7'd1;
                end
            end
            
            MODE_SET: begin
                // 设置闹钟
                if(set_flag && alarm_en) begin
                    // 设置模式：调整当前时间
                    hourC <= alarm_h; minC <= alarm_m; secC <= alarm_s;
                    alarm_en <= ~alarm_en;
                end else if(set_flag && !alarm_en) begin
                    // 使用边沿检测，只在按键上升沿时调整
                    if(key_add[0] && !key_add_prev[0]) hourC <= (hourC >= 7'd23) ? 7'd0 : hourC + 7'd1;
                    if(key_add[1] && !key_add_prev[1]) minC <= (minC >= 7'd59) ? 7'd0 : minC + 7'd1;
                    if(key_add[2] && !key_add_prev[2]) secC <= (secC >= 7'd59) ? 7'd0 : secC + 7'd1;
                end
            end
            
            // 模式2：正计时（从00:00:00累加，到99:59:59循环）
            MODE_UP: begin
                if(set_flag && alarm_en) begin
                    // 设置正计时起始时间
                    hourC <= hourA; minC <= minA; secC <= secA;
                    alarm_en <= ~alarm_en;
                end else if(set_flag && !alarm_en) begin
                    // 使用边沿检测，只在按键上升沿时调整
                    if(key_add[0] && !key_add_prev[0]) hourC <= (hourC >= 7'd99) ? 7'd0 : hourC + 7'd1;
                    if(key_add[1] && !key_add_prev[1]) minC <= (minC >= 7'd59) ? 7'd0 : minC + 7'd1;
                    if(key_add[2] && !key_add_prev[2]) secC <= (secC >= 7'd59) ? 7'd0 : secC + 7'd1;
                end
            end
            
            // 模式3：倒计时（从设置值递减，到0触发蜂鸣器）
            MODE_DOWN: begin
                if(set_flag && alarm_en) begin
                    // 设置倒计时时间
                    hourC <= hourd; minC <= mind; secC <= secd;
                    alarm_en <= ~alarm_en;
                end else if(set_flag && !alarm_en) begin
                    // 使用边沿检测，只在按键上升沿时调整
                    if(key_add[0] && !key_add_prev[0]) hourC <= (hourC >= 7'd23) ? 7'd0 : hourC + 7'd1;
                    if(key_add[1] && !key_add_prev[1]) minC <= (minC >= 7'd59) ? 7'd0 : minC + 7'd1;
                    if(key_add[2] && !key_add_prev[2]) secC <= (secC >= 7'd59) ? 7'd0 : secC + 7'd1;
                end
            end
        endcase
		  
        i <= i + 10'd1;
        
        // set_confirm边沿检测和处理（只在上升沿时响应）
        if(set_confirm && !set_confirm_prev) begin  // 检测上升沿
            set_flag <= ~set_flag;
            if(set_flag) begin  // 不在设置，根据模式显示时间。
                alarm_en <= 1'b1;  // 刷新能使；
                if(current_mode == MODE_DOWN) begin
                    hourd <= hourC; mind <= minC; secd <= secC;
                end else if(current_mode == MODE_DISP) begin
                    hour <= hourC; min <= minC; sec <= secC;
                end else if(current_mode == MODE_UP) begin
                    hourA <= hourC; minA <= minC; secA <= secC;
                end else if(current_mode == MODE_SET) begin
                    alarm_h <= hourC; alarm_m <= minC; alarm_s <= secC;
                end
                hourC <= 7'd12; minC <= 7'd0; secC <= 7'd0;
            end
        end
    end
end

reg [6:0] disp_h, disp_m, disp_s;
always @(*) begin
    if(set_flag) begin
        case(current_mode)
            MODE_DISP: begin disp_h = hourC; disp_m = minC; disp_s = secC; end
            MODE_UP:   begin disp_h = hourC; disp_m = minC; disp_s = secC; end
            MODE_DOWN: begin disp_h = hourC; disp_m = minC; disp_s = secC; end
            MODE_SET:  begin disp_h = hourC; disp_m = minC; disp_s = secC; end
            default:   begin disp_h = hour; disp_m = min; disp_s = sec; end
        endcase
    end else begin
        case(current_mode)
            MODE_DISP: begin disp_h = hour; disp_m = min; disp_s = sec; end
            MODE_UP:   begin disp_h = hourA; disp_m = minA; disp_s = secA; end
            MODE_DOWN: begin disp_h = hourd; disp_m = mind; disp_s = secd; end
            MODE_SET:  begin disp_h = alarm_h; disp_m = alarm_m; disp_s = alarm_s; end
            default:   begin disp_h = hour; disp_m = min; disp_s = sec; end
        endcase
    end
end

assign num_h1 = disp_h / 10; assign num_h0 = disp_h % 10;
assign num_m1 = disp_m / 10; assign num_m0 = disp_m % 10;
assign num_s1 = disp_s / 10; assign num_s0 = disp_s % 10;

endmodule