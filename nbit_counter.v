module nbit_counter #(
  parameter             BIT = 8 
) (
  input  wire           CLK   ,
  input  wire           NRST  ,
  output reg  [BIT-1:0] COUNT
) ;

  always @(posedge CLK or negedge NRST) begin
    if (!NRST) begin
      COUNT[BIT-1:0] <= {BIT{1'b0}};
    end else begin
      COUNT[BIT-1:0] <= COUNT[BIT-1:0] + 1'b1;
    end
  end

endmodule
