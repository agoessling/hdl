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

  program.add_argument("--ignore_failure")
    .default_value(false)
    .implicit_value(true)
    .help("do not return error code on failure.");

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

  int return_code = RUN_ALL_TESTS();

  if (program.get<bool>("--ignore_failure")) {
    return 0;
  }

  return return_code;
}
