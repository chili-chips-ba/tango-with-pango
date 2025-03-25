module lcd_display(
    input             lcd_clk,                  //lcd驱动时钟
    input             sys_rst_n,                //复位信号
    input      [15:0] lcd_id,                   //LCD屏ID
    
    input      [11:0] pixel_xpos,               //像素点横坐标
    input      [11:0] pixel_ypos,               //像素点纵坐标   
    input      [15:0] cmos_data,                //CMOS传感器像素点数据
    input      [10:0] h_disp,                   //LCD屏水平分辨率
    input      [10:0] v_disp,                   //LCD屏垂直分辨率   
    
    output     [15:0] lcd_data,                 //LCD像素点数据
    output            data_req                  //请求像素点颜色数据输入
    );    

//parameter define  
parameter  V_CMOS_DISP = 11'd480;                //CMOS分辨率--行
parameter  H_CMOS_DISP = 11'd800;                //CMOS分辨率--列

localparam BLACK  = 16'b00000_000000_00000;      //RGB565 黑色

//reg define   
reg             data_val            ;            //数据有效信号

//wire define
wire    [10:0]  display_border_pos_l;            //左侧边界的横坐标
wire    [10:0]  display_border_pos_r;            //右侧边界的横坐标
wire    [10:0]  display_border_pos_t;            //上端边界的纵坐标
wire    [10:0]  display_border_pos_b;            //下端边界的纵坐标

//*****************************************************
//**                    main code
//*****************************************************

//左侧边界的横坐标计算 
assign display_border_pos_l  = (h_disp - H_CMOS_DISP)/2;//-1

//右侧边界的横坐标计算 
assign display_border_pos_r = H_CMOS_DISP + (h_disp - H_CMOS_DISP)/2;//-1

//上端边界的纵坐标计算 
assign display_border_pos_t  = (v_disp - V_CMOS_DISP)/2;

//下端边界的纵坐标计算
assign display_border_pos_b = V_CMOS_DISP + (v_disp - V_CMOS_DISP)/2;

//请求像素点颜色数据输入 范围:79~718，共640个时钟周期
assign data_req = ((pixel_xpos >= display_border_pos_l) &&
                  (pixel_xpos < display_border_pos_r) &&
                  (pixel_ypos > display_border_pos_t) &&
                  (pixel_ypos <= display_border_pos_b)
                  ) ? 1'b1 : 1'b0;

//在数据有效范围内，将摄像头采集的数据赋值给LCD像素点数据
assign lcd_data = data_val ? cmos_data : BLACK;

//有效数据滞后于请求信号一个时钟周期,所以数据有效信号在此延时一拍
always @(posedge lcd_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        data_val <= 1'b0;
    else
        data_val <= data_req;    
end    

endmodule