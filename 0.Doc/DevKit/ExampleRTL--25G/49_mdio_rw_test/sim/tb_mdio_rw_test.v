`timescale 1ns / 1ns

module tb_mdio_rw_test();

parameter  PHY_ADDR = 5'h04;           //设置PHY地址

reg          sys_clk  ;
reg          sys_rst_n;
reg          touch_key; //触摸按键

wire         eth_mdio ; //PHY管理接口的双向数据信号
wire         eth_mdc  ; //PHY管理接口的时钟信号
wire         eth_rst_n; //以太网复位信号
wire  [1:0]  led      ; //LED连接速率指示

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	touch_key <= 1'b0;
	#201
	sys_rst_n <= 1'b1;
	#200
	touch_key <= 1'b1;
	#400
	touch_key <= 1'b0;
end
	
always #10 sys_clk <= ~sys_clk;

pullup(eth_mdio);      //MDIO信号上拉

//为PHY寄存器赋初始值
reg         we_i;
reg         strobe_i;
reg  [7:0]  address_i;
reg  [7:0]  data_i;

defparam mdio_rw_test_inst.u_mdio_ctrl.TIME_CNT = 1000;

initial begin
    we_i           = 1'b0;
    strobe_i       = 1'b0;     
    address_i      = 8'd0;
    data_i         = 8'd0;
    #200       
    we_i           = 1'b1;         
    strobe_i       = 1'b1; 
    address_i      = 8'h0a;
    data_i         = 8'h55;
    #20             
    address_i      = 8'h0b;
    data_i         = 8'haa;
    #20            
    address_i      = 8'h40;        //设置PHY芯片的PHY地址
    data_i         = PHY_ADDR;            
    #20
    we_i           = 1'b0;
    strobe_i       = 1'b0;    
    address_i      = 8'd0;
    data_i         = 8'd0;    
end

mdio_rw_test mdio_rw_test_inst(
    .sys_clk  	(sys_clk  ),
    .sys_rst_n	(sys_rst_n),
	.touch_key	(touch_key), //触摸按键
				
	.eth_mdio 	(eth_mdio ), //PHY管理接口的双向数据信号
    .eth_mdc  	(eth_mdc  ), //PHY管理接口的时钟信号
    .eth_rst_n	(eth_rst_n), //以太网复位信号
    .led      	(led      )  //LED连接速率指示
    );
	
//例化MDIO接口从机仿真模型
mdio_slave_interface u_mdio_slave_interface(
		.rst_n_i    (sys_rst_n),
		.mdc_i      (eth_mdc),
		.mdio       (eth_mdio),

		//wishbone interface 
		.clk_i      (sys_clk),
		.rst_i      (~sys_rst_n),
		.address_i  (address_i),
  		.data_i     (data_i),
  		.data_o     (),
  		.strobe_i   (strobe_i),
  		.we_i		(we_i),
  		.ack_o      ()
    );

endmodule