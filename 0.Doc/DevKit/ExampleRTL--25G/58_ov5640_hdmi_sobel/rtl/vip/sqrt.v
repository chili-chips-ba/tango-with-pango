//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：http://www.openedv.com/forum.php
//淘宝店铺：https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2023-2033
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           sqrt
// Created by:          正点原子
// Created date:        2023年9月12日17:52:55
// Version:             V1.0
// Descriptions:        开平方模块
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module sqrt
   #(     
      parameter    d_width = 22,
      parameter    q_width = d_width/2 - 1,
      parameter    r_width = q_width + 1    
   )
  (
      input                 clk      ,
      input                 rst      ,
      input                 i_vaild  ,
      input  [d_width-1:0]  data_i   , //输入
      
      output  reg             o_vaild,
      output  reg [q_width:0] data_o , //输出
      output  reg [r_width:0] data_r   //余数
   );

//reg define 
reg  [d_width-1:0]  D   [r_width:1]; //被开方数
reg  [  q_width:0]  Q_z [r_width:1]; //实验值
reg  [  q_width:0]  Q_q [r_width:1]; //确认值
reg  ivalid_t       [r_width:1]    ; //表示此时寄存器D中对应位置是数据是否有效

//*****************************************************
//**                    main code
//*****************************************************

always@(posedge clk or posedge rst)begin
    if(rst)
        begin
            D[r_width]        <= 0;
            Q_z[r_width]      <= 0;
            Q_q[r_width]      <= 0;
            ivalid_t[r_width] <= 0;
        end
    else if(i_vaild)
        begin
            D[r_width] <= data_i;                   //被开方数据
            Q_z[r_width] <= {1'b1,{q_width{1'b0}}}; //实验值设置，先将最高位置1
            Q_q[r_width] <= 0; //实际计算结果
            ivalid_t[r_width] <= 1;
        end
    else
        begin
            D[r_width] <= 0;
            Q_z[r_width] <= 0;
            Q_q[r_width] <= 0;
            ivalid_t[r_width] <= 0;
        end
end

//迭代计算过程，流水线操作
generate
    genvar i;
        for(i=r_width-1;i>=1;i=i-1)
            begin:U
                always@(posedge clk or posedge rst) begin
                    if(rst)
                        begin
                            D[i] <= 0;
                            Q_z[i] <= 0;
                            Q_q[i] <= 0;
                            ivalid_t[i] <= 0;
                        end
                    else    if(ivalid_t[i+1])
                        begin
                            if(Q_z[i+1]*Q_z[i+1] > D[i+1])
                                begin
                                    Q_z[i] <= {Q_q[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
                                    Q_q[i] <= Q_q[i+1];
                                end
                            else
                                begin
                                    Q_z[i] <= {Q_z[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
                                    Q_q[i] <= Q_z[i+1];
                                end
                            D[i] <= D[i+1];
                            ivalid_t[i] <= 1;
                        end
                    else
                        begin
                            ivalid_t[i] <= 0;
                            D[i] <= 0;
                            Q_q[i] <= 0;
                            Q_z[i] <= 0;
                        end
                end
            end
endgenerate

//计算余数与最终平方根
always@(posedge clk or posedge rst) begin
    if(rst)
        begin
            data_o <= 0;
            data_r <= 0;
            o_vaild <= 0;
        end
    else    if(ivalid_t[1])
        begin
            if(Q_z[1]*Q_z[1] > D[1])
                begin
                    data_o <= Q_q[1];
                    data_r <= D[1] - Q_q[1]*Q_q[1];
                    o_vaild <= 1;
                end
            else
                begin
                    data_o <= {Q_q[1][q_width:1],Q_z[1][0]};
                    data_r <= D[1] - {Q_q[1][q_width:1],Q_z[1][0]}*{Q_q[1][q_width:1],Q_z[1][0]};
                    o_vaild <= 1;
                end
        end
    else
        begin
            data_o <= 0;
            data_r <= 0;
            o_vaild <= 0;
        end
end

endmodule