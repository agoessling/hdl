#pragma once

#include <optional>
#include <string>

#include "verilated.h"
#include "verilated_vcd_c.h"

template<class MODULE> class TestBench {
  public:
    MODULE module_;

  protected:
    unsigned int tick_count_;

  private:
    VerilatedVcdC trace_;
    std::optional<int> max_counts_;

  public:
    TestBench(std::optional<int> max_counts = std::nullopt)
        : tick_count_(0), max_counts_(max_counts) {
      Verilated::traceEverOn(true);
      // Evaluate so initial values are correct.
      module_.eval();
    }
    virtual ~TestBench(void) {}

    void OpenTrace(const std::string &filename) {
      if (!trace_.isOpen()) {
        module_.trace(&trace_, 99);
        trace_.open(filename.c_str());
      }
    }

    void CloseTrace(void) {
      if (trace_.isOpen()) {
        trace_.close();
      }
    }

    virtual void tick(void) {
      tick_count_++;

      // Allow combinatorial logic to settle.
      module_.i_clk = 0;
      module_.eval();

      if (trace_.isOpen()) {
        trace_.dump(10 * tick_count_ - 2);
      }

      // Rising edge.
      module_.i_clk = 1;
      module_.eval();

      if (trace_.isOpen()) {
        trace_.dump(10 * tick_count_);
      }

      // Falling edge.
      module_.i_clk = 0;
      module_.eval();

      if (trace_.isOpen()) {
        trace_.dump(10 * tick_count_ + 5);
      }
    }

    virtual bool done(void) {
      return (max_counts_ && tick_count_ > max_counts_);
    }
};
