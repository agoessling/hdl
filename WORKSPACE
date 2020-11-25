workspace(name = "hdl")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# Verilog Rules.
http_archive(
    name = "rules_verilog",
    strip_prefix = "rules_verilog-0.1.0",
    sha256 = "401b3f591f296f6fd2f6656f01afc1f93111e10b81b9a9d291f9c04b3e4a3e8b",
    url = "https://github.com/agoessling/rules_verilog/archive/v0.1.0.zip",
)

# Vivado Rules.
http_archive(
    name = "rules_vivado",
    strip_prefix = "rules_vivado-0.1.0",
    sha256 = "8b8bb5c6866e347c041bb6dca53b59f6be3c715192d035f1e3a2bf1027ad4d16",
    url = "https://github.com/agoessling/rules_vivado/archive/v0.1.0.zip",
)

load("@rules_vivado//vivado:direct_repositories.bzl", "rules_vivado_direct_deps")
rules_vivado_direct_deps()

load("@rules_vivado//vivado:indirect_repositories.bzl", "rules_vivado_indirect_deps")
rules_vivado_indirect_deps()

# Symbiyosys Rules.
http_archive(
    name = "rules_symbiyosys",
    strip_prefix = "rules_symbiyosys-0.1.0",
    sha256 = "2ca46880e91cb8453edac0ed485b895f6911127d87d675dab7635e99f9eaf59d",
    url = "https://github.com/agoessling/rules_symbiyosys/archive/v0.1.0.zip",
)

load("@rules_symbiyosys//symbiyosys:direct_repositories.bzl", "rules_symbiyosys_direct_deps")
rules_symbiyosys_direct_deps()

load("@rules_symbiyosys//symbiyosys:indirect_repositories.bzl", "rules_symbiyosys_indirect_deps")
rules_symbiyosys_indirect_deps()

# Googletest Rules.
http_archive(
    name = "gtest",
    strip_prefix = "googletest-release-1.10.0",
    sha256 = "94c634d499558a76fa649edb13721dce6e98fb1e7018dfaeba3cd7a083945e91",
    url = "https://github.com/google/googletest/archive/release-1.10.0.zip",
)

# Structopt
http_archive(
    name = "structopt",
    strip_prefix = "structopt-0.1.0",
    sha256 = "2f42afa039b8e250a597bc25c4180e0e1b612c99ed075f7de7dd57b87bbeba36",
    url = "https://github.com/p-ranav/structopt/archive/v0.1.0.zip",
    build_file = "@//tools:structopt.BUILD",
)

# Argparse
http_archive(
    name = "argparse",
    strip_prefix = "argparse-535244d7b7fb8b8e2aa88464de98ef120eb4ff7f",
    sha256 = "ede0db99134b0cb37f0debaef4a2d8fc069b9d5be9159bf9a631e2a195d513f5",
    url = "https://github.com/p-ranav/argparse/archive/535244d7b7fb8b8e2aa88464de98ef120eb4ff7f.zip",
    build_file = "@//tools:argparse.BUILD",
)

# Verilator Rules.
http_archive(
    name = "rules_verilator",
    strip_prefix = "rules_verilator-0.1-rc4",
    sha256 = "c0d7a13f586336ab12ea60cbfca226b660a39c6e8235ac1099e39dd2ace3166f",
    url = "https://github.com/kkiningh/rules_verilator/archive/v0.1-rc4.zip",
)

load(
    "@rules_verilator//verilator:repositories.bzl",
    "rules_verilator_dependencies",
    "rules_verilator_toolchains",
)

rules_verilator_dependencies()
rules_verilator_toolchains()

load("@rules_m4//m4:m4.bzl", "m4_register_toolchains")
m4_register_toolchains()

load("@rules_flex//flex:flex.bzl", "flex_register_toolchains")
flex_register_toolchains()

load("@rules_bison//bison:bison.bzl", "bison_register_toolchains")
bison_register_toolchains()
