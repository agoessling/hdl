#include <optional>

#include "gtest/gtest.h"
#include "Vuart_rx.h"
#include "Vuart_rx_uart_rx.h"
#include "module_checker.h"
#include "module_test_fixture.h"

class UartRxTest : public ModuleTest<Vuart_rx> {
 protected:
  int32_t baud_div_;
  int32_t data_bits_;

  UartRxTest() {
    baud_div_ = tb_.module_.uart_rx->BAUD_DIV;
    data_bits_ = tb_.module_.uart_rx->DATA_BITS;
  }

  void ReceiveByte(uint32_t data, int32_t offset = 0) {
    // Start bit.
    tb_.module_.i_rx = 0;
    tb_.tick(baud_div_ + offset);

    // Data.
    uint32_t shift_reg = data;
    for (int32_t i = 0; i < data_bits_; ++i) {
      tb_.module_.i_rx = shift_reg & 0x01;
      shift_reg = shift_reg >> 1;
      tb_.tick(baud_div_);
    }

    // Stop bit.
    tb_.module_.i_rx = 1;
    tb_.tick(baud_div_ - baud_div_ / 2 - offset);

    EXPECT_EQ(tb_.module_.o_ready_strobe, 1) << "Ready strobe not present.";
    EXPECT_EQ(tb_.module_.o_data, data) << "Received data did not match.";

    tb_.tick(baud_div_ / 2);
  }
};

TEST_F(UartRxTest, ReceiveByteEarly) {
  ModuleChecker checker;
  auto response = checker.Check();
  checker.Register(tb_.module_.o_ready_strobe, 12);
  checker.Get(tb_.module_.o_ready_strobe);
  checker.Register(tb_.module_.o_data, 10);
  checker.Get(tb_.module_.o_data);
  checker.Get(tb_.module_.o_ready_strobe);
  checker.Register(tb_.module_.o_ready_strobe, 11);
  checker.Get(tb_.module_.o_ready_strobe);
  std::cout << response.first << response.second << std::endl;
  ReceiveByte(0x55, 1 - (baud_div_ / 2)); // Early.
}

TEST_F(UartRxTest, ReceiveByteCentered) {
  ReceiveByte(0x55); // Centered.
}

TEST_F(UartRxTest, ReceiveByteLate) {
  ReceiveByte(0x55, baud_div_ / 2); // Late.
}
