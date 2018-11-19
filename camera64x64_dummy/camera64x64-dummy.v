
`timescale 1ps / 1ps

module camera64x64_dummy (
  input   wire  CLK,    // Clock
  input   wire  RST,    // Reset
  input   wire  SCLK,   // SPI Clock
  output  wire  LED_R,  // Interrupt
  output  wire  LED_G,  // Lookup
  output  wire  LED_B,  // Spi Detect
  output  reg   INT,    // Interrupt Signal
  output  reg   LOOKUP  // Lookup Signal
);

  wire s_spidetect;
  wire s_spidetect_pulse_pos;
  wire s_spidetect_pulse_neg;
  wire s_counter_done;

  wire s_clk;

  reg       r_lookup_next;
  reg [7:0] r_pll_rst;

  //============================================================
  // PLL Reset (Shift Register)
  //============================================================
  always @(posedge CLK) begin
    r_pll_rst[7:0] <= {r_pll_rst[6:0], 1'b1};
  end

  //============================================================
  // PLL
  //============================================================
`ifdef D_SIM
  assign s_clk = CLK;
`else
  PLL12M u_PLL12M (
    .ref_clk_i   ( CLK                   ) , // 12MHz
    .rst_n_i     ( ~r_pll_rst[7]         ) ,
    .outcore_o   ( s_clk                 ) , // 240MHz
    .outglobal_o (                       )
  );
`endif

  //============================================================
  // swap by IP Core
  //============================================================
  spi_detector #(
    .FREQ   ( 8'h3f                 )
  ) u_spi_detector (
    .CLK    ( s_clk                 ) ,
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
    .CLK    ( s_clk                 ) ,
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
    .CLK    ( s_clk                 ) ,
    .RST    ( RST                   ) ,
    .IN     ( ~s_spidetect          ) ,
    .OUT    ( s_spidetect_pulse_neg )
  );

  //============================================================
  // Assert interrupt signal 1ms after the posedge of LOOKUP.
  //  1ms / 4.167ns = 239980 = 0x0003A96C
  // For simulation, delay time is 1us.
  //  1us / 4.167ns = 240 = 0xF0
  //============================================================
  nbit_counter #(
    .BIT    ( 32                    ) ,
`ifdef D_SIM
    .MAX    ( 32'h000000F0          )
`else
    .MAX    ( 32'h0003A96C          )
`endif
  ) nbit_counter (
    .CLK    ( s_clk                 ) ,
    .RST    ( RST                   ) ,
    .TRIG   ( s_spidetect_pulse_neg ) ,
    .DONE   ( s_counter_done        ) ,
    .COUNT  (                       )
  );

  //============================================================
  //
  //============================================================
  always @(posedge s_clk or posedge RST) begin
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
  always @(posedge s_clk or posedge RST) begin
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
  assign LED_R = ~INT;
  assign LED_G = ~LOOKUP;
  assign LED_B = ~s_spidetect;

endmodule

