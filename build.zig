const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const upstream = b.dependency("clickhouse", .{});

    const absl = b.addStaticLibrary(.{ .name = "absl", .target = target, .optimize = optimize });
    absl.addIncludePath(upstream.path("contrib/absl"));
    absl.addCSourceFiles(.{
        .root = upstream.path("contrib/absl/absl"),
        .files = &.{
            "numeric/int128.cc",
        },
        .flags = &.{ "-std=c++17", "-Wno-implicit-fallthrough" },
    });
    absl.linkLibCpp();

    const cityhash = b.addStaticLibrary(.{ .name = "cityhash", .target = target, .optimize = optimize });
    cityhash.addIncludePath(upstream.path("contrib/cityhash"));
    cityhash.addCSourceFiles(.{ .root = upstream.path("contrib/cityhash/cityhash"), .files = &.{
        "city.cc",
    }, .flags = &.{"-std=c++17"} });
    cityhash.linkLibCpp();

    const gtest = b.addStaticLibrary(.{ .name = "gtest-lib", .target = target, .optimize = optimize });
    gtest.addIncludePath(upstream.path("contrib/gtest/include"));
    gtest.addIncludePath(upstream.path("contrib/gtest"));
    gtest.addCSourceFiles(.{ .root = upstream.path("contrib/gtest"), .files = &.{
        "src/gtest.cc",
        "src/gtest-all.cc",
        "src/gtest_main.cc",
    }, .flags = &.{"-std=c++17"} });
    gtest.linkLibCpp();

    const lz4 = b.addStaticLibrary(.{ .name = "lz4", .target = target, .optimize = optimize });
    lz4.addCSourceFiles(.{ .root = upstream.path("contrib/lz4/lz4"), .files = &.{
        "lz4.c",
        "lz4hc.c",
    }, .flags = &.{"-std=c99"} });
    lz4.linkLibC();

    const lib = b.addStaticLibrary(.{
        .name = "clickhouse-cpp",
        .target = target,
        .optimize = optimize,
    });

    lib.linkLibrary(absl);
    lib.linkLibrary(cityhash);
    lib.linkLibrary(gtest);
    lib.linkLibrary(lz4);

    lib.linkLibC();
    lib.linkLibCpp();
    lib.addIncludePath(upstream.path("contrib/absl"));
    lib.addIncludePath(upstream.path("contrib/cityhash"));
    lib.addIncludePath(upstream.path("contrib/cityhash/cityhash"));
    lib.addIncludePath(upstream.path("contrib/gtest/include"));
    lib.addIncludePath(upstream.path("contrib/gtest"));
    lib.addIncludePath(upstream.path("contrib/lz4/lz4"));
    lib.addIncludePath(upstream.path(""));

    lib.addCSourceFiles(
        .{
            .root = upstream.path("clickhouse"),
            .files = &.{
                "base/compressed.cpp",
                "base/input.cpp",
                "base/output.cpp",
                "base/platform.cpp",
                "base/socket.cpp",
                "base/wire_format.cpp",
                "base/endpoints_iterator.cpp",
                "columns/array.cpp",
                "columns/column.cpp",
                "columns/date.cpp",
                "columns/decimal.cpp",
                "columns/enum.cpp",
                "columns/factory.cpp",
                "columns/geo.cpp",
                "columns/ip4.cpp",
                "columns/ip6.cpp",
                "columns/lowcardinality.cpp",
                "columns/nullable.cpp",
                "columns/numeric.cpp",
                "columns/map.cpp",
                "columns/string.cpp",
                "columns/tuple.cpp",
                "columns/uuid.cpp",
                "columns/itemview.cpp",
                "types/type_parser.cpp",
                "types/types.cpp",
                "block.cpp",
                "client.cpp",
                "query.cpp",
            },
            .flags = &.{ "-std=c++17", "-D_CRT_SECURE_NO_WARNINGS", "-Wempty-body", "-Wconversion", "-Wreturn-type", "-Wno-sign-conversion", "-Wparentheses", "-Wuninitialized", "-Wunreachable-code", "-Wunused-function", "-Wunused-value", "-Wunused-variable" },
        },
    );

    b.installArtifact(lib);
}
