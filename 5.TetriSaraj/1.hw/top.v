/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps

module top (
   input wire clk_10mhz,      // 10MHz clock

   //output wire led_olimex,     // LED output

   output tx,
   input  rx,

   input  btnC,
   input  btnU,
   input  btnD,
   input  btnL,
   input  btnR,
   
   input  [15:0] sw,
   output [15:0] led,
   output [7:0] cathodes,
   output [3:0] anodes,

   output hsync,       // to VGA connector
   output vsync,       // to VGA connector
   output [11:0] rgb,  // to DAC, to VGA connector

    output [7:0] jb
);
   
   // command protocol constants:
   parameter [7:0]  C_SOP = 8'h23;
   parameter [7:0]  C_EOP = 8'h0d;
   
   // commands:
   parameter [7:0]  C_REGISTER_RD = 8'h08;
   parameter [7:0]  C_REGISTER_WR = 8'h07;
   
   wire        rx_busy, tx_busy, converted, data_valid;
   reg [15:0]     data_length, data_cnt;
   reg [7:0]      command;  

   // Local control logic variables
   // FSM state  
   reg [3:0] state;

   // This variable is super critical in preventing wrong FSM state changes
   reg allow_next;     // Local signal to prevent race conditions 
    
   // IO related variables
   reg flush_ctrl;    // Flush the RX data after reading
   reg tx_enable_ctrl;    // Allow tranmission of output, after data is settled

   wire [7:0]    uart_data;   // The actual RX UART data      
   reg  [7:0]    out_data;   // The data that will be sent over TX    

   reg ram_wen; 
   reg [31:0] ram_data, ram_addr;
   reg [15:0] display_data;
   reg [7:0] checksum;
   reg [8:0] leds;

   // UART clock related variables
   reg [4:0]  counter; 
   
   // VGA signals
   wire [9:0]     w_x, w_y;
   wire          w_video_on, w_p_tick;
   reg  [11:0]   rgb_reg;
   wire [11:0]   rgb_next;

   ///////////////////////////////////
   // Power-on Reset
   ///////////////////////////////////
   reg [7:0] reset_cnt = 0;
   wire resetn = &reset_cnt;
	
	   wire clk, lock;

   pll pll_inst (
      .clock_in(clk_10mhz), // 10 MHz
      .rst_in(),
      .clock_out(clk),// 25 MHz, 0 deg
      .locked(lock)
   );
	
	   reg sw_dl1, sw_dl2;
   always @(posedge clk) 
   begin
      sw_dl1 <= sw[15];
      sw_dl2 <= sw_dl1;
      if(sw_dl2 && !sw[15]) begin
         reset_cnt <= 0;
      end else begin
         reset_cnt <= reset_cnt + !resetn;
      end
    end 
   
   wire btnC_out;
    debounce debBtnC (
        .clk    (clk),
        .in     (btnC),
        .out    (btnC_out)
    );
    wire btnL_out;
    debounce debBtnL (
        .clk    (clk),
        .in     (btnL),
        .out    (btnL_out)
    );
    wire btnR_out;
    debounce debBtnR (
        .clk    (clk),
        .in     (btnR),
        .out    (btnR_out)
    );
    wire btnD_out;
    debounce debBtnD (
        .clk    (clk),
        .in     (btnD),
        .out    (btnD_out)
    );
    wire btnU_out;
    debounce debBtnU (
        .clk    (clk),
        .in     (btnU),
        .out    (btnU_out)
    );
    ///////////////////////////////////
    // Peripheral Bus
    ///////////////////////////////////   
   wire        iomem_valid;
   wire        iomem_ready;
   wire [ 3:0] iomem_wstrb;
   wire [31:0] iomem_addr;
   wire [31:0] iomem_wdata;
   wire [31:0] iomem_rdata;

   reg  [31:0] gpio;
   wire [4:0]  debug_pins_char_gen;
   reg  [31:0] gpio_iomem_rdata;
   reg      gpio_iomem_ready;
   wire     vga_iomem_ready;
   

   wire[4:0] buttons;
   assign buttons = { btnC_out, btnD_out, btnL_out, btnR_out, btnU_out};

   
    // enable signals for each of the peripherals
    wire gpio_en    = (iomem_addr[31:24] == 8'h03); /* GPIO mapped to 0x03xx_xxxx */
    wire video_en   = (iomem_addr[31:24] == 8'h05); /* Video device mapped to 0x05xx_xxxx */
   
   assign led[5:0] = leds[5:0];
   //assign led[10:6] = buttons;
   assign led[11] = w_video_on;  
   assign led[12] = allow_next;
   assign led[13] = ram_wen;
   assign led[14] = r_CLK_1HZ;   
   assign led[15] = sw[15];   

   assign iomem_ready = gpio_en ? gpio_iomem_ready : ( video_en ? vga_iomem_ready : 1'b0);      
   assign iomem_rdata = gpio_en ? gpio_iomem_rdata : 32'h00000000;   
   

   always @(posedge clk) 
   begin
      if (!resetn) begin
         gpio <= 0;
      end else begin
         gpio_iomem_ready <= 0;
         if (iomem_valid && !iomem_ready && gpio_en) begin
            gpio_iomem_ready <= 1;
            gpio_iomem_rdata <= {8'h00, 1'b0, 1'b0, 1'b0, buttons[4:0], gpio[15:0]};
            if (iomem_wstrb[0]) gpio[7:0] <= iomem_wdata[7:0];
            if (iomem_wstrb[1]) gpio[15:8] <= iomem_wdata[15:8];
            if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
            if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];               
         end
      end
   end
   
   wire tx_uc, rx_uc, tx_prog, rx_prog;
   
   assign tx = sw[15] ? tx_prog : tx_uc;  
   assign rx_uc = sw[15] ? 1'bz : rx;
   assign rx_prog = sw[15] ? rx : 1'bz;
   
   // uC Circuit     
   picosoc_noflash soc (
      .clk  (clk),    
      .resetn  (resetn),

      .ser_tx  (tx_uc),
      .ser_rx  (rx_uc),

      .irq_5   (1'b0),
      .irq_6   (1'b0),
      .irq_7   (1'b0),

      .iomem_valid(iomem_valid),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr (iomem_addr),
      .iomem_wdata(iomem_wdata),
      .iomem_rdata(iomem_rdata),
      
      .progmem_wen   (progmem_wen),
      .progmem_waddr (ram_addr),
      .progmem_wdata (ram_data)     
   ); 
   
    // VGA Controller
    vga_controller vga(
      .clk(clk), 
      .reset(!resetn),     
      .hsync(hsync), 
      .vsync(vsync),
      .video_on(w_video_on), 
      .p_tick(w_p_tick), 
      .x(w_x), 
      .y(w_y)
   );

    // VGA Wrapper
    vga_wrapper at(
      .clk(clk),
      .reset(!resetn),     
      .vga_iomem_ready(vga_iomem_ready),
      
      .iomem_valid(iomem_valid && video_en),
      .iomem_ready(iomem_ready),
      .iomem_wstrb(iomem_wstrb),
      .iomem_addr(iomem_addr),
      .iomem_wdata(iomem_wdata),

      .video_on(w_video_on), 
      .x(w_x), 
      .y(w_y), 
      .rgb(rgb_next),
      
      .o_debug_pins(debug_pins_char_gen)
   );
   
    // RGB buffer
   always @(posedge clk)
   begin
        //if(w_p_tick)
            rgb_reg <= rgb_next;
   end
   
   // output
   assign rgb = rgb_reg;


   wire I_write = (command==C_REGISTER_WR);
   wire I_read  = (command==C_REGISTER_RD);

   initial begin
      counter = 0;

      flush_ctrl = 0;
      tx_enable_ctrl = 0;
      allow_next = 0;   
      out_data = 0;
      checksum = 0;
      display_data = 0;
      command = 0;
      data_length = 0;
      data_cnt = 0;
      progmem_wen = 0;
      ram_wen = 0;
      ram_addr = 32'hFFFFFFFF;
      ram_data = 32'd0;
   end
   
   reg progmem_wen;
   
    // Constants (parameters) to create the frequencies needed:
    // Input clock is 100.0 MHz, system clock.
    // Formula is: (100000 KHz / 1 Hz) * 50% duty cycle    
    // So for 1/2 Hz: (100000000 / 1) * 0.5 = 50000000, Input clock is generated 100MHz        
    parameter c_CNT_CLK_HZ = 50000000;        
    // These signals will be the counters:        
    reg [31:0] r_CNT_CLK_HZ = 0;       
    // These signals will toggle at the frequencies needed:          
    reg r_CLK_1HZ       = 1'b0;        
    always @(posedge clk)  
    begin        
        if (r_CNT_CLK_HZ == c_CNT_CLK_HZ-1) begin// -1, since counter starts at 0                
            r_CLK_1HZ <= !r_CLK_1HZ;
            r_CNT_CLK_HZ <= 0;
        end else
            r_CNT_CLK_HZ <= r_CNT_CLK_HZ + 1;            
    end                                         
    //------------------------------------------------------------------------------    
      
endmodule
