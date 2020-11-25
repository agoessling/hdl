#include <cstdlib>
#include <optional>

#include "argparse/argparse.hpp"
#include "gtest/gtest.h"
#include "module_test_fixture.h"

int main(int argc, char *argv[]) {
  ::testing::InitGoogleTest(&argc, argv);

  argparse::ArgumentParser program("module_test");

  program.add_argument("-d", "--vcd_dir")
    .help("directory for VCD trace files.");

  try {
    program.parse_args(argc, argv);
  } catch (const std::runtime_error &err) {
    std::cout << err.what() << std::endl;
    std::cout << program;
    return EXIT_FAILURE;
  }

  std::optional<std::string> directory = program.present<std::string>("--vcd_dir");

  if (directory) {
    g_trace_directory = directory.value().c_str();
  }

  return RUN_ALL_TESTS();
}
