load("@rules_symbiyosys//symbiyosys:defs.bzl", "symbiyosys_test", "symbiyosys_trace")
load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")
load("@rules_verilog//verilog:defs.bzl", "verilog_module")

load("//tools:verilator_cc_test.bzl", "verilator_cc_test")

cc_library(
    name = "module_test_bench",
    hdrs = ["module_test_bench.h"],
    deps = ["@verilator_v4.104//:libverilator"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "module_test_fixture",
    srcs = ["module_test_fixture.cpp"],
    hdrs = ["module_test_fixture.h"],
    deps = [
        ":module_test_bench",
        "@gtest//:gtest",
    ],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "module_checker",
    srcs = ["module_checker.cpp"],
    hdrs = ["module_checker.h"],
    deps = ["@verilator_v4.104//:libverilator"],
    visibility = ["//visibility:public"],
)

cc_library(
    name = "module_test_main",
    srcs = ["module_test_main.cpp"],
    deps = [
        ":module_test_fixture",
	"@argparse//:argparse",
        "@gtest//:gtest",
    ],
    visibility = ["//visibility:public"],
)

verilog_module(
    name = "uart_rx_module",
    top = "uart_rx",
    srcs = ["uart_rx.sv"],
    deps = [":strobe_div_module"],
    visibility = ["//visibility:public"],
)

verilator_cc_test(
    name = "uart_rx",
    module = ":uart_rx_module",
    csrcs = ["test_uart_rx.cpp"],
    cdeps = [":module_checker"],
    param_cases = [
        {"BAUD_DIV": 3},
        {"BAUD_DIV": 8},
        {"BAUD_DIV": 29},
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
    param_cases = [
        {"BAUD_DIV": 3},
    ],
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
    param_cases = [
        {"DIV": 2, "RESET_VAL": 0},
        {"DIV": 2, "RESET_VAL": 1},
        {"DIV": 6, "RESET_VAL": 0},
        {"DIV": 6, "RESET_VAL": 3},
        {"DIV": 7, "RESET_VAL": 0},
        {"DIV": 7, "RESET_VAL": 6},
        {"DIV": 8, "RESET_VAL": 0},
        {"DIV": 8, "RESET_VAL": 4},
        {"DIV": 100, "RESET_VAL": 0},
        {"DIV": 100, "RESET_VAL": 73},
    ],
)

symbiyosys_test(
    name = "prove_strobe_div_DIV10_RESET_VAL0",
    module = ":strobe_div_module",
    modes = ["prove", "cover"],
    engine = "smtbmc",
    params = {
        "DIV": "10",
        "RESET_VAL": "0",
    },
)

symbiyosys_test(
    name = "prove_strobe_div_DIV10_RESET_VAL3",
    module = ":strobe_div_module",
    modes = ["prove", "cover"],
    engine = "smtbmc",
    params = {
        "DIV": "10",
        "RESET_VAL": "3",
    },
)

symbiyosys_trace(
    name = "prove_strobe_div_trace_DIV10_RESET_VAL0",
    test = ":prove_strobe_div_DIV10_RESET_VAL0",
    testonly = True,
)

symbiyosys_trace(
    name = "prove_strobe_div_trace_DIV10_RESET_VAL3",
    test = ":prove_strobe_div_DIV10_RESET_VAL3",
    testonly = True,
)
