`timescale 1ns / 1ns

module tb_edge_test();
	
reg			sys_clk		;
reg			sys_rst_n	;
reg			a			;
	
wire		a_posedge	;
wire		a_negedge	;
wire		a_edge      ;


initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	a <= 1'b0;
	#201
	sys_rst_n <= 1'b1;
	#20
	a <= 1'b1;
	#100
	a <= 1'b0;
end
	
always #10 sys_clk <= ~sys_clk;	
	
	
edge_test	edge_test_inst(
	   .sys_clk		(sys_clk	),
	   .sys_rst_n	(sys_rst_n	),
	   .a			(a			),
					 		
	   .a_posedge	(a_posedge	),
	   .a_negedge	(a_negedge	),
	   .a_edge      (a_edge   	)
);	
	
endmodule
