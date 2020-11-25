load("@rules_symbiyosys//symbiyosys:defs.bzl", "symbiyosys_test", "symbiyosys_trace")
load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")
load("@rules_verilog//verilog:defs.bzl", "verilog_module")

load("//tools:verilator_cc_test.bzl", "verilator_cc_test")

cc_library(
    name = "test_bench",
    hdrs = ["test_bench.h"],
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "module_test",
    srcs = ["module_test.cpp"],
    deps = [
        "@structopt//:structopt",
	"@argparse//:argparse",
        "@gtest//:gtest",
    ],
)

verilog_module(
    name = "uart_tx_module",
    top = "uart_tx",
    srcs = ["uart_tx.sv"],
    deps = [":strobe_div_module"],
    visibility = ["//visibility:public"],
)

verilator_cc_test(
    name = "uart_tx",
    module = ":uart_tx_module",
    csrcs = ["test_uart_tx.cpp"],
    params = {
        "BAUD_DIV": [3],
    },
)

symbiyosys_test(
    name = "prove_uart_tx",
    module = ":uart_tx_module",
    modes = ["prove", "cover"],
    engine = "smtbmc",
    depth = 33,
)

symbiyosys_trace(
    name = "prove_uart_tx_trace",
    test = ":prove_uart_tx",
    testonly = True,
)

verilog_module(
    name = "strobe_div_module",
    top = "strobe_div",
    srcs = ["strobe_div.sv"],
    visibility = ["//visibility:public"],
)

verilator_cc_test(
    name = "strobe_div",
    module = ":strobe_div_module",
    csrcs = ["test_strobe_div.cpp"],
    params = {
        "DIV": [2, 6, 7, 8, 100],
    },
)

symbiyosys_test(
    name = "prove_strobe_div",
    module = ":strobe_div_module",
    modes = ["prove", "cover"],
    engine = "smtbmc",
)

symbiyosys_trace(
    name = "prove_strobe_div_trace",
    test = ":prove_strobe_div",
    testonly = True,
)
