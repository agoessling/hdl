#include "gtest/gtest.h"
#include "Vstrobe_div.h"
#include "Vstrobe_div_strobe_div.h"
#include "module_test_fixture.h"

class StrobeDivTest : public ModuleTest<Vstrobe_div> {
 protected:
  int32_t div_;
  int32_t reset_val_;

  StrobeDivTest() {
    div_ = tb_.module_.strobe_div->DIV;
    reset_val_ = tb_.module_.strobe_div->RESET_VAL;
  }
};

TEST_F(StrobeDivTest, InitiallyZero) {
  int32_t reset_value;
  if (reset_val_ == div_ - 1) {
    reset_value = 1;
  } else {
    reset_value = 0;
  }

  EXPECT_EQ(tb_.module_.o_strobe, reset_value) << "Incorrect reset value.";
}

TEST_F(StrobeDivTest, StrobeSequence) {
  // Check reset halfway through count.
  for (int32_t i = 0; i < div_ / 2; ++i) {
    tb_.tick();
  }

  tb_.module_.i_reset = 1;
  tb_.tick();
  tb_.module_.i_reset = 0;

  for (int32_t i = reset_val_; i < 3 * div_ + reset_val_; ++i) {
    int32_t strobe = i % div_ == div_ - 1 ? 1 : 0;
    ASSERT_EQ(tb_.module_.o_strobe, strobe) << "Timestep: " << i;

    tb_.tick();
  }
}
