`timescale 1 ns/ 1 ns
module tb_top_digital_recognition();

parameter T = 20;


reg         sys_clk  ;
reg         sys_rst_n;
reg         rst_n;



							  
wire         rdata_req                 ;  //DDR3控制器模块读使能
wire         lcd_de                    ;  //LCD 数据输入使能
wire         lcd_clk                   ;  //分频产生的LCD 采样时钟    
wire  [15:0] post_rgb                  ;  //处理后的图像数据
wire  [10:0] pixel_xpos                ;  //像素点横坐标
wire  [10:0] pixel_ypos                ;  //像素点纵坐标  
wire  [23:0] digit                     ;  //像素点纵坐标 
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
wire  [10:0] h_disp                    ;  //LCD屏水平分辨率
wire  [10:0] v_disp                    ;  //LCD屏垂直分辨率  
wire  [23:0] lcd_rgb				   ;

initial begin   

     sys_clk            <=1'b0;   //初始时钟为低电平
     rst_n <=0;
     sys_rst_n          <=1'b0;   //复位信号初始为低电平
     
     #1000   
     sys_rst_n      	<=1'b1;   //一个时钟周期后复位信号拉高
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

//LCD驱动显示模块
lcd_rgb_top  u_lcd_rgb_top(
	.sys_clk               (sys_clk  ),
    .sys_rst_n             (sys_rst_n ),
	.sys_init_done         (1),		
				           
    //lcd接口 				           
    .lcd_id                (),                		//LCD屏的ID号 
    .lcd_hs                (hs_t),                	//LCD 行同步信号
    .lcd_vs                (vs_t),                	//LCD 场同步信号
    .lcd_de                (de_t),                	//LCD 数据输入使能
    .lcd_rgb               (lcd_rgb),               //LCD 颜色数据
    .lcd_bl                (),                		//LCD 背光控制信号
    .lcd_rst               (),               		//LCD 复位信号
    .lcd_pclk              (),              		//LCD 采样时钟
    .lcd_clk               (lcd_clk), 	            //LCD 驱动时钟
	//用户接口			           
    .out_vsync             (rd_vsync),              //lcd场信号
    .h_disp                (h_disp),                //行分辨率  
    .v_disp                (v_disp),                //场分辨率  
    .pixel_xpos            (pixel_xpos),
    .pixel_ypos            (pixel_ypos),   
    .pre_rgb               (color_rgb), 
	.post_rgb              (post_rgb),
	.post_de               (lcd_de),	    
    .data_in               (rd_data),	            //rfifo输出数据
    .data_req              (rdata_req)              //请求数据输入
    ); 
    
  //图像处理模块
vip u_vip(
    //module clock
    .clk              (lcd_clk),          			// 时钟信号
    .rst_n            (sys_rst_n ),            		// 复位信号（低有效）
    //图像处理前的数据接口
    .pre_frame_vsync  (vs_t),
    .pre_frame_hsync  (hs_t),
    .pre_frame_de     (de_t),
    .pre_rgb          (color_rgb),
    .xpos             (pixel_xpos),
    .ypos             (pixel_ypos),
    //图像处理后的数据接口
    .h_total_pexel    (h_disp),
    .v_total_pexel    (v_disp),    
    .post_frame_vsync (lcd_vs),  					// 处理后的场信号
    .post_frame_hsync (lcd_hs ),                 	// 处理后的行信号
    .post_frame_de    (lcd_de),     				// 处理后的数据有效使能 
    .digit            (digit),
    .post_rgb         (post_rgb)           			// 处理后的图像数据

);    

endmodule