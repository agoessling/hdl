#include <unistd.h>

#include <iostream>
#include <optional>
#include <string>

#include "verilated.h"
#include "gtest/gtest.h"
#include "Vhello.h"
#include "Vhello_hello.h"
#include "src/lib/test_bench.h"

std::string g_vcd_path;

class HelloTest : public ::testing::Test {
 protected:
  TestBench<Vhello> tb_;

  HelloTest() {
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

  ~HelloTest() override {
    tb_.CloseTrace();
  }
};

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
