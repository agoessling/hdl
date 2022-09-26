#include "src/lib/module_checker.h"

#include <iostream>
#include <string>
#include <utility>

#include "verilated.h"

//class Signal {
// public:
//  virtual bool compare(int64_t value) = 0;
//};
//
//class SignalCData : public Signal {
// private:
//  CData &data_;
// public:
//  SignalCData(CData &data) : data_{data} {}
//  bool compare(int64_t value) {
//    return value == data_;
//  }
//  std::size_t hash(void) const noexcept {
//    std::cout << "In hash()." << std::endl;
//    return reinterpret_cast<std::size_t>(&data_);
//  }
//};

void ModuleChecker::Register(CData &data, int val) {
  signals_[&data] = val;
}

void ModuleChecker::ExpectEq(CData &data, int64_t value) {

}

void ModuleChecker::Get(CData &data) {
  std::cout << signals_[&data] << std::endl;
}

std::pair<bool, std::string> ModuleChecker::Check(void) {
  return std::make_pair(true, "Success");
}
