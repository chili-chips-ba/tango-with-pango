`timescale 1ns / 1ns

module tb_divider_4();

reg			sys_clk		;
reg			sys_rst_n	;
						
wire		out_clk     ;

initial begin
	sys_clk = 1'b1;
	sys_rst_n <= 1'b0;
	#201
	sys_rst_n <= 1'b1;
end

always #10 sys_clk <= ~sys_clk;

divider_4	divider_4_inst(
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
				 			
	.out_clk    (out_clk   )
);

endmodule
