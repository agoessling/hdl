//#include <cstdlib>
//#include <iostream>
//#include <optional>

//#include "gtest/gtest.h"
//#include "structopt/app.hpp"
//
//struct Options {
//  std::optional<std::string> directory;
//};
//STRUCTOPT(Options, directory);
//
//int main(int argc, char *argv[]) {
////  ::testing::InitGoogleTest(&argc, argv);
//
//  try {
//    auto options = structopt::app("module_test").parse<Options>(argc, argv);
//
//    std::cout << options.directory.value_or("None") << std::endl;
//  } catch (structopt::exception &e) {
//    std::cout << e.what() << std::endl;
//    std::cout << e.help();
//    return EXIT_FAILURE;
//  }
//
//  return EXIT_SUCCESS;
//}
#include "argparse/argparse.hpp"
#include "structopt/app.hpp"

struct Options {
  std::string input_file;
  std::string output_file;
};
STRUCTOPT(Options, input_file, output_file);



int main(int argc, char *argv[]) {
  try {
    auto options = structopt::app("module_test").parse<Options>(argc, argv);
  } catch (structopt::exception& e) {
    std::cout << e.what() << "\n";
    std::cout << e.help();
  }
}
