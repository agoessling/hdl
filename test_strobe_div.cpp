#include <atomic>
#include <iostream>
#include <string>
#include <thread>

#include "verilated.h"
#include "gtest/gtest.h"

#include "test_bench.h"

#include "Vstrobe_div.h"
#include "Vstrobe_div_strobe_div.h"

TEST(StrobeDivTests, InitiallyZero) {
  TestBench<Vstrobe_div> tb;

  int reset_value;
  if (tb.module_.strobe_div->DIV == 1) {
    reset_value = 1;
  } else {
    reset_value = 0;
  }

  EXPECT_EQ(tb.module_.o_strobe, reset_value) << "Incorrect reset value.";
}

TEST(StrobeDivTests, StrobeSequence) {
  TestBench<Vstrobe_div> tb;

  int div = tb.module_.strobe_div->DIV;

  for (int i = 0; i < 3 * div; ++i) {
    int strobe = i % div == div - 1 ? 1 : 0;
    ASSERT_EQ(tb.module_.o_strobe, strobe) << "Timestep: " << i;

    tb.tick();
  }
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  Verilated::commandArgs(argc, argv);

  return RUN_ALL_TESTS();
}
