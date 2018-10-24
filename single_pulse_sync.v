//========================================================
// クロックドメイン交差用のモジュール1
// CLK_Iに同期した1cycleのパルスを,
// CLK_Oの1cycleパルスに載せ替える
//========================================================
module single_pulse_sync #(
  parameter MUL = 10 // SIG_Iのパルス幅を何倍に広げるか指定する
) (
  input  wire XRST,  // negedge active
  input  wire CLK_I, // clock driving SIG_I
  input  wire CLK_O, // clock driving SIG_O
  input  wire SIG_I, // input pulse (1cycle)
  output wire SIG_O  // output pulse (1cycle)
);

  reg  sig_i[MUL-1:0];
  reg  sig_i_expand; 
  reg  sig_i_sync[3:0];

  // パルス幅を広げる  
  always @(posedge CLK_I or negedge XRST) begin
    if (~XRST) begin
      sig_i[MUL-1:0] <= {MUL{1'b0}};
    end else begin
      sig_i[MUL-1:0] <= {sig_i[MUL-2:0], SIG_I};
    end
  end

  // パルス幅を広げたものを一度FFで叩く(重要)
  always @(posedge CLK_I or negedge XRST) begin
    if (~XRST) begin
      sig_i_expand <= 1'b0;
    end else begin
      sig_i_expand <= |sig_i[MUL-1:0];
    end
  end

  // 3段シンクロナイザ+1
  always @(posedge CLK_O or negedge XRST) begin
    if (~XRST) begin
      sig_i_sync_to_o[3:0] <= 4'b0;
    end else begin
      sig_i_sync_to_o[3:0] <= {sig_i_sync_to_o[2:0], sig_i_expand};
    end
  end

  assign SIG_O = ~sig_i_sync_to_o[3] & sig_i_sync_to_o[2] ;

endmodule
