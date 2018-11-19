
`timescale 1ps / 1ps

module sim_top();
  reg        CLK;
  reg        RST;
  reg        SCLK;

  //============================================================
  // System Task
  //============================================================
  initial begin
    #30000000 $finish();
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
    forever #2084 CLK = ~CLK; // 240MHz
  end

  initial begin
    RST = 1;
    #10000 RST = 0;
  end

  initial begin
    SCLK = 0;
    forever begin
      #3000000
      repeat(30) #62500 SCLK = ~SCLK; // 8MHz
      SCLK = 0;
    end
  end

  camera64x64_dummy u_camera64x64_dummy (
    .CLK    ( CLK  ) ,
    .RST    ( RST  ) ,
    .SCLK   ( SCLK )
  );

endmodule
