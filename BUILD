load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")
load("//:verilator_cc_test.bzl", "verilator_cc_test")

verilator_cc_test(
    name = "strobe_div",
    vsrcs = ["strobe_div.sv"],
    csrcs = ["test_strobe_div.cpp"],
    params = {
        "DIV": [2, 6, 7, 8, 100],
    },
)

cc_library(
    name = "test_bench",
    hdrs = ["test_bench.h"],
)
