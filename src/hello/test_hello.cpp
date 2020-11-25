#include "gtest/gtest.h"
#include "Vhello.h"
#include "Vhello_hello.h"
#include "src/lib/module_test_fixture.h"

class HelloTest : public ModuleTest<Vhello> {};

TEST_F(HelloTest, SendMessage) {
  int32_t seen_start = 0;
  int32_t last_tx_start = tb_.module_.hello->tx_start;
  int32_t max_cycles = 10000;
  int32_t cycles = 0;
  while (cycles++ < max_cycles) {
    tb_.tick();
    if (tb_.module_.hello->tx_start == 1) {
      if (last_tx_start == 0) {
        seen_start++;
      }
    } else if (seen_start >= 2) {
      break;
    }
    last_tx_start = tb_.module_.hello->tx_start;
  }
}
