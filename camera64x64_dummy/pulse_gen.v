
`timescale 1ps / 1ps

module pulse_gen (
  input   wire  CLK,
  input   wire  RST,
  input   wire  IN,
  output  wire  OUT
);

  reg r_ff0;
  reg r_ff1;

  always @(posedge CLK or posedge RST)
    if (RST) begin
      r_ff0 <= 1'b0;
      r_ff1 <= 1'b0;
    end else begin
      r_ff0 <= IN;
      r_ff1 <= r_ff0;
    end
  end

  assign OUT = r_ff0 & ~r_ff1;

endmodule
