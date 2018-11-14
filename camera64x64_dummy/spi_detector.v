
`timescale 1ps / 1ps

module spi_detector (
  input   wire  CLK , // 100MHz
  input   wire  RST , //  10MHz
  input   wire  SCLK ,
  output  wire  DETECT
) ;

  reg [3:0] r_timer;
  reg [7:0] r_counter;
  reg [7:0] r_capture0;
  reg [7:0] r_capture1;

  //============================================================
  // spi clock freerun counter
  //============================================================
  always @(posedge SCLK or posedge RST) begin
    if (RST)
      r_counter <= 8'b0;
    else
      r_counter <= r_counter + 8'b1;
  end

  //============================================================
  // clock freerun counter
  //============================================================
  always @(posedge CLK or posedge RST) begin
    if (RST)
      r_timer <= 0;
    else
      r_timer <= r_timer + 4'b1;
  end

  //============================================================
  //
  //============================================================
  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      r_capture0 <= 0;
      r_capture1 <= 0;
    end else if (r_timer==4'hf) begin
      r_capture0 <= r_counter; // this bus signal must be synchronized by CLK !!!
      r_capture1 <= r_capture0;
    end
  end

  assign DETECT = (r_capture0 != r_capture1) ;

endmodule

