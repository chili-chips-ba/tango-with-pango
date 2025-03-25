//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           sd_ddr_size
// Last modified Date:  2020/11/22 15:16:38
// Last Version:        V1.0
// Descriptions:        根据LCD ID，计算DDR最大读写地址和SD卡读扇区个数
//                      
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/11/22 15:16:38
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sd_ddr_size (
    input               clk          , //时钟
    input               rst_n        , //复位，低电平有效
                                       
    input        [15:0] ID_lcd       , //LCD ID
                                       
    output  reg  [23:0] ddr_max_addr , //DDR读写最大地址
    output  reg  [15:0] sd_sec_num     //SD卡读扇区个数
);

//parameter define
parameter  ID_4342 = 16'h4342;
parameter  ID_4384 = 16'h4384;
parameter  ID_7084 = 16'h7084;
parameter  ID_7016 = 16'h7016;
parameter  ID_1018 = 16'h1018;

//*****************************************************
//**                    main code                      
//*****************************************************

//根据LCD ID，计算DDR最大读写地址和SD卡读扇区个数
always @(posedge clk or negedge rst_n) begin 
    if(!rst_n) begin
        ddr_max_addr <= 24'd0;   
        sd_sec_num <= 16'd0;        
    end 
    else begin    
        case(ID_lcd ) 
            ID_4342 : begin
                ddr_max_addr <= 24'd130560;    //480*272
                sd_sec_num <= 16'd765 + 1'b1;  //480*272*3/512     
            end 
            ID_4384 : begin
                ddr_max_addr <= 24'd384000;    //800*480
                sd_sec_num <= 16'd2250 + 1'b1; //800*480*3/512 + 1 
            end
            ID_7084 : begin       
                ddr_max_addr <= 24'd384000;    //800*480
                sd_sec_num <= 16'd2250 + 1'b1; //800*480*3/512 + 1
            end 
            ID_7016 : begin         
                ddr_max_addr <= 24'd614400;    //1024*600
                sd_sec_num <= 16'd3600 + 1'b1; //800*480*3/512 + 1  
            end    
            ID_1018 : begin         
                ddr_max_addr <= 24'd1024000;   //1280*800
                sd_sec_num <= 16'd6000 + 1'b1; //800*480*3/512 + 1  
            end 
        default : begin         
                ddr_max_addr <= 24'd384000;    //800*480
                sd_sec_num <= 16'd2250 + 1'b1; //800*480*3/512 + 1  
        end
        endcase
    end    
end 

endmodule 
