`timescale 1ns/1ns
module tb_top_matrix_keyboard ();

reg         sys_clk    ;
reg         sys_rst_n  ;
reg   [3:0] key_row    ;
reg   [7:0] swi        ;
wire  [3:0] key_col    ;
wire  [3:0] sel_t      ;
wire  [7:0] seg_led_t  ;
wire  [7:0] led	       ;

//初始化系统时钟、全局复位
initial begin
        sys_clk   <= 1'b1;
        sys_rst_n <= 1'b0;      
        #40;
        sys_rst_n <= 1'b1;
end
//sys_clk:每10ns电平翻转一次，产生一个50MHz的时钟信号
always #10 sys_clk = ~sys_clk;
//矩阵键盘按键模拟
initial begin
        key_row <= 4'b1111;
        #80         //按键按下  
        key_row <= 4'b1101;
        #220        //消抖时间 此刻的延时要能与del_en的高脉冲重合
        key_row <= 4'b1111;
        #80         //扫描延迟时间
        key_row <= 4'b1111;
        #80         //扫描延迟时间
        key_row <= 4'b1101;
        #160        //按键松开
        key_row <= 4'b1111;
end
//拨码开关控制LED
initial begin
        swi <= 8'b0000_0000;
        #40
        swi <= 8'b0000_0001;
        #60
        swi <= 8'b1111_1101;
        #60
        swi <= 8'b1111_1011;

end

initial begin
$dumpvars();
$dumpfile("file.vcd");
end

top_matrix_keyboard u_top_matrix_keyboard(
        .sys_clk   (sys_clk   ),
        .sys_rst_n (sys_rst_n ),
        .key_row   (key_row   ),
        .swi       (swi       ),
        .key_col   (key_col   ),
        .sel_t     (sel_t     ),
        .seg_led_t (seg_led_t ),
        .led       (led       )
);

endmodule //tb_top_matrix_keyboard









