{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, cudaPackages ? null, cudaSupport ? false }:

stdenv.mkDerivation rec {
  pname = "ts_zip";
  version = "2024-03-02";

  src = fetchurl {
    url = "https://bellard.org/ts_zip/ts_zip-${version}.tar.gz";
    sha256 = "Swcsaqh5GV8Huo8Oce6IkI2kPfDo2vXo22UhYSR1T/E=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  
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
    
    # Copy model file to bin directory
    cp *.bin $out/bin/
    
    # Create symlinks for libraries in bin directory
    ln -s $out/lib/libnc.so $out/bin/
    ${lib.optionalString cudaSupport "ln -s $out/lib/libnc_cuda.so $out/bin/"}
    
    # Install binary
    cp ts_zip $out/bin/ts_zip-unwrapped
    
    # Create wrapper that sets up CUDA paths
    makeWrapper $out/bin/ts_zip-unwrapped $out/bin/ts_zip \
      ${lib.optionalString cudaSupport ''--prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib:/run/opengl-driver-32/lib"''}
  '';

  meta = with lib; {
    description = "Text compression using Large Language Models" + lib.optionalString cudaSupport " (with CUDA support)";
    homepage = "https://bellard.org/ts_zip/";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}