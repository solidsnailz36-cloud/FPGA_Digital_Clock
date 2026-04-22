//simulation/modelsim/CT.v// Clock_Core 调试测试文件
`timescale 1ns/1ns

module Clock_Core_Testbench;

// ==================== 1. 信号定义 ====================
reg         clk_1khz;        // 1Hz时钟
reg         rst_n;          // 复位
reg         mode_switch;    // 模式切换 0没有 / 1按了
reg         set_confirm;    // 设置确认 0没有 / 1按了
reg  [2:0]  key_add;        // 加按键   0没有 / 1按了
wire        buzzer_trig;    // 蜂鸣器触发
wire [3:0]  num_h1, num_h0, num_m1, num_m0, num_s1, num_s0; // 显示数字

// ==================== 2. 监控信号 ====================
wire [1:0]  current_mode;   // 当前模式
wire        set_flag;       // 设置标志
wire        alarm_en;       // 闹钟使能
wire [6:0]  hour, min, sec; // 当前时间
wire [6:0]  hourC, minC, secC; // 设置时间
wire [6:0]  hourd, mind, secd; // 倒计时时间
wire [6:0]  hourA, minA, secA; // 正计时时间
wire [6:0]  alarm_h, alarm_m, alarm_s; // 闹钟时间
wire [6:0]  disp_h, disp_m, disp_s;   // 显示时间

// ==================== 3. 实例化被测模块 ====================
Clock_Core uut (
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .mode_switch(mode_switch),
    .set_confirm(set_confirm),
    .key_add(key_add),
    .buzzer_trig(buzzer_trig),
    .num_h1(num_h1),
    .num_h0(num_h0),
    .num_m1(num_m1),
    .num_m0(num_m0),
    .num_s1(num_s1),
    .num_s0(num_s0)
);

// ==================== 4. 内部信号监控 ====================
// 添加这些assign语句来监控内部寄存器
assign current_mode = uut.current_mode;
assign set_flag = uut.set_flag;
assign alarm_en = uut.alarm_en;
assign hour = uut.hour;
assign min = uut.min;
assign sec = uut.sec;
assign hourC = uut.hourC;
assign minC = uut.minC;
assign secC = uut.secC;
assign hourd = uut.hourd;
assign mind = uut.mind;
assign secd = uut.secd;
assign hourA = uut.hourA;
assign minA = uut.minA;
assign secA = uut.secA;
assign alarm_h = uut.alarm_h;
assign alarm_m = uut.alarm_m;
assign alarm_s = uut.alarm_s;
assign disp_h = uut.disp_h;
assign disp_m = uut.disp_m;
assign disp_s = uut.disp_s;

// ==================== 5. 时钟生成 ====================
// 1Hz时钟：周期1秒 = 1,000,000,000ns
initial clk_1khz = 0;
always #500000 clk_1khz = ~clk_1khz;  // 500ms半周期

// ==================== 6. 按键模拟任务 ====================
task press_key;
    input key_num;
    begin
        case(key_num)
            0: mode_switch = 1;  // 模式切换
            1: set_confirm = 1;  // 设置确认（假设key_in[4]对应set_confirm）
        endcase
        #30000000;  // 保持1秒
        case(key_num)
            0: mode_switch = 0;
            1: set_confirm = 0;
        endcase
        #30000000;  // 等待1秒
    end
endtask

task press_add_key;//加减按键（0小时+/1分钟+/2秒+）
    input [2:0] key_index;
    begin
        key_add[key_index] = 1;
        #30000000;  // 保持1秒
        key_add[key_index] = 0;
        #30000000;  // 等待1秒
    end
endtask

reg [6:0] target_sec;
reg [6:0] target_min;

// ==================== 7. 主测试流程 ====================
initial begin
    // 初始化所有信号
	 rst_n = 0;
    mode_switch = 0;
    set_confirm = 0;
    key_add = 3'b000;
	 #300000;
	 rst_n = 1;
    // ----------------- 阶段2：正常走时测试 -----------------
	 $display("\n[阶段1] 正常走时测试");
    $display("当前模式: %d (期望: 0-正常走时)", current_mode);
    $display("当前时间: %02d:%02d:%02d", hour, min, sec);
	 #2000000000;  
	 #2000000000;// 等待4秒
	 $display("等待4秒……");
	  $display("时间=%t 秒: 当前时间 %02d:%02d:%02d, 显示 %d%d:%d%d:%d%d", 
                $time/1000000000.0, hour, min, sec,
                num_h1, num_h0, num_m1, num_m0, num_s1, num_s0);
	 // ----------------- 阶段3：模式切换测试 -----------------
    $display("\n[阶段2] 模式切换测试");
    // 切换到正计时模式
    $display("切换到正计时模式...");
    press_key(0);  // 按模式键
    
    $display("当前模式: %d (期望: 1-正计时)", current_mode);
    $display("正计时时间: %02d:%02d:%02d", hourA, minA, secA);
    
    // 观察正计时运行
    #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
	 #2000000000;  // 5秒
    $display("1分14秒后正计时: %02d:%02d:%02d", hourA, minA, secA);
    
    // 切换到倒计时模式
    $display("\n切换到倒计时模式...");
    press_key(0);
    
    $display("当前模式: %d (期望: 2-倒计时)", current_mode);
    $display("倒计时时间: %02d:%02d:%02d", hourd, mind, secd);
    $display("\n等待倒计时结束");
	 #2000000000;
	 #2000000000;
	 #2000000000;
    $display("倒计时时间: %02d:%02d:%02d", hourd, mind, secd);
    // 切换到闹钟设置模式
    $display("\n切换到闹钟设置模式...");
    press_key(0);
    
    $display("当前模式: %d (期望: 3-闹钟设置)", current_mode);
    $display("闹钟时间: %02d:%02d:%02d", alarm_h, alarm_m, alarm_s);
    
    // 切回显示模式
    $display("\n切回显示模式...");
    press_key(0);
    $display("当前模式: %d (期望: 0-显示模式)", current_mode);
	 
	  // ----------------- 阶段4：时间设置测试 -----------------
    $display("\n[阶段4] 显示模式时间设置测试");
    
    // 进入设置模式
    $display("进入设置模式...");
    press_key(1);  // 按设置确认键
    
    $display("设置标志: %d (期望: 1)", set_flag);
    $display("目前设置时间(hourC): %02d:%02d:%02d", hourC, minC, secC);
    
    // 调整小时
    $display("增加10小时...");
    press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
	 press_add_key(0);  // 小时+
    $display("设置时间变为: %02d:%02d:%02d", hourC, minC, secC);
    
    // 调整分钟
    $display("增加35分钟...");
    press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
	 press_add_key(1);  // 分钟+
    $display("设置时间变为: %02d:%02d:%02d", hourC, minC, secC);
    
    // 调整秒钟
    $display("增加10秒钟...");
    press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
	 press_add_key(2);  // 秒+
    $display("设置时间变为: %02d:%02d:%02d", hourC, minC, secC);
    
    // 保存设置
    $display("保存设置...");
    press_key(1);  // 按设置确认键
    
    $display("设置标志: %d (期望: 0)", set_flag);
    $display("当前时间变为: %02d:%02d:%02d", hour, min, sec);
    
	   // ----------------- 阶段7：闹钟测试 -----------------
    $display("\n[阶段7] 闹钟设置和触发测试");
    
    // 切换到闹钟设置模式
    press_key(0);
    press_key(0);
	 press_key(0);
    // 进入闹钟设置
    press_key(1);
    
    // 设置闹钟比当前时间晚10秒
    target_sec = (sec + 10) % 60;
    target_min = min + ((sec + 10) / 60);
    
    // 调整到目标时间
    while(hourC != hour || minC != target_min || secC != target_sec) begin
        if(secC != target_sec) press_add_key(2);
        if(minC != target_min) press_add_key(1);
        if(hourC != hour) press_add_key(0);
    end
    
    $display("设置闹钟为: %02d:%02d:%02d", hourC, minC, secC);
    $display("当前时间: %02d:%02d:%02d", hour, min, sec);
    
    // 保存闹钟
    press_key(1);
    press_key(0);
    // 等待闹钟触发
    $display("等待闹钟触发...");
    #2000000000;  // 等待5秒
    #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
	 #2000000000;
    
    $stop;
end
 always @(buzzer_trig) begin
        if(buzzer_trig)
            $display("  ✓ 闹钟触发成功 at time = %t", $time);
        //else
           // $display("  ✗ 闹钟未触发 at time = %t", $time);
    end
endmodule