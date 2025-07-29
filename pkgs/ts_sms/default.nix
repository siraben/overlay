{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  cudaPackages ? null,
  cudaSupport ? false,
}:

stdenv.mkDerivation rec {
  pname = "ts_sms";
  version = "2024-12-26";

  src = fetchurl {
    url = "https://bellard.org/ts_sms/ts_sms-${version}.tar.gz";
    sha256 = "eWajeDNcoSwU+acAUPqBz0bl/Hvb9CQBMOKN9NTXrOQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = lib.optionals cudaSupport [
    cudaPackages.cudatoolkit
  ];

  # libcuda.so.1 is provided by the NVIDIA driver at runtime
  autoPatchelfIgnoreMissingDeps = [ "libcuda.so.1" ];

  installPhase = ''
    mkdir -p $out/{bin,lib}

    # Install libraries
    cp libnc.so $out/lib/
    ${lib.optionalString cudaSupport "cp libnc_cuda.so $out/lib/"}

    # Copy resources directly to bin directory
    cp -r tokenizer *.bin $out/bin/

    # Create symlinks for libraries in bin directory
    ln -s $out/lib/libnc.so $out/bin/
    ${lib.optionalString cudaSupport "ln -s $out/lib/libnc_cuda.so $out/bin/"}

    # Install binary
    cp ts_sms $out/bin/ts_sms-unwrapped

    # Create wrapper that sets up CUDA paths
    makeWrapper $out/bin/ts_sms-unwrapped $out/bin/ts_sms \
      ${lib.optionalString cudaSupport ''--prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:/run/opengl-driver-32/lib"''}
  '';

  meta = with lib; {
    description =
      "Short Message Compression using neural network models"
      + lib.optionalString cudaSupport " (with CUDA support)";
    homepage = "https://bellard.org/ts_sms/";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
