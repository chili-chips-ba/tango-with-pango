`timescale 1 ns/ 1 ns
module tb_top_digital_recognition();

parameter T = 20;


reg         sys_clk  ;
reg         sys_rst_n;
reg         rst_n;



							  
wire         rdata_req                 ;  //DDR3������ģ���ʹ��
wire         lcd_de                    ;  //LCD ��������ʹ��
wire         lcd_clk                   ;  //��Ƶ������LCD ����ʱ��    
wire  [15:0] post_rgb                  ;  //������ͼ������
wire  [10:0] pixel_xpos                ;  //���ص������
wire  [10:0] pixel_ypos                ;  //���ص�������  
wire  [23:0] digit                     ;  //���ص������� 
wire  [15:0] color_rgb        		   ;
wire  [15:0] post_rgb	       		   ;
wire         hs_t             		   ;
wire         vs_t             		   ;
wire         de_t             		   ; 
reg   [15:0] rd_data				   ;
reg   [31:0] Addr					   ;
wire  [15:0] Data					   ;
reg          rdata_req_d0			   ;
reg   [10:0] v_cnt	   				   ;
reg   [10:0] h_cnt	   				   ;
reg          data_en	   			   ;
wire  [10:0] h_disp                    ;  //LCD��ˮƽ�ֱ���
wire  [10:0] v_disp                    ;  //LCD����ֱ�ֱ���  
wire  [23:0] lcd_rgb				   ;

initial begin   

     sys_clk            <=1'b0;   //��ʼʱ��Ϊ�͵�ƽ
     rst_n <=0;
     sys_rst_n          <=1'b0;   //��λ�źų�ʼΪ�͵�ƽ
     
     #1000   
     sys_rst_n      	<=1'b1;   //һ��ʱ�����ں�λ�ź�����
     rst_n <=0;
     #500 
     rst_n <=1;    



end 

assign   lcd_rgb = de_t ? {24{1'bz}} :  24'h800080;

always # (T/2) sys_clk <= ~sys_clk;

always@(posedge lcd_clk)begin
	if(!rst_n)
		Addr <= 0;
	else if(Addr == 383999)	
		Addr <= 0;  
	else if(data_en) 
		Addr <= Addr + 1;  
	else
		Addr <= Addr;    
end

always@(posedge lcd_clk)begin
	if(!rst_n)
		data_en <= 0;
	else if((v_cnt>=200 && v_cnt <680) && (h_cnt>=200 && h_cnt <1000))	
		data_en <= 1;  
	else
		data_en <= 0;    
end

always@(posedge lcd_clk)begin
	if(!rst_n)
		rd_data <= 0;
	else if(rdata_req )	
		if(data_en)
			rd_data <= Data;  
    else 
        rd_data <= 16'hffff;      
	else
		rd_data <= 16'h0;    
end

always@(posedge lcd_clk)begin
	if(!rst_n)
		rdata_req_d0 <= 0; 
	else
		rdata_req_d0 <= rdata_req;    
end

always@(posedge lcd_clk)begin
	if(!rst_n)
		v_cnt <= 0;
	else if(v_cnt==799 && rdata_req_d0 && ~rdata_req )   
		v_cnt <= 0; 
	else if(rdata_req_d0 && ~rdata_req)	
		v_cnt <= v_cnt + 1;  
	else
		v_cnt <= v_cnt;   
end


always@(posedge lcd_clk)begin
	if(!rst_n)
		h_cnt <= 0;
	else if(rdata_req )   
		h_cnt <= h_cnt + 1;	  
	else
		h_cnt <= 0;    
end



SpiMem u_SpiMem(
.Addr (Addr),
.Data (Data)
);

//LCD������ʾģ��
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (sys_clk  ),
    .sys_rst_n             (sys_rst_n ),
	.sys_init_done         (1),		
				           
    //lcd�ӿ� 				           
    .lcd_id                (),                		//LCD����ID�� 
    .lcd_hs                (hs_t),                	//LCD ��ͬ���ź�
    .lcd_vs                (vs_t),                	//LCD ��ͬ���ź�
    .lcd_de                (de_t),                	//LCD ��������ʹ��
    .lcd_rgb               (lcd_rgb),               //LCD ��ɫ����
    .lcd_bl                (),                		//LCD ��������ź�
    .lcd_rst               (),               		//LCD ��λ�ź�
    .lcd_pclk              (),              		//LCD ����ʱ��
    .lcd_clk               (lcd_clk), 	            //LCD ����ʱ��
	//�û��ӿ�			           
    .out_vsync             (rd_vsync),              //lcd���ź�
    .h_disp                (h_disp),                //�зֱ���  
    .v_disp                (v_disp),                //���ֱ���  
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),   
    .pre_rgb               (color_rgb), 
	.post_rgb              (post_rgb),
	.post_de               (lcd_de),	    
    .data_in               (rd_data),	            //rfifo�������
    .data_req              (rdata_req)              //������������
    ); 
    
  //ͼ����ģ��
vip u_vip(
    //module clock
    .clk              (lcd_clk),          			// ʱ���ź�
    .rst_n            (sys_rst_n ),            		// ��λ�źţ�����Ч��
    //ͼ����ǰ�����ݽӿ�
    .pre_frame_vsync  (vs_t),
    .pre_frame_hsync  (hs_t),
    .pre_frame_de     (de_t),
    .pre_rgb          (color_rgb),
    .xpos             (pixel_xpos),
    .ypos             (pixel_ypos),
    //ͼ���������ݽӿ�
    .h_total_pexel    (h_disp),
    .v_total_pexel    (v_disp),    
    .post_frame_vsync (lcd_vs),  					// �����ĳ��ź�
    .post_frame_hsync (lcd_hs ),                 	// ���������ź�
    .post_frame_de    (lcd_de),     				// ������������Чʹ�� 
    .digit            (digit),
    .post_rgb         (post_rgb)           			// ������ͼ������

);    

endmodule