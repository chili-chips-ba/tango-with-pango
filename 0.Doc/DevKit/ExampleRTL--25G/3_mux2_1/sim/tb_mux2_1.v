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
  
  //initial����ǲ����Ա��ۺϵ�,һ��ֻ��testbench�б�������RTL�����б�
  initial
      begin   //�ڷ�����begin...end���е����ݶ���˳��ִ�е�
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
    .in1(in1),    //�����ź�in1
    .in2(in2),    //�����ź�in2
    .sel(sel),    //ѡ������ź�sel
        
    .out(out)      //����ź�out
    );

endmodule
