//****************************************Copyright (c)***********************************//      
//����֧�֣�www.openedv.com                                                                            
//�Ա����̣�http://openedv.taobao.com                                                                  
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡFPGA & STM32���ϡ�                                                         
//��Ȩ���У�����ؾ���                                                                                     
//Copyright(C) ����ԭ�� 2018-2028                                                                     
//All rights reserved                                                                             
//----------------------------------------------------------------------------------------        
// File name:           dht11_drive                                                               
// Last modified Date:  2018-04-07 16:32:16                                                         
// Last Version:        V1.0                                                                      
// Descriptions:        ��ʪ�ȴ���������ģ��                                                              
//----------------------------------------------------------------------------------------        
// Created by:          ����ԭ��                                                                      
// Created date:        2018-04-07 16:32:22                                                         
// Version:             V1.0                                                                      
// Descriptions:        The original version                                                      
//                                                                                                
//----------------------------------------------------------------------------------------        
// Modified by:         ����ԭ��                                                                      
// Modified date:                                                                                 
// Version:                                                                                       
// Descriptions:                                                                                  
//                                                                                                
//----------------------------------------------------------------------------------------        
//****************************************************************************************//

module dht11_drive (
    input                sys_clk    ,   //ϵͳʱ��
    input                rst_n      ,   //ϵͳ��λ
                                        
    inout                dht11      ,   //dht11��ʪ�ȴ�����������
    output  reg  [31:0]  data_valid     //��Ч�������
);                                      
                                        
//parameter define 
parameter  POWER_ON_NUM     = 1000_000; //�ϵ���ʱ�ȴ�ʱ��,��λus
//״̬������״̬                     
parameter  st_power_on_wait = 3'd0;     //�ϵ���ʱ�ȴ�
parameter  st_low_20ms      = 3'd1;     //��������20ms�͵�ƽ
parameter  st_high_13us     = 3'd2;     //�����ͷ�����13us
parameter  st_rec_low_83us  = 3'd3;     //����83us�͵�ƽ��Ӧ
parameter  st_rec_high_87us = 3'd4;     //�ȴ�87us�ߵ�ƽ��׼���������ݣ�
parameter  st_rec_data      = 3'd5;     //����40λ����
parameter  st_delay         = 3'd6;     //��ʱ�ȴ�,��ʱ��ɺ����²���DHT11

//reg define
reg    [2:0]   cur_state   ;        //��ǰ״̬
reg    [2:0]   next_state  ;        //��һ��״̬
                           
reg    [4:0]   clk_cnt     ;        //��Ƶ������
reg            clk_1m      ;        //1Mhzʱ��
reg    [20:0]  us_cnt      ;        //1΢�������
reg            us_cnt_clr  ;        //1΢������������ź�
                           
reg    [39:0]  data_temp   ;        //������յ�������
reg            step        ;        //���ݲɼ�״̬
reg    [5:0]   data_cnt    ;        //���������ü�����

reg            dht11_buffer;        //DHT11����ź�
reg            dht11_d0    ;        //DHT11�����źżĴ���0
reg            dht11_d1    ;        //DHT11�����źżĴ���1

//wire define                       
wire        dht11_pos      ;        //DHT11������
wire        dht11_neg      ;        //DHT11�½���

//*****************************************************
//**                    main code
//*****************************************************

assign dht11     = dht11_buffer;
assign dht11_pos = ~dht11_d1 & dht11_d0; //�ɼ�������
assign dht11_neg = dht11_d1 & ~dht11_d0; //�ɼ��½���

//�õ�1Mhz��Ƶʱ��
always @ (posedge sys_clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_cnt <= 5'd0;
        clk_1m  <= 1'b0;
    end 
    else if (clk_cnt < 5'd24) 
        clk_cnt <= clk_cnt + 1'b1;       
    else begin
        clk_cnt <= 5'd0;
        clk_1m  <= ~ clk_1m;
    end 
end

//��DHT11�����ź������Ĵ����Σ����ڱ��ؼ��
always @ (posedge clk_1m or negedge rst_n) begin
    if (!rst_n) begin
        dht11_d0 <= 1'b1;
        dht11_d1 <= 1'b1;
    end 
    else begin
        dht11_d0 <= dht11;
        dht11_d1 <= dht11_d0;
    end 
end 

//1΢�������
always @ (posedge clk_1m or negedge rst_n) begin
    if (!rst_n)
        us_cnt <= 21'd0;
    else if (us_cnt_clr)
        us_cnt <= 21'd0;
    else 
        us_cnt <= us_cnt + 1'b1;
end 

//״̬��ת
always @ (posedge clk_1m or negedge rst_n) begin
    if (!rst_n)
        cur_state <= st_power_on_wait;
    else 
        cur_state <= next_state;
end 

//״̬����ȡDHT11����
always @ (posedge clk_1m or negedge rst_n) begin
    if(!rst_n) begin
        next_state   <= st_power_on_wait;
        data_temp    <= 40'd0;
        step         <= 1'b0; 
        us_cnt_clr   <= 1'b0;
        data_cnt     <= 6'd0;
        dht11_buffer <= 1'bz;   
    end 
    else begin
        case (cur_state)
            //�ϵ����ʱ1��ȴ�DHT11�ȶ�
            st_power_on_wait : begin                
                if(us_cnt < POWER_ON_NUM) begin
                    dht11_buffer <= 1'bz; //����״̬�ͷ�����
                    us_cnt_clr   <= 1'b0;
                end
                else begin            
                    next_state   <= st_low_20ms;
                    us_cnt_clr   <= 1'b1;
                end
            end
            //FPGA������ʼ�źţ�20ms�ĵ͵�ƽ��    
            st_low_20ms: begin
                if(us_cnt < 20000) begin
                    dht11_buffer <= 1'b0; //��ʼ�ź�Ϊ�͵�ƽ 
                    us_cnt_clr   <= 1'b0;
                end
                else begin
                    dht11_buffer <= 1'bz; //��ʼ�źŽ������ͷ�����
                    next_state   <= st_high_13us;
                    us_cnt_clr   <= 1'b1;
                end    
            end 
            //�ȴ�DHT11����Ӧ�źţ��ȴ�10~20us��
            st_high_13us:begin                      
                if (us_cnt < 20) begin
                    us_cnt_clr   <= 1'b0;
                    if(dht11_neg) begin   //��⵽DHT11��Ӧ�ź�
                        next_state <= st_rec_low_83us;
                        us_cnt_clr <= 1'b1; 
                    end
                end
                else                      //����20usδ��Ӧ
                    next_state <= st_delay;
            end 
            //�ȴ�DHT11��83us�͵�ƽ��Ӧ�źŽ��� 
            st_rec_low_83us: begin                  
                if(dht11_pos)                   
                    next_state <= st_rec_high_87us;  
            end 
            //DHT11����87us֪ͨFPGA׼���������� 
            st_rec_high_87us: begin
                if(dht11_neg) begin       //׼��ʱ�����    
                    next_state <= st_rec_data; 
                    us_cnt_clr <= 1'b1;
                end
                else begin                //�ߵ�ƽ׼����������
                    data_cnt  <= 6'd0;
                    data_temp <= 40'd0;
                    step  <= 1'b0;
                end
            end 
            //��������40λ����  
            st_rec_data: begin                                
                case(step)
                    0: begin              //�������ݵ͵�ƽ
                        if(dht11_pos) begin 
                            step   <= 1'b1;
                            us_cnt_clr <= 1'b1;
                        end            
                        else              //�ȴ����ݵ͵�ƽ����
                            us_cnt_clr <= 1'b0;
                    end
                    1: begin              //�������ݸߵ�ƽ
                        if(dht11_neg) begin 
                            data_cnt <= data_cnt + 1'b1;
                                          //�жϽ�������Ϊ0/1
                            if(us_cnt < 60)
                                data_temp <= {data_temp[38:0],1'b0};
                            else                
                                data_temp <= {data_temp[38:0],1'b1};
                            step <= 1'b0;
                            us_cnt_clr <= 1'b1;
                        end 
                        else              //�ȴ����ݸߵ�ƽ����
                            us_cnt_clr <= 1'b0;
                    end
                endcase
                
                if(data_cnt == 40) begin  //���ݴ����������֤У��λ
                    next_state <= st_delay;
                    if(data_temp[7:0] == data_temp[39:32] + data_temp[31:24] 
                                         + data_temp[23:16] + data_temp[15:8])
                        data_valid <= data_temp[39:8];  
                end
            end 
            //���һ�����ݲɼ�����ʱ2s 
            st_delay:begin
                if(us_cnt < 2000_000)
                    us_cnt_clr <= 1'b0;
                else begin                //��ʱ���������·�����ʼ�ź�
                    next_state <= st_low_20ms;      
                    us_cnt_clr <= 1'b1;
                end
            end
            default : ;
        endcase
    end 
end

endmodule                                     