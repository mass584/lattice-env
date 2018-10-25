`timescale 1ps / 1ps

module sim_8bit_counter();
  reg        CLK;
  reg        NRST;
  wire [7:0] cnt;

  nbit_counter #(.BIT(8)) u_nbit_counter(CLK, NRST, cnt);

  initial begin
    CLK = 0;
    forever #10 CLK = ~CLK;
  end

  initial begin
    NRST = 0;
    #30 NRST = 1;
  end

  initial begin
    #500 $finish();
  end

  always @(posedge CLK) begin
    $write("[%t] counter: %b\n", $time, cnt);
  end

  initial begin
    $dumpfile("sim_8bit_counter.vcd");
    $dumpvars(0, u_nbit_counter);
  end

endmodule
