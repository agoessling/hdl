`default_nettype none

module uart_rx #(
    parameter BAUD_DIV /*verilator public*/ = 3,
    parameter DATA_BITS /*verilator public*/ = 8
) (
    input wire logic i_clk,
    input wire logic i_reset,
    input wire logic i_rx,
    output logic [DATA_BITS - 1:0] o_data,
    output logic o_ready_strobe
);

  logic baud_strobe;
  logic strobe_reset;
  // Reset value is set to a half baud so that we can start the strobe on the falling edge of the
  // start bit, but still have a strobe in the middle of the bit half a baud later.
  strobe_div #(.DIV(BAUD_DIV), .RESET_VAL(BAUD_DIV / 2)) strobe_div (
      .i_clk,
      .i_reset(strobe_reset),
      .o_strobe(baud_strobe)
  );

  localparam IDLE = 0;
  localparam START_BIT = 1;
  localparam STOP_BIT = DATA_BITS + 2;

  logic [$clog2(STOP_BIT + 1) - 1:0] state;
  initial state = IDLE;
  always_ff @(posedge i_clk) begin
    if (i_reset) begin
      state <= IDLE;
    end else if (state == IDLE && !i_rx) begin
      state <= START_BIT;
    end else if (baud_strobe) begin
      if (state == STOP_BIT) begin
        state <= IDLE;
      end else begin
        state <= state + 1;
        o_data <= {i_rx, o_data[DATA_BITS - 1:1]};
      end
    end
  end

  // Hold strobe in reset whenever the reciever is idling.
  assign strobe_reset = state == IDLE;

  // Expose shift register on the sample of the stop bit.
  assign o_ready_strobe = (state == STOP_BIT) && baud_strobe;
endmodule
