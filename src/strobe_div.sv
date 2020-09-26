`default_nettype none

module strobe_div #(
    parameter DIV /*verilator public*/ = 10
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

`ifdef FORMAL
  // Create flag for t<0.
  logic f_past_valid;
  initial f_past_valid = 0;
  always_ff @(posedge i_clk)
    f_past_valid <= 1;

  // Assume module in reset for t<0.
  initial assume(i_reset);
  always_comb
    if (!f_past_valid)
      assume(i_reset);

  // Ensure strobe is set when counter is at maximum.
  always_comb
    if (counter == WIDTH'(DIV - 1))
      assert(o_strobe == 1);
    else
      assert(o_strobe == 0);

  // Ensure counter is always incrementing and resets correctly.
  always_ff @(posedge i_clk)
    if (!f_past_valid);
    else if ($past(counter) == WIDTH'(DIV - 1) || $past(i_reset))
      assert(counter == 0);
    else
      assert(counter == $past(counter) + 1);
`endif
endmodule
