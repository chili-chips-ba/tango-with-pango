`timescale  1ns/1ns                // �������ʱ�䵥λ1ns�ͷ���ʱ�侫��Ϊ1ns

module  tb_rs485_key_led;      // ����ģ��

//parameter  define
parameter  T = 20;                 // ʱ������Ϊ10ns

//defparam  define
defparam u_rs485_key_led.u_key_trig.u_key_debounce_0.CNT_MAX=10;
defparam u_rs485_key_led.u_key_trig.u_key_debounce_1.CNT_MAX=10;

//reg define
reg         sys_clk  ;  // ʱ���ź�
reg         sys_rst_n;  // ��λ�ź�
reg  [1:0]  key      ;  // ��λ�ź�
reg         uart_rxd ;  // UART���ն˿�

//*****************************************************
//**                    main code
//*****************************************************

//�������źų�ʼֵ
initial begin
   sys_clk            = 1'b0 ;  
   sys_rst_n          = 1'b0 ;     // ��λ
   key                = 2'b11;     //����
   uart_rxd           = 1'b1 ;     //����Ϊ��
    #(T+10)
   sys_rst_n  = 1'b1;              // �ڵ�30ns��ʱ��λ�ź��ź�����
    #(1000) 
   uart_rxd           = 1'b0 ;     //��ʼλ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit0λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit1λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit2λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit3λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit4λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit5λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit6λ
    #(8680)
   uart_rxd           = 1'b0 ;     //bit7λ
    #(8680)
   uart_rxd           = 1'b1 ;     //ֹͣλ   
    #(1000)
   key                = 2'b10;
    #(20)
   key                = 2'b11;
    #(60)
   key                = 2'b10;
end

//50Mhz��ʱ�ӣ�������Ϊ1/50Mhz=20ns,����ÿ10ns����ƽȡ��һ��
always #(T/2) sys_clk = ~sys_clk;

//��������ģ��
 rs485_key_led u_rs485_key_led(
    .sys_clk          (sys_clk  ),    //50mʱ��
    .sys_rst_n        (sys_rst_n),    //��λ�źţ��͵�ƽ��Ч
    .key              (key      ),    //����
    .led              (),             //led��
    .rs485_uart_rxd   (uart_rxd ),    //UART���ն˿�
    .rs485_uart_txd   ()              //UART���Ͷ˿�
);
    
endmodule