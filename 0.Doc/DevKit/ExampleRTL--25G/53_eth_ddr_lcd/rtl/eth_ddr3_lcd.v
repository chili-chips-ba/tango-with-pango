//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           eth_ddr3_lcd
// Last modified Date:  2020/05/04 9:19:08
// Last Version:        V1.0
// Descriptions:        ��̫��ͼƬ����LCD��ʾ����
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/05/04 9:19:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module eth_ddr3_lcd(
    input                  sys_clk     ,  //FPGA�ⲿʱ�ӣ�50MHz
    input                  rst_n       ,  //������λ���͵�ƽ��Ч
    //��̫���ӿ�                          
    input                  eth_rxc     ,  //RGMII��������ʱ��
    input                  eth_rx_ctl  ,  //RGMII����������Ч�ź�
    input       [3:0]      eth_rxd     ,  //RGMII��������
    output                 eth_txc     ,  //RGMII��������ʱ��    
    output                 eth_tx_ctl  ,  //RGMII���������Ч�ź�
    output      [3:0]      eth_txd     ,  //RGMII�������          
    output                 eth_rst_n   ,  //��̫��оƬ��λ�źţ��͵�ƽ��Ч                           
    // DDR3                            
    output                mem_rst_n     ,                       
    output                mem_ck        ,
    output                mem_ck_n      ,
    output                mem_cke       ,
    output                mem_ras_n     ,
    output                mem_cas_n     ,
    output                mem_we_n      , 
    output                mem_odt       ,
    output                mem_cs_n      ,
    output      [14:0]    mem_a         ,   
    output      [2:0]     mem_ba        ,   
    inout       [1:0]     mem_dqs       ,
    inout       [1:0]     mem_dqs_n     ,
    inout       [15:0]    mem_dq        ,
    output      [1:0]     mem_dm        ,							   
    //lcd�ӿ�                           
    output                 lcd_hs       ,  //LCD ��ͬ���ź�
    output                 lcd_vs       ,  //LCD ��ͬ���ź�
    output                 lcd_de       ,  //LCD ��������ʹ��
    inout       [23:0]     lcd_rgb      ,  //LCD ��ɫ����
    output                 lcd_bl       ,  //LCD ��������ź�
    output                 lcd_rst      ,  //LCD ��λ�ź�
    output                 lcd_pclk        //LCD ����ʱ��
    );
//parameter define
//������MAC��ַ 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//������IP��ַ 192.168.1.10
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};  
//Ŀ��MAC��ַ ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;    
//Ŀ��IP��ַ 192.168.1.102     
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102};  
				   							   
//wire define    
wire         gmii_rx_clk               ;  //��̫��125Mʱ��            
wire         clk_50m                   ;  //50mhzʱ��,�ṩ��lcd����ʱ��
wire         locked                    ;  //ʱ�������ź�           						    
wire         rdata_req                 ;  //DDR3������ģ���ʹ��
wire  [15:0] rd_data                   ;  //DDR3������ģ�������
wire         ddr3_init_done            ;  //DDR3��ʼ�����init_calib_complete
wire         sys_init_done             ;  //ϵͳ��ʼ�����(DDR��ʼ��+����ͷ��ʼ��)
wire  [27:0] app_addr_rd_min           ;  //��DDR3����ʼ��ַ
wire  [27:0] app_addr_rd_max           ;  //��DDR3�Ľ�����ַ
wire  [7:0]  rd_bust_len               ;  //��DDR3�ж�����ʱ��ͻ������
wire  [27:0] app_addr_wr_min           ;  //дDDR3����ʼ��ַ
wire  [27:0] app_addr_wr_max           ;  //дDDR3�Ľ�����ַ
wire  [7:0]  wr_bust_len               ;  //��DDR3��д����ʱ��ͻ������ 
wire         lcd_clk                   ;  //��Ƶ������LCD ����ʱ��
wire  [12:0] h_disp                    ;  //LCD��ˮƽ�ֱ���
wire  [12:0] v_disp                    ;  //LCD����ֱ�ֱ���     
wire  [10:0] h_pixel                   ;  //����ddr3��ˮƽ�ֱ���        
wire  [10:0] v_pixel                   ;  //����ddr3������ֱ�ֱ��� 
wire  [15:0] lcd_id                    ;  //LCD����ID��
wire  [27:0] ddr3_addr_max             ;  //����DDR3������д��ַ 
wire         i2c_rh_wl                 ;  //I2C��д�����ź�             
wire  [7:0]  i2c_data_r                ;  //I2C������ 
wire  [12:0] total_h_pixel             ;  //ˮƽ�����ش�С 
wire  [12:0] total_v_pixel             ;  //��ֱ�����ش�С
wire  [11:0] pixel_ypos;
wire  [11:0] pixel_xpos;
wire         sys_rst_n                  ;  //ϵͳ��λ�ź�
wire  [7:0]  rec_data                   ;  //��̫�����յ�����
wire  [15:0] picture_data               ;  //ͼƬ����
wire         picture_data_vld           ;  //ͼƬ������Ч�ź�
wire         picture_data_vld0          ;  //��480x272��ͼƬ������Ч�ź�
wire         picture_data_vld1          ;  //480x272��ͼƬ������Ч�ź�
wire         data_req_big               ;  //��480x272����LCD�����ź�
wire         data_req_small             ;  //480x272LCD�������ź�
wire  [10:0] picture_data_cntx;
wire  [10:0] picture_data_cnty;
wire         rec_en;
//*****************************************************
//**                    main code
//*****************************************************
//��PLL����ȶ�֮��ֹͣϵͳ��λ
assign  sys_rst_n     =   rst_n & locked                     ;
//ϵͳ��ʼ����ɣ�DDR3��ʼ�����
assign  sys_init_done =   ddr3_init_done                ;
assign  ddr3_addr_max =  (lcd_id == 16'h4342) ? 130560:384000; //����ddr3������д��ַ
assign  h_disp        =  (lcd_id == 16'h4342) ? 480:800      ; //����ddr3��һ�����ݣ�ͻ�����ȣ�

//ʱ�Ӳ���ģ��
clk_wiz_0 u_clk_wiz_0 (
  .pll_rst(1'b0),      // input
  .clkin1(sys_clk),        // input
  .pll_lock(locked),    // output
  .clkout0(clk_50m)       // output
);


//480x272��ͼƬ�ü�ģ��   
picture_tailor u_picture_tailor(
    .gmii_rx_clk           (gmii_rx_clk)          ,  //ͼƬ��������ʱ��
    .sys_rst_n             (sys_rst_n)            ,  //��λ�ź�                        
    .picture_data_vld0     (picture_data_vld0)    , 
    //480x272��ͼƬ������Ч�ź�                      
    .picture_data_vld1     (picture_data_vld1)    ,
    .picture_data_cntx     (picture_data_cntx)    ,
    .picture_data_cnty     (picture_data_cnty)    
     //��480x272��ͼƬ������Ч�ź� 
    );
       
// ddr3����ģ��
ddr3_ctrl_top u_ddr3_ctrl_top(
    .clk            (clk_50m        ),
    .rst_n          (sys_rst_n      ),
    .ddr3_init_done (ddr3_init_done),  //ddr��ʼ������ź�
    // �û��ӿ�
    .wd_clk         (gmii_rx_clk    ),      //дʱ��
    .rd_clk         (lcd_clk        ),      //��ʱ��
    .wd_en          (picture_data_vld),     //������Чʹ���ź�
    .wd_data        (picture_data   ),      //д��Ч����
    .rd_en          (rdata_req      ),      //DDR3 ��ʹ��
    .rd_data        (rd_data         ),      //rfifo�������
    .addr_rd_min    (28'b0          ),      //��DDR3����ʼ��ַ
    .addr_rd_max    (ddr3_addr_max  ),      //��DDR�Ľ�����ַ
    .rd_burst_len   (h_disp[12:3]   ),      //��DDR3�ж����ݵ�ͻ������
    .addr_wd_min    (28'b0          ),      //дDDR3����ʼ��ַ
    .addr_wd_max    (ddr3_addr_max  ),      //дDDR�Ľ�����ַ
    .wd_burst_len   (h_disp[12:3]   ),      //д��DDR3�����ݵ�ͻ������

    .wr_load        (1'd0),                     //����Դ�����ź�
    .rd_load        (rd_vsync       ),      //���Դ�����ź�
    .ddr3_pingpang_en(1'b0),                //DDR3 ƹ�Ҳ���
    .ddr3_read_valid (1'b1),                //������������
    //DDR3 IO�ӿ�
    .mem_rst_n      (mem_rst_n      ),
    .mem_ck         (mem_ck         ),
    .mem_ck_n       (mem_ck_n       ),
    .mem_cke        (mem_cke        ),
    .mem_ras_n      (mem_ras_n      ),
    .mem_cas_n      (mem_cas_n      ),
    .mem_we_n       (mem_we_n       ),
    .mem_odt        (mem_odt        ),
    .mem_cs_n       (mem_cs_n       ),
    .mem_a          (mem_a          ),
    .mem_ba         (mem_ba         ),
    .mem_dqs        (mem_dqs        ),
    .mem_dqs_n      (mem_dqs_n      ),
    .mem_dq         (mem_dq         ),
    .mem_dm         (mem_dm         )
);
                  
//LCD ����
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (clk_50m  ),             //ʱ��
    .sys_rst_n             (sys_rst_n ),            //��λ
	.sys_init_done         (sys_init_done),         //��ʼ�����
    //lcd�ӿ� 				           
    .lcd_id                (lcd_id),                //LCD����ID�� 
    .lcd_hs                (lcd_hs),                //LCD ��ͬ���ź�
    .lcd_vs                (lcd_vs),                //LCD ��ͬ���ź�
    .lcd_de                (lcd_de),                //LCD ��������ʹ��
    .lcd_rgb               (lcd_rgb),               //LCD ��ɫ����
    .lcd_bl                (lcd_bl),                //LCD ��������ź�
    .lcd_rst               (lcd_rst),               //LCD ��λ�ź�
    .lcd_pclk              (lcd_pclk),              //LCD ����ʱ��
    .lcd_clk               (lcd_clk), 	            //LCD ����ʱ��
	//�û��ӿ�			           
    .out_vsync             (rd_vsync),              //lcd���ź�
    .h_disp                (),                      //�зֱ��� h_disp 
    .v_disp                (),                      //���ֱ��� v_disp 
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),       
    .data_in               (rd_data),	            //rfifo�������
    .data_req              (rdata_req)             //������������
    );   

//��̫������
eth_top #(
    .BOARD_MAC          (BOARD_MAC),                //������MAC��ַ
    .BOARD_IP           (BOARD_IP),                 //������IP��ַ
    .DES_MAC            (DES_MAC),                  //Ŀ��MAC��ַ
    .DES_IP             (DES_IP)                    //Ŀ��IP��ַ
    )
u_eth_top(
    .sys_rst_n          (sys_rst_n) ,              //ϵͳ��λ�źţ��͵�ƽ��Ч 
    .eth_rxc            (eth_rxc)   ,              //RGMII��������ʱ��
    .eth_rx_ctl         (eth_rx_ctl),              //RGMII����������Ч�ź�
    .eth_rxd            (eth_rxd)   ,              //RGMII��������
    .eth_txc            (eth_txc)   ,              //RGMII��������ʱ��    
    .eth_tx_ctl         (eth_tx_ctl),              //RGMII���������Ч�ź�
    .eth_txd            (eth_txd)   ,              //RGMII�������          
    .eth_rst_n          (eth_rst_n) ,              //��̫��оƬ��λ�źţ��͵�ƽ��Ч 

    .udp_rec_en         (rec_en),                  //��̫��8λͼƬ���ݽ������
    .udp_rec_data       (rec_data),                //��̫��8λ����
    .gmii_rx_clk        (gmii_rx_clk)              //��̫��125Mʱ��
    ); 
    

udp_data u_udp_data(
  .clk                 (gmii_rx_clk),              //ʱ���ź�
  .rst_n               (sys_rst_n),                //��λ�źţ��͵�ƽ��Ч                                               
  .rec_en              (rec_en),                   //UDP���յ�����ʹ���ź�
  .picture_data_vld0   (picture_data_vld0),        //��480x272��ͼƬ������Ч
  .picture_data_vld1   (picture_data_vld1),        //480x272��ͼƬ������Ч  
  .lcd_id              (lcd_id),                   //LCD��ID
  .picture_data_vld    (picture_data_vld),         //ͼƬ������Ч  
  .rec_data            (rec_data),   
       //��̫��16λͼƬ��������
  .picture_data        (picture_data)              //��̫��16λͼƬ��������
    );  
    
endmodule 