// Created by IP Generator (Version 2022.2-SP4.2 build 132111)
// Instantiation Template
//
// Insert the following codes into your Verilog file.
//   * Change the_instance_name to your own instance name.
//   * Change the signal names in the port associations


sync_fifo_2048x8b the_instance_name (
  .clk(clk),                      // input
  .rst(rst),                      // input
  .wr_en(wr_en),                  // input
  .wr_data(wr_data),              // input [7:0]
  .wr_full(wr_full),              // output
  .almost_full(almost_full),      // output
  .rd_en(rd_en),                  // input
  .rd_data(rd_data),              // output [7:0]
  .rd_empty(rd_empty),            // output
  .almost_empty(almost_empty)     // output
);
