
`timescale 1ps / 1ps

module sim_top();
  reg        CLK;
  reg        RST;
  reg        SCLK;

  //============================================================
  // System Task
  //============================================================
  initial begin
    #100000000 $finish();
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
    forever #41680 CLK = ~CLK; // 12MHz
  end

  initial begin
    RST = 1;
    #100000 RST = 0;
  end

  initial begin
    SCLK = 0;
    forever begin
      #9000000
      repeat(50) #62500 SCLK = ~SCLK; // 8MHz
      SCLK = 0;
    end
  end

  camera64x64_dummy u_camera64x64_dummy (
    .CLK    ( CLK  ) ,
    .RST    ( RST  ) ,
    .SCLK   ( SCLK )
  );

endmodule
