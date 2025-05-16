`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/13 15:38:27
// Design Name: 
// Module Name: dds_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dds_tb( );
   reg                 sys_clk    ;  //系统时钟
   reg                 sys_rst_n  ;  //系统复位，低电平有效
   reg                 key0       ;  //按键key0
   reg                 key1       ;  //按键key1
    //DA芯片接口
   wire                da_clk     ;  //DA(AD9708)驱动时钟,最大支持125Mhz时钟
   wire    [7:0]       da_data    ;  //输出给DA的数据
    //AD芯片接口
   reg     [7:0]       ad_data   ;   //AD输入数据
    //模拟输入电压超出量程标志(本次试验未用到)
   reg                 ad_otr    ;  //0:在量程范围 1:超出量程
   wire                ad_clk    ;  //AD(AD9280)驱动时钟,最大支持32Mhz时钟 
//sys_rst_n,sys_clk,key
initial 
    begin  
          sys_rst_n       =   1'b0;
          sys_clk         =   1'b0;
          key0            =   1'b1;
          key1            =   1'b1;
          #200;
          sys_rst_n       =   1'b1;
          #1020;
          key0 = 0;
          #105;
          key0 = 1;
          #1020;
          key0 = 0;
          #120;
          key0 = 1;          
          #1020;
          key0 = 0;
          #120;
          key0 = 1;
          #1020;
          key0 = 0;
          #120;
          key0 = 1;                
          #1020;
          key1 = 0;
          #120;
          key1 = 1;
          #1020;
          key1 = 0;
          #110;
          key1 = 1;
          #1020;
          key1 = 0;
          #110;
          key1 = 1;
          #1020;
          key1 = 0;
          #110;
          key1 = 1; 
          #2020;
          key1 = 0;
          #110;
          key1 = 1;                                     
          #2020;
          $stop;
 end 

always #10 sys_clk = ~sys_clk;

dds    u1_dds
(
     .sys_clk      (sys_clk),
     .sys_rst_n  (sys_rst_n),
     .key0            (key0),
     .key1            (key1),
     .da_clk          (da_clk),
     .da_data         (da_data),
     .ad_data         (ad_data),
     .ad_otr          (ad_otr ),
     .ad_clk          (ad_clk )
);

endmodule
