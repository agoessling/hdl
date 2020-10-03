def _symbiyosys_test_impl(ctx):
    prefix = "${{RUNFILES_DIR}}/{}/".format(ctx.workspace_name)
    shell_cmd = [
        prefix + ctx.executable._symbiyosys_wrapper.short_path,
        "--modes",
        " ".join(ctx.attr.modes),
        "--engine",
        ctx.attr.engine,
        "--top",
        ctx.attr.top,
        "--depth",
        str(ctx.attr.depth),
        " ".join([prefix + f.short_path for f in ctx.files.srcs]),
        "$@",
    ]

    script = ctx.actions.declare_file("{}.sh".format(ctx.label.name))
    ctx.actions.write(script, ' '.join(shell_cmd), is_executable = True)

    runfiles = ctx.runfiles(
        files = ctx.files.srcs,
        transitive_files = ctx.attr._symbiyosys_wrapper[DefaultInfo].default_runfiles.files,
    )
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
        "depth": attr.int(
            doc = "Solver depth.",
            default = 20,
        ),
        "engine": attr.string(
            doc = "Verification engine.",
            default = "smtbmc",
        ),
        "_symbiyosys_wrapper": attr.label(
            doc = "Symbiyosys wrapper script.",
            default = Label("//tools:symbiyosys_wrapper"),
            executable = True,
            cfg = "target",
        ),
    },
    test = True,
)


def _symbiyosys_trace_impl(ctx):
    # Run test to generate VCD directory / files.
    vcd_dir = ctx.actions.declare_directory("{}_vcd".format(ctx.label.name))

    args = ctx.actions.args()
    args.add("--vcd_dir")
    args.add(vcd_dir.path)
    args.add("--ignore_failure")

    ctx.actions.run(outputs = [vcd_dir], executable = ctx.executable.test, arguments = [args],
                    env = {
                        "RUNFILES_DIR": ctx.executable.test.path + ".runfiles",
                        "PATH": "/usr/local/bin:/usr/bin:/bin"
                    })

    # Wrap gtk_wrapper in order to bake in arguments.
    shell_cmd = [
        ctx.executable._gtkwave_wrapper.short_path,
        "--tcl_template",
        ctx.file._tcl_template.short_path,
        "--tcl_output",
        ctx.label.name + ".tcl",
        "--vcd_dir",
        vcd_dir.short_path,
        "--open_level",
        "1",
        "$@",
    ]
    shell_script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(shell_script, ' '.join(shell_cmd), is_executable = True)

    runfiles = ctx.runfiles(files = [ctx.file._tcl_template, vcd_dir])

    for attr in [ctx.attr._gtkwave_wrapper, ctx.attr.test]:
      runfiles = runfiles.merge(attr[DefaultInfo].default_runfiles)

    return [DefaultInfo(executable = shell_script, runfiles = runfiles)]


symbiyosys_trace = rule(
    implementation = _symbiyosys_trace_impl,
    doc = "View VCD trace from Symbiyosys.",
    attrs = {
        "test": attr.label(
            doc = "Test target to produce VCD file.",
            mandatory = True,
            executable = True,
            cfg = "target",
        ),
        "_tcl_template": attr.label(
            doc = "Tcl file for GTKwave initialization.",
            default = Label("//tools:gtkwave.tcl.template"),
            allow_single_file = True,
        ),
        "_gtkwave_wrapper": attr.label(
            doc = "GTKwave wrapper script.",
            default = Label("//tools:gtkwave_wrapper"),
            executable = True,
            cfg = "target",
        ),
    },
    executable = True,
)
