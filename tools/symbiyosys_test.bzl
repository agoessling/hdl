def _symbiyosys_test_impl(ctx):
    config_str = ""
    config_str = "[tasks]\n"
    tasks = ["task{}".format(i) for i in range(len(ctx.attr.modes))]
    config_str += "\n".join(tasks)
    config_str += "\n\n"

    config_str += "[options]\n"
    options = ["task{}: mode {}".format(i, mode) for i, mode in enumerate(ctx.attr.modes)]
    config_str += "\n".join(options)
    config_str += "\n\n"

    config_str += "[engines]\n"
    config_str += "\n".join(ctx.attr.engines)
    config_str += "\n\n"

    config_str += "[script]\n"
    for f in ctx.files.srcs:
        sv_flag = " -sv" if f.extension == "sv" else ""
        config_str += "read -formal{} {}\n".format(sv_flag, f.basename)
    config_str += "prep -top {}\n".format(ctx.attr.top)
    config_str += "\n"

    config_str += "[files]\n"
    config_str += "\n".join([f.short_path for f in ctx.files.srcs])

    config = ctx.actions.declare_file("{}.sby".format(ctx.label.name))
    ctx.actions.write(config, config_str)

    shell_cmd = "sby -f {}".format(config.short_path)
    script = ctx.actions.declare_file("{}.sh".format(ctx.label.name))
    ctx.actions.write(script, shell_cmd, is_executable = True)

    runfiles = ctx.runfiles(files = [config] + ctx.files.srcs)
    return [DefaultInfo(executable = script, runfiles = runfiles)]


symbiyosys_test = rule(
    implementation = _symbiyosys_test_impl,
    doc = "Formal verification of (System) Verilog.",
    attrs = {
        "srcs": attr.label_list(
            doc = "(System) verilog source files.",
            mandatory = True,
            allow_empty = False,
            allow_files = [".v", ".sv"],
        ),
        "top": attr.string(
            doc = "Top module name.",
            mandatory = True,
        ),
        "modes": attr.string_list(
            doc = "Modes of verification.",
            mandatory = True,
            allow_empty = False,
        ),
        "engines": attr.string_list(
            doc = "Verification engines.",
            default = ["smtbmc"],
            allow_empty = False,
        ),
    },
    test = True,
)
