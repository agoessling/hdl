def _gtkwave_trace_impl(ctx):
    # Run test to generate VCD directory / files.
    vcd_dir = ctx.actions.declare_directory(ctx.label.name + "_vcd")

    args = ctx.actions.args()
    args.add('-d', vcd_dir.path)
    args.add('--ignore_failure')

    ctx.actions.run(outputs = [vcd_dir], executable = ctx.executable.test, arguments = [args])

    # Wrap gtk_wrapper in order to bake in arguments.
    shell_cmd = [
        ctx.executable._gtkwave_wrapper.short_path,
        "--vcd_dir",
        vcd_dir.short_path,
        "--open_level",
        "2",
        "$@",
    ]
    shell_script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(shell_script, ' '.join(shell_cmd), is_executable = True)

    runfiles = ctx.runfiles(files = [vcd_dir])

    for attr in [ctx.attr._gtkwave_wrapper, ctx.attr.test]:
      runfiles = runfiles.merge(attr[DefaultInfo].default_runfiles)

    return [DefaultInfo(executable = shell_script, runfiles = runfiles)]

gtkwave_trace = rule(
    implementation = _gtkwave_trace_impl,
    doc = "View VCD trace from test.",
    attrs = {
        "test": attr.label(
            doc = "Test target to produce VCD file.",
            mandatory = True,
            executable = True,
            cfg = "exec",
        ),
        "_gtkwave_wrapper": attr.label(
            doc = "GTKwave wrapper script.",
            default = Label("@rules_verilog//gtkwave:gtkwave_wrapper"),
            executable = True,
            cfg = "exec",
        ),
    },
    executable = True,
)
