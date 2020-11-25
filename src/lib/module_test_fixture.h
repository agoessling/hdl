#pragma once

#include <filesystem>

#include "gtest/gtest.h"
#include "module_test_bench.h"

extern const char *g_trace_directory;

template<class MODULE> class ModuleTest : public ::testing::Test {
 protected:
  TestBench<MODULE> tb_;

  ModuleTest() {
    if (g_trace_directory) {
      // Prepare directory path.
      std::filesystem::path path(g_trace_directory);

      // Append filename based on test name.
      const ::testing::TestInfo * const test_info =
          ::testing::UnitTest::GetInstance()->current_test_info();

      path.append(test_info->name());
      path.concat(".vcd");

      tb_.OpenTrace(path.string());
    }
  }

  ~ModuleTest() override {
    tb_.CloseTrace();
  }
};
