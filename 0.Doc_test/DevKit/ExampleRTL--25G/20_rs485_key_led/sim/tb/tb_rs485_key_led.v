`timescale  1ns/1ns                // 定义仿真时间单位1ns和仿真时间精度为1ns

module  tb_rs485_key_led;      // 测试模块

//parameter  define
parameter  T = 20;                 // 时钟周期为10ns

//defparam  define
defparam u_rs485_key_led.u_key_trig.u_key_debounce_0.CNT_MAX=10;
defparam u_rs485_key_led.u_key_trig.u_key_debounce_1.CNT_MAX=10;

//reg define
reg         sys_clk  ;  // 时钟信号
reg         sys_rst_n;  // 复位信号
reg  [1:0]  key      ;  // 复位信号
reg         uart_rxd ;  // UART接收端口

//*****************************************************
//**                    main code
//*****************************************************

//给输入信号初始值
initial begin
   sys_clk            = 1'b0 ;  
   sys_rst_n          = 1'b0 ;     // 复位
   key                = 2'b11;     //按键
   uart_rxd           = 1'b1 ;     //空闲为高
    #(T+10)
   sys_rst_n  = 1'b1;              // 在第30ns的时候复位信号信号拉高
    #(1000) 
   uart_rxd           = 1'b0 ;     //起始位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit0位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit1位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit2位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit3位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit4位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit5位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit6位
    #(8680)
   uart_rxd           = 1'b0 ;     //bit7位
    #(8680)
   uart_rxd           = 1'b1 ;     //停止位   
    #(1000)
   key                = 2'b10;
    #(20)
   key                = 2'b11;
    #(60)
   key                = 2'b10;
end

//50Mhz的时钟，周期则为1/50Mhz=20ns,所以每10ns，电平取反一次
always #(T/2) sys_clk = ~sys_clk;

//例化顶层模块
 rs485_key_led u_rs485_key_led(
    .sys_clk          (sys_clk  ),    //50m时钟
    .sys_rst_n        (sys_rst_n),    //复位信号，低电平有效
    .key              (key      ),    //按键
    .led              (),             //led灯
    .rs485_uart_rxd   (uart_rxd ),    //UART接收端口
    .rs485_uart_txd   ()              //UART发送端口
);
    
endmodule