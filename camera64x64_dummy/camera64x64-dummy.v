
`timescale 1ps / 1ps

module camera64x64_dummy (
  input   wire  CLK,   // Clock, 100MHz
  input   wire  RST,   // Reset
  input   wire  SCLK,  // SPI Clock
  output  reg   INT,   // Interrupt Signal
  output  reg   LOOKUP // Lookup Signal
);

  wire s_rxrdy;
  wire s_rxrdy_pulse_pos;
  wire s_rxrdy_pulse_neg;
  wire s_counter_done;

  //============================================================
  // swap by IP Core
  //============================================================
  spi_detector u_spi_detector (
    CLK    ( CLK               ) ,
    SCLK   ( SCLK              ) ,
    RXRDY  ( s_rxrdy           )
  );

  //============================================================
  // assert single pulse at the posedge of RXRDY
  //============================================================
  pulse_gen u_pulse_gen_at_posedge (
    CLK    ( CLK               ) ,
    IN     ( s_rxrdy           ) ,
    OUT    ( s_rxrdy_pulse_pos )
  );

  //============================================================
  // assert single pulse at the negedge of RXRDY
  //============================================================
  pulse_gen u_pulse_gen_at_negedge (
    CLK    ( CLK               ) ,
    IN     ( ~s_rxrdy          ) ,
    OUT    ( s_rxrdy_pulse_neg )
  );

  //============================================================
  // Assert interrupt signal 1ms after the posedge of LOOKUP.
  // 1ms / 10ns = 10^5 = 0x000186A0
  //============================================================
  nbit_counter #(
    BIT    ( 32                ) ,
    MAX    ( 32'h000186A0      )
  ) nbit_counter (
    CLK    ( CLK               ) ,
    RST    ( RST               ) ,
    TRIG   ( s_rxrdy_pulse_pos ) ,
    DONE   ( s_counter_done    ) ,
    COUNT  (                   )
  );

  //============================================================
  //
  //============================================================
  always (posedge CLK and negedge RST) begin
    if (RST)
      LOOKUP <= 1'b0;
    else if (s_rxrdy_pulse_pos)
      LOOKUP <= 1'b1;
    else if (s_rxrdy_pulse_neg)
      LOOKUP <= 1'b0;
    else
      LOOKUP <= LOOKUP;
  end

  //============================================================
  //
  //============================================================
  always (posedge CLK or negedge RST) begin
    if (RST)
      INT <= 1'b0;
    else if (s_counter_done)
      INT <= 1'b1;
    else if (s_rxrdy_pulse_neg)
      INT <= 1'b0;
    else
      INT <= INT;
  end

endmodule

