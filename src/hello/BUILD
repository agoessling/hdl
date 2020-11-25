load("@rules_verilog//verilog:defs.bzl", "verilog_module")
load("@rules_vivado//vivado:defs.bzl", "vivado_project")

load("//tools:verilator_cc_test.bzl", "verilator_cc_test")

verilog_module(
    name = "hello_module",
    top = "hello",
    srcs = ["hello.sv"],
    deps = [
        "//src/lib:uart_tx_module",
        "//src/lib:strobe_div_module",
    ],
)

verilator_cc_test(
    name = "hello",
    module = ":hello_module",
    csrcs = ["test_hello.cpp"],
    params = {
        "BAUD": [25000000],
        "FREP": [100000],
    },
)

vivado_project(
    name = "hello",
    module = ":hello_module",
    part = "xc7a35ticsg324-1l",
    io_constraints = [
        "timing_constraints.xdc",
        "io_constraints.xdc",
    ],
    bitstream_constraints = ["bitstream_constraints.xdc"],
    memory_size = 16,
    memory_interface = "SPIx4",
    memory_pn = "mt25ql128-spi-x1_x2_x4",
)
