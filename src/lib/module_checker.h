#pragma once

#include <string>
#include <unordered_map>
#include <utility>

#include "verilated.h"

class ModuleChecker {
 private:
  std::unordered_map<void *, int> signals_;
 public:
  ModuleChecker(void) {}
  ~ModuleChecker(void) {}
  void Register(CData &data, int val);
  void Get(CData &data);
  std::pair<bool, std::string> Check(void);
};
