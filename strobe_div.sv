`default_nettype none

module strobe_div #(
    int DIV /*verilator public*/ = 2
) (
    input wire i_clk,
    output logic o_strobe
);

  if (DIV < 1) begin : param_check
    $error("DIV < 1: %d", DIV);
  end

  generate
    if (DIV == 1) begin : div1
      // verilator lint_off UNUSED
      wire unused = i_clk;
      // verilator lint_on UNUSED
      assign o_strobe = 1'b1;

    end else begin : divn  // DIV >= 2.
      localparam int WIDTH = $clog2(DIV);
      logic [WIDTH - 1:0] counter;

      initial begin
        counter = 0;
      end

      always_ff @(posedge i_clk) begin
        if (counter == WIDTH'(DIV - 1)) begin
          counter <= 0;
        end else begin
          counter <= counter + 1;
        end
      end

      assign o_strobe = counter == WIDTH'(DIV - 1);
    end
  endgenerate
endmodule
