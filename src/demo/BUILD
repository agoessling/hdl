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
