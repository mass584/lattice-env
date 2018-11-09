`timescale 1ps / 1ps

module sim_top();
  reg        CLK;
  reg        RST;
  reg        SCLK;

  //============================================================
  // System Task
  //============================================================
  initial begin
    #100000 $finish();
  end

  initial begin
    $dumpfile("sim_top.vcd");
    $dumpvars(0, u_camera64x64_dummy);
  end

  //============================================================
  //
  //============================================================
  initial begin
    CLK = 0;
    forever #10 CLK = ~CLK;
  end

  initial begin
    RST = 1;
    #30 RST = 0;
  end

  initial begin
    SCLK = 0;
    forever begin
      #20000 repeat(100) #100 SCLK = ~SCLK;
      SCLK = 0;
    end
  end

  camera64x64_dummy u_camera64x64_dummy (
    .CLK    ( CLK  ) ,
    .RST    ( RST  ) ,
    .SCLK   ( SCLK )
  );

endmodule
