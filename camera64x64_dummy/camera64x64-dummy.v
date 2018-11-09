
`timescale 1ps / 1ps

module camera64x64_dummy (
  input   wire  CLK,   // Clock, 100MHz
  input   wire  RST,   // Reset
  input   wire  SCLK,  // SPI Clock
  output  reg   INT,   // Interrupt Signal
  output  reg   LOOKUP // Lookup Signal
);

  wire s_spidetect;
  wire s_spidetect_pulse_pos;
  wire s_spidetect_pulse_neg;
  wire s_counter_done;

  //============================================================
  // swap by IP Core
  //============================================================
  spi_detector u_spi_detector (
    .CLK    ( CLK                   ) ,
    .RST    ( RST                   ) ,
    .SCLK   ( SCLK                  ) ,
    .DETECT ( s_spidetect           )
  );

  //============================================================
  // assert single pulse at the posedge of spi_detect
  //============================================================
  pulse_gen #(
    .INI    ( 0                     )
  ) u_pulse_gen_at_posedge (
    .CLK    ( CLK                   ) ,
    .RST    ( RST                   ) ,
    .IN     ( s_spidetect           ) ,
    .OUT    ( s_spidetect_pulse_pos )
  );

  //============================================================
  // assert single pulse at the negedge of spi_detect
  //============================================================
  pulse_gen #(
    .INI    ( 1                     )
  ) u_pulse_gen_at_negedge (
    .CLK    ( CLK                   ) ,
    .RST    ( RST                   ) ,
    .IN     ( ~s_spidetect          ) ,
    .OUT    ( s_spidetect_pulse_neg )
  );

  //============================================================
  // Assert interrupt signal 1ms after the posedge of LOOKUP.
  // 1ms / 10ns = 10^5 = 0x000186A0
  // 1us / 10ns = 100 = 0x64
  //============================================================
  nbit_counter #(
    .BIT    ( 32                    ) ,
//`ifdef D_SIM
    .MAX    ( 32'h00000064          )
//`else
//    .MAX    ( 32'h000186A0          )
//`endif
  ) nbit_counter (
    .CLK    ( CLK                   ) ,
    .RST    ( RST                   ) ,
    .TRIG   ( s_spidetect_pulse_neg ) ,
    .DONE   ( s_counter_done        ) ,
    .COUNT  (                       )
  );

  //============================================================
  //
  //============================================================
  always @(posedge CLK or negedge RST) begin
    if (RST)
      LOOKUP <= 1'b0;
    else if (s_spidetect_pulse_neg)
      LOOKUP <= 1'b1;
    else if (s_spidetect_pulse_pos)
      LOOKUP <= 1'b0;
    else
      LOOKUP <= LOOKUP;
  end

  //============================================================
  //
  //============================================================
  always @(posedge CLK or negedge RST) begin
    if (RST)
      INT <= 1'b0;
    else if (s_counter_done)
      INT <= 1'b1;
    else if (s_spidetect_pulse_pos)
      INT <= 1'b0;
    else
      INT <= INT;
  end

endmodule

