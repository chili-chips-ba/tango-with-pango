`timescale 1ns / 1ns

module tb_latch();

reg	a;
reg	b;

wire y;

initial begin
	a = 1'b0;
	b <= 1'b1;
end

always #10 a <= {$random} % 2;

always #10 b <= {$random} % 2;


latch   latch_inst(
    .a		(a),
    .b		(b),
			 	
    .y		(y)
    );

endmodule
