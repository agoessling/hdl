`default_nettype none

module uart_tx #(
    parameter BAUD_DIV /*verilator public*/ = int'(1e8 / 9600),
    parameter DATA_BITS /*verilator public*/ = 8
) (
    input logic i_clk,
    input logic i_reset,
    input logic [DATA_BITS - 1:0] i_data,
    input logic i_start,
    output logic o_busy,
    output logic o_tx
);

  logic baud_strobe;
  logic strobe_reset;
  strobe_div #(.DIV(BAUD_DIV)) strobe_div (
      .i_clk,
      .i_reset(strobe_reset),
      .o_strobe(baud_strobe)
  );

  localparam BITS = DATA_BITS + 2;
  logic [BITS - 1:0] shift_reg;  // One start and stop bit.

  enum logic [$clog2(BITS + 1) - 1:0] {  // One more state than bits.
    IDLE = 0,
    START_BIT = 1,
    STOP_BIT = BITS
  } state;

  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      state <= IDLE;
    end else if (state == IDLE && i_start) begin
      state <= START_BIT;
      shift_reg <= {1'b1, i_data, 1'b0};
    end else if (baud_strobe) begin
      shift_reg <= {1'b1, shift_reg[BITS - 1: 1]};

      if (state == STOP_BIT) begin
        state <= IDLE;
      end else begin
        state <= state + 1;
      end
    end
  end

  always_comb begin
    strobe_reset = state == IDLE;
    o_busy = state != IDLE;

    o_tx = shift_reg[0];
    if (state == IDLE) begin
      o_tx = 1'b1;
    end
  end

  initial begin
    state = IDLE;
  end
endmodule
