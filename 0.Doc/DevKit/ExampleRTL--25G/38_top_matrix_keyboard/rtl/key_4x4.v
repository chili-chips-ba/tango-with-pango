//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           key_4x4
// Created by:          正点原子
// Created date:        2023年2月3日14:17:02
// Version:             V1.0
// Descriptions:        key_4x4
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_4x4(
    input                sys_clk  ,   //50MHZ
    input                sys_rst_n,
    input       [3:0]    key_row  ,   //行

    output reg  [3:0]    key_col  ,   //列
    output reg  [4:0]    key_value,   //键值
    output reg           key_flag
);

//reg define
reg [2:0] state       ;  //状态标志
reg [3:0] key_col_reg ;  //寄存扫描列值
reg [3:0] key_row_reg ;  //寄存扫描行值
reg [31:0]delay_cnt   ;
reg [3:0] key_reg_row ;
reg       key_flag_row;  //消抖完成标志
reg       del_en      ;  //按键延时标志信号，高电平有效
reg [3:0] del_cnt     ;  //按键延时

//*****************************************************
//**                    main code                      
//*****************************************************

//按键消抖模块
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)begin
        key_reg_row <= 4'b1;
        delay_cnt <= 32'd0;
    end
    else begin
        key_reg_row <= key_row;
            if(key_reg_row != key_row)               //如果按键被按下           
//              delay_cnt <= 32'd1000000;            //消抖计数器为20ms    
                delay_cnt <= 32'd8;                  //仿真时使用           
            else if(key_reg_row == key_row)begin  
                if(delay_cnt > 32'd0)
                    delay_cnt <= delay_cnt - 1'b1;
                else
                    delay_cnt <= delay_cnt;
            end           
    end   
end
//按键消抖完成标志模块
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)  
        key_flag_row <= 1'b0;              
    else begin
            if(delay_cnt == 32'd1)                   //消抖计数器等于1   
                key_flag_row <= 1'b1;                //说明消抖标志完成
            else if(del_en)
                key_flag_row <= 1'b0;
    end   
end
//按键扫描延迟打拍模块
always @(posedge sys_clk or negedge sys_rst_n)begin 
    if (!sys_rst_n)begin 
        del_en <= 1'b0;
        del_cnt <= 1'b0;
    end    
    else begin
        if(del_cnt == 4'd3)begin
            del_cnt <= 1'd0;
            del_en <= 1'b1;
        end
        else begin
            del_cnt <= del_cnt + 1'b1;
            del_en <= 1'b0;
        end
    end        
end
//按键扫描模块
always @(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
      key_col <= 4'b0;
      state <= 0;
      key_flag <= 1'b0;
      key_col_reg <= 4'b0;
      key_row_reg <= 4'b0;
    end
    else begin 
        if(del_en)begin
            case (state)
              0:
                begin
                    key_col[3:0] <= 4'b0000;
                    key_flag <= 1'b0;
                    if((key_row[3:0] != 4'b1111) && (key_flag_row))begin   
                        state <= 1;                 //如果行扫描不都是高电平说明有按键按下
                        key_col[3:0] <= 4'b1110;    //跳转到状态 1 并且先判断第一列    
                    end 
                    else 
                        state <= 0 ;
                end
              1:
                begin                               //进入状态1
                    if(key_row[3:0] != 4'b1111)     //如果行扫描仍没有全部拉高
                        state <= 5;                 //说明就是第一列，跳转到状态 5
                    else begin
                        state <= 2;                 //如果不是第一列则跳转状态 2
                        key_col[3:0] <= 4'b1101;    //并且判断第二列
                    end
                end  
              2:                                   
                begin                               //进入状态 2
                    if(key_row[3:0] != 4'b1111)     //如果行扫描仍没有全部拉高
                        state <= 5;                 //说明就是第二列，跳转到状态 5
                    else begin                 
                        state <= 3;                 //如果不是第二列则跳转状态 3
                        key_col[3:0] <= 4'b1011;    //并且判断第三列
                    end  
                end
              3:
                begin                               //进入状态 3
                    if(key_row[3:0] != 4'b1111)     //如果行扫描仍没有全部拉高
                        state <= 5;                 //说明就是第三列，跳转到状态 5
                    else begin                  
                        state <= 4;                 //如果不是第三列则跳转状态 4
                        key_col[3:0] <= 4'b0111;    //并且判断第四列
                    end  
                end
              4:
                begin                               //进入状态 4
                    if (key_row[3:0] != 4'b1111)    //如果行扫描仍没有全部拉高
                        state <= 5;                 //说明就是第四列，跳转到状态 5
                    else                        
                        state <= 0;                 //如果不是第四列则跳转状态 0
                end                                
              5:
                begin  
                    if(key_row[3:0] != 4'b1111)begin
                        key_col_reg <= key_col;     //将列扫描的值赋值给列扫描寄存器
                        key_row_reg <= key_row;     //将行扫描的值赋值给行扫描寄存器
                        state <= 5;
                        key_flag <= 1'b1;  
                    end             
                    else
                        state <= 0;
                end             
            endcase 
        end    
    end             
end
//按键赋值模块
always @ ( posedge sys_clk or negedge sys_rst_n )begin
    if(!sys_rst_n)begin
        key_value <= 5'd16;
    end
    else if(key_flag)
    begin
        case ({key_col_reg,key_row_reg})           //将列扫描寄存器与行扫描寄存器进行位拼接
            //第一列按键编号
            8'b1110_1110 : key_value <= 5'd0;
            8'b1110_1101 : key_value <= 5'd4;
            8'b1110_1011 : key_value <= 5'd8;
            8'b1110_0111 : key_value <= 5'd12;
            //第二列按键编号  
            8'b1101_1110 : key_value <= 5'd1;
            8'b1101_1101 : key_value <= 5'd5;
            8'b1101_1011 : key_value <= 5'd9;
            8'b1101_0111 : key_value <= 5'd13;
            //第三列按键编号  
            8'b1011_1110 : key_value <= 5'd2;
            8'b1011_1101 : key_value <= 5'd6;
            8'b1011_1011 : key_value <= 5'd10;
            8'b1011_0111 : key_value <= 5'd14;
            //第四列按键编号  
            8'b0111_1110 : key_value <= 5'd3;
            8'b0111_1101 : key_value <= 5'd7;
            8'b0111_1011 : key_value <= 5'd11;
            8'b0111_0111 : key_value <= 5'd15; 
        endcase 
    end   
end  
endmodule