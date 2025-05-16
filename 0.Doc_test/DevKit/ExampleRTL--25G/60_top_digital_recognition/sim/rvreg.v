 module SpiMem(input [31:0]Addr,output reg [15:0] Data);

	reg [15:0]  mem[383999:0]; 
	
  initial $readmemh ( "rom_384000x16b.txt", mem );
  
     always@(Addr) begin
	           Data <=  mem[Addr];
     end 
     
 endmodule 