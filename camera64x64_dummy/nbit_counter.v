
`timescale 1ps / 1ps

module nbit_counter #(
  parameter             BIT = 8 ,
  parameter             MAX = 8'hFF
) (
  input  wire           CLK ,
  input  wire           RST ,
  input  wire           TRIG ,
  output wire           DONE ,
  output reg  [BIT-1:0] COUNT
) ;

  always @(posedge CLK or posedge RST) begin
    if (RST)
      COUNT <= 0;
    else if (TRIG)
      COUNT <= 1;
    else begin
      if (COUNT[BIT-1:0]==MAX)
        COUNT <= 0;
      else if (COUNT==0)
        COUNT <= COUNT;
      else
        COUNT <= COUNT + 1;
    end
  end

  assign DONE = (COUNT[BIT-1:0]==MAX);

endmodule
