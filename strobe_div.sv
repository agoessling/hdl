`default_nettype none

module strobe_div #(
    parameter DIV /*verilator public*/ = 2
) (
    input logic i_clk,
    input logic i_reset,
    output logic o_strobe
);

  // Bounds check DIV.
  if (DIV < 2) begin : param_check
    $error("DIV < 2: %d", DIV);
  end

  // Calculate size of counter based on divider.
  localparam WIDTH = $clog2(DIV);
  logic [WIDTH - 1:0] counter;
  initial counter = 0;

  always_ff @(posedge i_clk) begin
    if (counter == WIDTH'(DIV - 1) || i_reset) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  assign o_strobe = counter == WIDTH'(DIV - 1);
endmodule
