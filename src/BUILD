load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")
load("//tools:verilator_cc_test.bzl", "verilator_cc_test")
load("//tools:symbiyosys_test.bzl", "symbiyosys_test", "symbiyosys_trace")
load("//tools:vivado.bzl", "vivado_bitstream", "vivado_config_memory", "vivado_load",
     "vivado_flash")

vivado_bitstream(
    name = "top",
    srcs = ["top.v"],
    top = "top",
    part = "xc7a35ticsg324-1l",
    io_constraints = ["io_constraints.xdc"],
    bitstream_constraints = ["bitstream_constraints.xdc"],
)

vivado_config_memory(
    name = "top_config",
    bitstream = ":top",
    size = 16,
    memory_interface = "SPIx4",
)

vivado_load(
    name = "top_load",
    bitstream = ":top",
)

vivado_flash(
    name = "top_flash",
    config = ":top_config",
    memory_pn = "mt25ql128-spi-x1_x2_x4",
)

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
