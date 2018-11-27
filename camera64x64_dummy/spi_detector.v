
`timescale 1ps / 1ps

module spi_detector #(
  parameter     FREQ = 12'hfff
) (
  input   wire  CLK ,
  input   wire  RST ,
  input   wire  SCLK ,
  output  wire  DETECT
) ;

  reg [11:0] r_timer;
  reg [ 7:0] r_counter;
  reg [ 7:0] r_capture0;
  reg [ 7:0] r_capture1;

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
  // 
  //============================================================
  always @(posedge CLK or posedge RST) begin
    if (RST)
      r_timer <= 12'b0;
    else if (r_timer==FREQ)
      r_timer <= 12'b0;
    else
      r_timer <= r_timer + 12'b1;
  end

  //============================================================
  //
  //============================================================
  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      r_capture0 <= 8'b0;
      r_capture1 <= 8'b0;
    end else if (r_timer==FREQ) begin
      r_capture0 <= r_counter; // TODO : this bus signal must be synchronized by CLK !!!
      r_capture1 <= r_capture0;
    end
  end

  assign DETECT = (r_capture0 != r_capture1) ;

endmodule

