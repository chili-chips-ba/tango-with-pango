// Created by IP Generator (Version 2022.2-SP4.2 build 132111)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


ram_1port the_instance_name (
  .wr_data(wr_data),    // input [7:0]
  .addr(addr),          // input [4:0]
  .wr_en(wr_en),        // input
  .clk(clk),            // input
  .rst(rst),            // input
  .rd_data(rd_data)     // output [7:0]
);
