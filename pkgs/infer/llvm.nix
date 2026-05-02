{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  python3,
  libxml2,
  libffi,
  zlib,
  ncurses,
  symlinkJoin,
}:

let
  version = "18.1.3";
  runtimeSysroot = symlinkJoin {
    name = "infer-llvm-runtime-sysroot";
    paths = [
      stdenv.cc.libc
      stdenv.cc.libc.dev
      stdenv.cc.cc
      stdenv.cc.cc.lib
    ];
  };
  runtimeCmakeArgs = lib.concatStringsSep ";" [
    "-DCMAKE_SYSROOT=${runtimeSysroot}"
    "-DCMAKE_C_FLAGS=--gcc-toolchain=${runtimeSysroot}"
    "-DCMAKE_CXX_FLAGS=--gcc-toolchain=${runtimeSysroot}"
    "-DCMAKE_EXE_LINKER_FLAGS=-L${runtimeSysroot}/lib"
    "-DCMAKE_SHARED_LINKER_FLAGS=-L${runtimeSysroot}/lib"
    "-DCMAKE_MODULE_LINKER_FLAGS=-L${runtimeSysroot}/lib"
  ];
in
stdenv.mkDerivation {
  pname = "infer-llvm";
  inherit version;

  src = fetchurl {
    url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/llvm-project-${version}.src.tar.xz";
    hash = "sha256-KSn2LWnewDeeUp62MsQOFRkeNvO9WMLLLfBBOg3EhlE=";
  };

  patches = [
    ./patches/llvm/err_ret_local_block.patch
    ./patches/llvm/mangle_suppress_errors.patch
    ./patches/llvm/AArch64SVEACLETypes.patch
    ./patches/llvm/SmallVector-cstdint.patch
  ];

  # The patches include an extra llvm-project/ path component.
  patchFlags = [ "-p2" ];

  nativeBuildInputs = [
    cmake
    ninja
    python3
  ];

  buildInputs = [
    libxml2
    libffi
    zlib
    ncurses
  ];

  cmakeDir = "../llvm";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DLLVM_BUILD_TOOLS=OFF"
    "-DLLVM_ENABLE_ASSERTIONS=OFF"
    "-DLLVM_ENABLE_EH=ON"
    "-DLLVM_ENABLE_RTTI=ON"
    "-DLLVM_BUILD_DOCS=OFF"
    "-DLLVM_INCLUDE_BENCHMARKS=OFF"
    "-DLLVM_INCLUDE_EXAMPLES=OFF"
    "-DLLVM_INCLUDE_TESTS=OFF"
    "-DLLVM_TARGETS_TO_BUILD=X86;AArch64;ARM;Mips"
    "-DLLVM_ENABLE_PROJECTS=clang"
    # Infer's models need libc++ headers; skip libunwind for Darwin sandboxing.
    "-DLLVM_ENABLE_RUNTIMES=libcxx;libcxxabi"
    "-DLIBCXX_CXX_ABI=libcxxabi"
    "-DLIBCXXABI_USE_LLVM_UNWINDER=OFF"
    # GCC 15/libstdc++ exposes missing transitive <cstdint> includes in LLVM 18.
    "-DCMAKE_CXX_FLAGS=-includecstdint"
  ]
  ++ lib.optionals stdenv.isLinux [
    # LLVM runtimes are built by the just-built clang rather than Nix's wrapper,
    # so pass a sysroot with glibc, GCC startup objects, and libstdc++.
    "-DRUNTIMES_CMAKE_ARGS=${runtimeCmakeArgs}"
  ]
  ++ lib.optionals stdenv.isDarwin [
    "-DLLVM_BUILD_LLVM_DYLIB=ON"
  ];

  meta = {
    description = "Patched LLVM/clang 18.1.3 used by facebook/infer's clang frontend";
    homepage = "https://llvm.org/";
    license = lib.licenses.ncsa;
    platforms = lib.platforms.unix;
  };
}
