`timescale 1ns / 1ns

module tb_or_gate ();

//define reg
reg  A;
reg  B;

//define wire
wire     Y;

initial begin
    A = 1'b0;
    B = 1'b0;
    #100
    A = 1'b0;
    B = 1'B1;
    #100
    A = 1'b1;
    B = 1'b0;
    #100
    A = 1'b1;
    B = 1'b1;
end


or_gate or_gate_inst(
    .A(A),	//输入A
    .B(B),	//输入B
   
    .Y(Y)	//输出Y
    );
 
endmodule

