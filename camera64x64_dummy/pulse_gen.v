
`timescale 1ps / 1ps

module pulse_gen #(
  parameter     INI = 0
) (
  input   wire  CLK,
  input   wire  RST,
  input   wire  IN,
  output  wire  OUT
);

  reg r_ff0;
  reg r_ff1;

  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      r_ff0 <= INI;
      r_ff1 <= INI;
    end else begin
      r_ff0 <= IN;
      r_ff1 <= r_ff0;
    end
  end

  assign OUT = (r_ff0 & ~r_ff1);

endmodule
