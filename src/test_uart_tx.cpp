#include <unistd.h>

#include <iostream>
#include <optional>
#include <string>

#include "verilated.h"
#include "gtest/gtest.h"
#include "Vuart_tx.h"
#include "Vuart_tx_uart_tx.h"
#include "test_bench.h"

std::string g_vcd_path;

class UartTxTest : public ::testing::Test {
 protected:
  TestBench<Vuart_tx> tb_;
  int32_t baud_div_;
  int32_t num_bits_;

  UartTxTest() {
    baud_div_ = tb_.module_.uart_tx->BAUD_DIV;
    num_bits_ = tb_.module_.uart_tx->DATA_BITS + 2;

    if (!g_vcd_path.empty()) {
      // Prepare directory path.
      std::string filename(g_vcd_path);
      if (filename.back() != '/') {
        filename += "/";
      }

      // Append filename based on test name.
      const ::testing::TestInfo * const test_info =
          ::testing::UnitTest::GetInstance()->current_test_info();
      filename += test_info->name();
      filename += ".vcd";

      tb_.OpenTrace(filename);
    }
  }

  ~UartTxTest() override {
    tb_.CloseTrace();
  }

  void SendByte(uint8_t byte, std::optional<int32_t> cycles = std::nullopt) {
    tb_.module_.i_data = byte;
    tb_.module_.i_start = 1;
    tb_.tick();
    tb_.module_.i_start = 0;

    uint32_t shift = byte;
    shift |= 1 << (num_bits_ - 2);  // Stop bit.
    shift = shift << 1;  // Start bit.

    int32_t cycle_count = 0;
    for (int32_t bit = 0; bit < num_bits_; ++bit) {
      for (int32_t div = 0; div < baud_div_; ++div) {
        EXPECT_EQ(tb_.module_.o_tx, (shift >> bit) & 0x01) << "TX value incorrect.";
        EXPECT_EQ(tb_.module_.o_busy, 1) << "Busy not set during transmission.";

        tb_.tick();
        cycle_count++;

        if (cycles && cycle_count >= cycles) {
          return;
        }
      }
    }

    EXPECT_EQ(tb_.module_.o_tx, 1) << "TX didn't reset to high after transmision.";
    EXPECT_EQ(tb_.module_.o_busy, 0) << "Busy didn't reset to low after transmission.";
  }

  void CheckReset(void) {
    EXPECT_EQ(tb_.module_.o_busy, 0) << "Busy is set on reset.";
    EXPECT_EQ(tb_.module_.o_tx, 1) << "Tx is low on reset.";
  }
};

TEST_F(UartTxTest, ResetAndNoOp) {
  for (int32_t i = 0; i < 12 * baud_div_; ++i) {
    CheckReset();
    tb_.tick();
  }
}

TEST_F(UartTxTest, SendByte) {
  // Delay half of a frame to simulate asynchronous start.
  tb_.tick(baud_div_ * num_bits_ / 3);
  SendByte(0xDE);
  SendByte(0xAD);
  SendByte(0xBE);
  SendByte(0xEF);
}

TEST_F(UartTxTest, ResetDuringSend) {
  SendByte(0x00, baud_div_ * 3 + baud_div_ / 2);

  tb_.module_.i_reset = 1;
  tb_.tick();
  tb_.module_.i_reset = 0;

  CheckReset();

  SendByte(0xAA);
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  Verilated::commandArgs(argc, argv);

  int c;
  while ((c = getopt(argc, argv, "d:")) != -1) {
    switch (c) {
      case 'd':
        g_vcd_path.assign(optarg);
        printf("Got file name: %s\n", optarg);
        break;
      case '?':
        fprintf(stderr, "Unknown option '-%c'.\n", optopt);
        abort();
      default:
        fprintf(stderr, "Unhandled option '-%c'.\n", c);
        abort();
    }
  }

  return RUN_ALL_TESTS();
}
