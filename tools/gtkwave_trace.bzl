def _gtkwave_trace_impl(ctx):
    # Run test to generate VCD directory / files.
    vcd_dir = ctx.actions.declare_directory(ctx.label.name + "_vcd")
    args = ctx.actions.args()
    args.add('-d', vcd_dir.path)
    ctx.actions.run(outputs = [vcd_dir], executable = ctx.executable.test, arguments = [args])

    # Wrap gtk_wrapper in order to bake in arguments.
    shell_cmd = [
        ctx.executable._gtkwave_wrapper.short_path,
        "--tcl_template",
        ctx.file._tcl_template.short_path,
        "--tcl_output",
        ctx.label.name + ".tcl",
        "--vcd_dir",
        vcd_dir.short_path,
        "$@",
    ]
    shell_script = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(shell_script, ' '.join(shell_cmd), is_executable = True)

    runfiles = ctx.runfiles(
        files = [
            ctx.file._tcl_template,
            vcd_dir,
        ],
        transitive_files = ctx.attr._gtkwave_wrapper[DefaultInfo].default_runfiles.files,
    )
    return [DefaultInfo(executable = shell_script, runfiles = runfiles)]

gtkwave_trace = rule(
    implementation = _gtkwave_trace_impl,
    doc = "View VCD trace from test.",
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
