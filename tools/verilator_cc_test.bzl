load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")

load("//tools:gtkwave_trace.bzl", "gtkwave_trace")

def _tally_repetition(values, i):
    before = 1
    for v in values[:i]:
        before = before * len(v)
    after = 1
    for v in values[i + 1:]:
        after = after * len(v)

    return before, after

def _ngrid_params(params):
    keys = params.keys()
    orig_values = params.values()
    new_params = {}

    for i in range(len(keys)):
        before, after = _tally_repetition(orig_values, i)

        new_values = []
        for val in orig_values[i]:
            new_values += [val] * after

        new_values = new_values * before
        new_params[keys[i]] = new_values

    return new_params

def _param_suffix(params):
    return "_" + "_".join([str(k) + str(v) for k, v in params.items()]) if params else ""

def verilator_cc_test(name, module, csrcs, cdeps = [], param_cases = [{}]):
    for params in param_cases:
        vopts = ["-Wall"] + ["-G{}={}".format(k, v) for k, v in params.items()]

        verilator_lib_name = name + _param_suffix(params)

        verilator_cc_library(
            name = verilator_lib_name,
            module = module,
            vopts = vopts,
            trace = True,
        )

        native.cc_test(
            name = "test_" + verilator_lib_name,
            srcs = csrcs,
            deps = cdeps + [
                ":" + verilator_lib_name,
                "//src/lib:module_test_fixture",
                "//src/lib:module_test_main",
                "@gtest//:gtest",
            ],
            linkstatic = True,
            tags = [name],
        )

        gtkwave_trace(
            name = "trace_" + verilator_lib_name,
            test = ":test_" + verilator_lib_name,
            testonly = True,
        )

    native.test_suite(
        name = name,
        tags = [name],
    )
