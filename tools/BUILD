exports_files(["gtkwave.tcl.template"])

py_binary(
    name = "gtkwave_wrapper",
    srcs = ["gtkwave_wrapper.py"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "symbiyosys_wrapper",
    srcs = ["symbiyosys_wrapper.py"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "vivado_client",
    srcs = ["vivado_client.py"],
    deps = [":process_manager"],
    visibility = ["//visibility:public"],
)

py_binary(
    name = "vivado_server",
    srcs = ["vivado_server.py"],
    deps = [":process_manager"],
    visibility = ["//visibility:public"],
)

py_library(
    name = "process_manager",
    srcs = ["process_manager.py"],
    visibility = ["//visibility:public"],
)
