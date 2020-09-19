load("@rules_verilator//verilator:defs.bzl", "verilator_cc_library")

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
    return "_" + "_".join([str(k) + str(v) for k, v in params.items()])

def verilator_cc_test(name, vsrcs, csrcs, vdeps = [], cdeps = [], params = {"NONE": [""]}):
    params_lists = _ngrid_params(params)

    for i in range(len(params_lists.values()[0])):
        params = {k: v[i] for k, v in params_lists.items()}

        vopts = ["-Wall"] + ["-G{}={}".format(k, v) for k, v in params.items() if v]

        verilator_lib_name = name + _param_suffix(params)

        verilator_cc_library(
            name = verilator_lib_name,
            mtop = name,
            srcs = vsrcs,
            vopts = vopts,
            trace = True,
        )

        native.cc_test(
            name = "test_" + verilator_lib_name,
            srcs = csrcs,
            deps = cdeps + [":" + verilator_lib_name, "//:test_bench", "@gtest//:gtest"],
            linkstatic = True,
            tags = [name],
        )

    native.test_suite(
        name = name,
        tags = [name],
    )
