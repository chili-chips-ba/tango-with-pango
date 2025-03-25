//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           sd_ddr_size
// Last modified Date:  2020/11/22 15:16:38
// Last Version:        V1.0
// Descriptions:        ����LCD ID������DDR����д��ַ��SD������������
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/11/22 15:16:38
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sd_ddr_size (
    input               clk          , //ʱ��
    input               rst_n        , //��λ���͵�ƽ��Ч
                                       
    input        [15:0] ID_lcd       , //LCD ID
                                       
    output  reg  [23:0] ddr_max_addr , //DDR��д����ַ
    output  reg  [15:0] sd_sec_num     //SD������������
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

//����LCD ID������DDR����д��ַ��SD������������
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
