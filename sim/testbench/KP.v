// Key_Process 测试文件（适配无key_sub版本）
`timescale 1ns/1ns

module Key_Process_Testbench;

// ==================== 1. 信号定义 ====================
reg         clk_1khz;       // 1kHz扫描时钟
reg         rst_n;          // 复位信号
reg  [4:0]  key_in;         // 5个按键输入（低电平有效）
wire        mode_switch;    // 模式切换触发
wire        set_confirm;    // 设置确认触发
wire [2:0]  key_add;        // 加按键（小时+/分钟+/秒+）

// ==================== 2. 实例化被测模块 ====================
Key_Process uut (
    .clk_1khz(clk_1khz),
    .rst_n(rst_n),
    .key_in(key_in),
    .mode_switch(mode_switch),
    .set_confirm(set_confirm),
    .key_add(key_add)
);

// ==================== 3. 1kHz时钟生成 ====================
// 1kHz时钟：周期1ms = 1,000,000ns
initial clk_1khz = 0;
always #500000 clk_1khz = ~clk_1khz;  // 500,000ns半周期

// ==================== 4. 按键模拟任务 ====================
task press_key;
    input [4:0] key_index;     // 按键索引 0-4
    input integer press_time;  // 按下时间（ms）
    begin
        $display("时间=%t ms: 按下按键[%d]，持续%dms", 
                $time/1000000.0, key_index, press_time);
        
        // 按下按键（低电平有效）
        key_in[key_index] = 1'b0;
        
        // 模拟按键抖动（前5ms抖动）
        #1000000;  // 1ms
        key_in[key_index] = 1'b1;
        #100000;   // 0.1ms
        key_in[key_index] = 1'b0;
        #50000;    // 0.05ms
        key_in[key_index] = 1'b1;
        #50000;    // 0.05ms
        key_in[key_index] = 1'b0;
        
        // 稳定按下（扣除已用的1.2ms）
        #((press_time * 1000000) - 1200000);
        
        // 释放按键（可能有抖动）
        key_in[key_index] = 1'b1;
        #50000;    // 0.05ms
        key_in[key_index] = 1'b0;
        #50000;    // 0.05ms
        key_in[key_index] = 1'b1;
        #1000000;  // 1ms后完全释放
        
        $display("时间=%t ms: 释放按键[%d]", $time/1000000.0, key_index);
    end
endtask

// ==================== 5. 主测试流程 ====================
initial begin
    $display("========================================");
    $display("=== Key_Process 模块测试开始 ===");
    $display("========================================");
    
    // 初始化
    rst_n = 1'b0;
    key_in = 5'b11111;  // 所有按键释放（高电平）
    
    // ----------------- 阶段1：复位测试 -----------------
    $display("\n[阶段1] 复位测试");
    #2000000;  // 2ms
    rst_n = 1'b1;
    $display("时间=%t ms: 复位释放", $time/1000000.0);
    
    // 检查复位后输出
    #1000000;  // 1ms
    check_reset_outputs();
    
    // ----------------- 阶段2：消抖功能测试 -----------------
    $display("\n[阶段2] 消抖功能测试");
    
    // 测试1：15ms短按（应被过滤）
    $display("\n测试1：15ms短按（应被消抖过滤）");
    key_in[0] = 1'b0;  // 按下
    #15000000;        // 15ms（小于20ms消抖时间）
    key_in[0] = 1'b1;  // 释放
    #30000000;        // 等待30ms观察
    
    if(mode_switch == 0) begin
        $display("  ✓ 15ms短按被正确过滤");
    end else begin
        $display("  ✗ 15ms短按未被过滤，mode_switch=%b", mode_switch);
    end
    
    // 测试2：25ms正常按（应产生脉冲）
    $display("\n测试2：25ms正常按键（应产生脉冲）");
    press_key(0, 25);  // 按下25ms
    #30000000;         // 等待30ms观察
    
    if(check_pulse(mode_switch, "mode_switch")) begin
        $display("  ✓ 25ms按键产生正确脉冲");
    end
    
    // ----------------- 阶段3：单个按键功能测试 -----------------
    $display("\n[阶段3] 单个按键功能测试");
    
    // 测试模式切换按键（key_in[0]）
    $display("\n测试按键[0]：模式切换");
    press_key(0, 30);
    #10000000;  // 等待10ms
    
    // 测试设置确认按键（key_in[1]）
    $display("\n测试按键[1]：设置确认");
    press_key(1, 35);
    #10000000;  // 等待10ms
    
    // 测试小时+按键（key_in[2]）
    $display("\n测试按键[2]：小时+");
    press_key(2, 28);
    #10000000;  // 等待10ms
    
    // 测试分钟+按键（key_in[3]）
    $display("\n测试按键[3]：分钟+");
    press_key(3, 32);
    #10000000;  // 等待10ms
    
    // 测试秒钟+按键（key_in[4]）
    $display("\n测试按键[4]：秒钟+");
    press_key(4, 40);
    #10000000;  // 等待10ms
    
    // ----------------- 阶段4：按键同时按下测试 -----------------
    $display("\n[阶段4] 按键同时按下测试");
    
    // 同时按下两个键
    $display("同时按下按键[0]（模式）和[2]（小时+）...");
    key_in[0] = 1'b0;
    key_in[2] = 1'b0;
    #50000000;  // 50ms
    key_in[0] = 1'b1;
    key_in[2] = 1'b1;
    #30000000;  // 30ms观察
    
    // ----------------- 阶段5：快速连续按键测试 -----------------
    $display("\n[阶段5] 快速连续按键测试");
    
    for (int i = 0; i < 3; i++) begin
        $display("快速按键[2] 第%d次", i+1);
        press_key(2, 25);  // 快速按3次小时+键
        #10000000;  // 间隔10ms
    end
    
    // ----------------- 阶段6：长时间按键测试 -----------------
    $display("\n[阶段6] 长时间按键测试");
    
    // 长按100ms
    $display("长按按键[0] 100ms...");
    key_in[0] = 1'b0;
    #100000000;  // 100ms
    key_in[0] = 1'b1;
    #30000000;   // 30ms观察
    
    // 长按应该只在按下瞬间产生一个脉冲，不是持续高电平
    $display("长按测试完成");
    
    // ----------------- 阶段7：边界条件测试 -----------------
    $display("\n[阶段7] 边界条件测试");
    
    // 测试正好20ms的按键
    $display("\n测试正好20ms的按键...");
    key_in[0] = 1'b0;
    #20000000;  // 正好20ms
    key_in[0] = 1'b1;
    #30000000;  // 等待30ms
    
    if(mode_switch) begin
        $display("  ✓ 20ms按键产生脉冲");
    end else begin
        $display("  ✗ 20ms按键未产生脉冲");
    end
    
    // 测试按键抖动频繁变化
    $display("\n测试频繁抖动（模拟接触不良）...");
    for (int i = 0; i < 10; i++) begin
        key_in[0] = 1'b0;
        #500000;  // 0.5ms
        key_in[0] = 1'b1;
        #500000;  // 0.5ms
    end
    #50000000;  // 等待50ms
    
    if(mode_switch == 0) begin
        $display("  ✓ 频繁抖动被正确过滤");
    end else begin
        $display("  ✗ 频繁抖动产生误触发");
    end
    
    // ==================== 测试完成 ====================
    $display("\n========================================");
    $display("=== Key_Process 测试完成 ===");
    $display("总测试时间: %0.1f ms", $time/1000000.0);
    $display("========================================");
    
    $stop;
end

// ==================== 6. 辅助检查函数 ====================
task check_reset_outputs;
    begin
        if(mode_switch == 0 && set_confirm == 0 && key_add == 3'b000) begin
            $display("  ✓ 复位后所有输出为0");
        end else begin
            $display("  ✗ 复位后输出不为0:");
            $display("    mode_switch=%b, set_confirm=%b, key_add=%b",
                    mode_switch, set_confirm, key_add);
        end
    end
endtask

function check_pulse;
    input signal;
    input string signal_name;
    begin
        if(signal) begin
            $display("  ✓ %s 产生脉冲", signal_name);
            check_pulse = 1;
        end else begin
            $display("  ✗ %s 未产生脉冲", signal_name);
            check_pulse = 0;
        end
    end
endfunction

// ==================== 7. 实时监控器 ====================
// 监控输出脉冲
always @(posedge mode_switch) begin
    $display("[监控] 时间=%t ms: mode_switch 脉冲 ↑", $time/1000000.0);
    // 监控脉冲宽度
    fork
        begin
            #1000000;  // 1ms后检查
            if(mode_switch) begin
                $display("[警告] mode_switch脉冲宽度超过1ms!");
            end
        end
    join_none
end

always @(posedge set_confirm) begin
    $display("[监控] 时间=%t ms: set_confirm 脉冲 ↑", $time/1000000.0);
end

always @(posedge key_add[0]) begin
    $display("[监控] 时间=%t ms: key_add[0]（小时+）脉冲 ↑", $time/1000000.0);
end

always @(posedge key_add[1]) begin
    $display("[监控] 时间=%t ms: key_add[1]（分钟+）脉冲 ↑", $time/1000000.0);
end

always @(posedge key_add[2]) begin
    $display("[监控] 时间=%t ms: key_add[2]（秒钟+）脉冲 ↑", $time/1000000.0);
end

// 监控消抖过程
integer stable_count = 0;
always @(posedge clk_1khz) begin
    if(uut.cnt_filter > 0) begin
        if(stable_count == 0) begin
            $display("[消抖] 时间=%t ms: 开始消抖计数 cnt_filter=%d", 
                    $time/1000000.0, uut.cnt_filter);
        end
        stable_count = stable_count + 1;
    end else begin
        if(stable_count > 0) begin
            $display("[消抖] 时间=%t ms: 消抖中断，累计计数 %d 次", 
                    $time/1000000.0, stable_count);
            stable_count = 0;
        end
    end
end

// 监控按键状态变化
reg [4:0] last_key_in = 5'b11111;
always @(key_in) begin
    if(key_in !== last_key_in) begin
        $display("[按键] 时间=%t ms: key_in %b -> %b", 
                $time/1000000.0, last_key_in, key_in);
        last_key_in = key_in;
    end
end

// ==================== 8. 自动检查器 ====================
// 检查脉冲宽度应为1ms
reg [31:0] pulse_start_time;
string current_pulse_name;

task start_pulse_monitor;
    input signal;
    input string name;
    begin
        if(signal) begin
            pulse_start_time = $time;
            current_pulse_name = name;
            
            // 1ms后检查脉冲是否结束
            fork
                begin
                    #1000000;  // 1ms
                    if(signal) begin
                        $warning("%s脉冲宽度超过1ms!", name);
                    end
                end
            join_none
        end
    end
endtask

always @(posedge mode_switch) start_pulse_monitor(mode_switch, "mode_switch");
always @(posedge set_confirm) start_pulse_monitor(set_confirm, "set_confirm");
always @(posedge key_add[0]) start_pulse_monitor(key_add[0], "key_add[0]");
always @(posedge key_add[1]) start_pulse_monitor(key_add[1], "key_add[1]");
always @(posedge key_add[2]) start_pulse_monitor(key_add[2], "key_add[2]");

// ==================== 9. 波形保存 ====================
initial begin
    $dumpfile("key_process_test.vcd");
    // 保存所有信号
    $dumpvars(0, Key_Process_Testbench);
    
    // 或者只保存关键信号以减少文件大小
    // $dumpvars(1, 
    //     clk_1khz, rst_n, key_in,
    //     mode_switch, set_confirm, key_add,
    //     uut.key_filter, uut.cnt_filter, uut.key_last
    // );
end

endmodule