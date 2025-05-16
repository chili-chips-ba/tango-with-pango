//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/21 17:44:59
// Design Name: 
// Module Name: tb_mux2_1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_mux2_1(
    );
    
  reg in1;
  reg in2;
  reg sel;
  wire out;
  
  //initial语句是不可以被综合的,一般只在testbench中表达而不在RTL代码中表达。
  initial
      begin   //在仿真中begin...end块中的内容都是顺序执行的
          in1 = 1'b0;
          in2 = 1'b0;
          sel = 1'b0;
  		#100
  		in1 = 1'b0;
  		in2 = 1'b0;
  		sel = 1'b1;
  		#100
  		in1 = 1'b0;
  		in2 = 1'b1;
  		sel = 1'b0;
  		#100
  		in1 = 1'b0;
  		in2 = 1'b1;
  		sel = 1'b1;
  		#100
  		in1 = 1'b1;
  		in2 = 1'b0;
  		sel = 1'b0;
  		#100
  		in1 = 1'b1;
  		in2 = 1'b0;
  		sel = 1'b1;
  		#100
  		in1 = 1'b1;
  		in2 = 1'b1;
  		sel = 1'b1;
      end

mux2_1 u_mux2_1(
    .in1(in1),    //输入信号in1
    .in2(in2),    //输入信号in2
    .sel(sel),    //选择控制信号sel
        
    .out(out)      //输出信号out
    );

endmodule
