
`timescale 1ps / 1ps

module camera64x64_dummy (
  input   wire  CLK,    // Clock
  input   wire  RST,    // Reset
  input   wire  SCLK,   // SPI Clock
  output  wire  LED_1,  // Interrupt
  output  wire  LED_2,  // Lookup
  output  wire  LED_3,  // Spi Detect
  output  reg   INT,    // Interrupt Signal
  output  reg   LOOKUP  // Lookup Signal
);

  wire s_spidetect;
  wire s_spidetect_pulse_pos;
  wire s_spidetect_pulse_neg;
  wire s_counter_done;

  reg  r_lookup_next;

  //============================================================
  //
  //============================================================
  spi_detector #(
    .FREQ   ( 8'h8                  )
  ) u_spi_detector (
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
  //  1ms / 83.3ns = 12004 = 0x00002EE4
  // For simulation, delay time is 1us.
  //  1us / 83.3ns = 12 = 0xC
  //============================================================
  nbit_counter #(
    .BIT    ( 32                    ) ,
`ifdef D_SIM
    .MAX    ( 32'h0000000C          )
`else
    .MAX    ( 32'h00002EE4          )
`endif
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
  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      LOOKUP        <= 1'b0;
      r_lookup_next <= 1'b0;
    end else if (s_spidetect_pulse_neg) begin
      LOOKUP        <= r_lookup_next;
      r_lookup_next <= r_lookup_next;
    end else if (s_spidetect_pulse_pos) begin
      LOOKUP        <= 1'b0;
      r_lookup_next <= ~r_lookup_next;
    end else begin
      LOOKUP        <= LOOKUP;
      r_lookup_next <= r_lookup_next;
    end
  end

  //============================================================
  //
  //============================================================
  always @(posedge CLK or posedge RST) begin
    if (RST)
      INT <= 1'b0;
    else if (s_counter_done)
      INT <= 1'b1;
    else if (s_spidetect_pulse_pos)
      INT <= 1'b0;
    else
      INT <= INT;
  end

  //============================================================
  //
  //============================================================
  assign LED_1 = INT;
  assign LED_2 = LOOKUP;
  assign LED_3 = s_spidetect;

endmodule

