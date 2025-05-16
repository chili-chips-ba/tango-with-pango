`timescale 1ns / 1ns

module tb_decoder_3_8();

//define reg
reg		A;
reg		B;
reg		C;

//define wire
wire [7:0] out;

initial begin
	A = 0; B = 0; C = 0;
	#201
	A = 0; B = 0; C = 1;
	#200
	A = 0; B = 1; C = 0;
	#200
	A = 0; B = 1; C = 1;
	#200
	A = 1; B = 0; C = 0;
	#200
	A = 1; B = 0; C = 1;
	#200
	A = 1; B = 1; C = 0;
	#200
	A = 1; B = 1; C= 1;
	#200
	A = 0; B = 0; C= 0;
end

decoder3_8 decoder3_8_inst(
    .A	(A),
    .B	(B),
    .C	(C),

    .out(out)
    );
	
endmodule
