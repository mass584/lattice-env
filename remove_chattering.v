
//========================================================
// チャタリングノイズを取り除くモジュール
//  CLK_EN_PERIOD : Clock Enable信号を出力する周期を表す。
//                  チャタリングの継続時間(数msから数十ms)
//                  よりも長くしておく必要がある
//  INITIAL_STATE : Power On Reset解除時のSIG_Iの状態(HorL)
//                  を指定する
//========================================================
module remove_chattering #(
  parameter CLK_EN_PERIOD = 32'hffffffff,
  parameter INITIAL_STATE = 1'b0
) (
  input  wire XRST,
  input  wire CLK_O,
  input  wire SIG_I,
  output  reg SIG_O_NEG,
  output  reg SIG_O_POS
); 

  wire clk_en;
  reg  clk_cnt[31:0];
  reg  ff0;
  reg  ff1;
 
  // 長周期のパルスを作成する
  always @(posedge CLK_O or negedge XRST) begin
    if (~XRST) begin
      clk_cnt[31:0] <= 32'b0;
    end else if (clk_cnt[31:0]==CLK_EN_PERIOD) begin
      clk_cnt[31:0] <= 32'b0;
    end else begin
      clk_cnt[31:0] <= clk_cnt[31:0] + 32'b1;
    end
  end
  wire clk_en = (clk_cnt[31:0]==CLK_EN_PERIOD);

  // clk_enでラッチ
  always @(posedge CLK_O or negedge XRST) begin
    if (~XRST) begin
      ff0 <= INITIAL_STATE;
      ff1 <= INITIAL_STATE;
    end else if (clk_en) begin
      ff0 <= SIG_I;
      ff1 <= ff0;
    end else begin
      ff0 <= ff0;
      ff1 <= ff1;
    end
  end

  // negedge/posedgeを出力する回路
  always @(posedge CLK_O or negedge XRST) begin
    if (~XRST) begin
      SIG_O_NEG <= 1'b0;
      SIG_O_POS <= 1'b0;
    end else if (clk_en) begin
      SIG_O_NEG <= ~ff0 & ff1;
      SIG_O_POS <= ff0 & ~ff1;
    end else begin
      SIG_O_NEG <= 1'b0;
      SIG_O_POS <= 1'b0;
    end

endmodule
