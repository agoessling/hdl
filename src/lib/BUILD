load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")
load("//tools:verilator_cc_test.bzl", "verilator_cc_test")
load("//tools:symbiyosys_test.bzl", "symbiyosys_test", "symbiyosys_trace")

verilator_cc_test(
    name = "uart_tx",
    vsrcs = [
        "uart_tx.sv",
        "strobe_div.sv",
    ],
    csrcs = ["test_uart_tx.cpp"],
    params = {
        "BAUD_DIV": [3],
    },
)

symbiyosys_test(
    name = "prove_uart_tx",
    srcs = [
        "uart_tx.sv",
        "strobe_div.sv",
    ],
    top = "uart_tx",
    modes = ["prove", "cover"],
    engine = "smtbmc",
    depth = 33,
)

symbiyosys_trace(
    name = "prove_uart_tx_trace",
    test = ":prove_uart_tx",
    testonly = True,
)

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

symbiyosys_test(
    name = "prove_strobe_div",
    srcs = ["strobe_div.sv"],
    top = "strobe_div",
    modes = ["prove", "cover"],
    engine = "smtbmc",
)

symbiyosys_trace(
    name = "prove_strobe_div_trace",
    test = ":prove_strobe_div",
    testonly = True,
)
