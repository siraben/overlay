{
  polyml,
}:

# CakeML's CI worker uses Poly/ML 5.8.1, but it doesn't compile against
# modern glibc. nixpkgs' 5.9.2 builds and works.  build-instructions.sh
# recommends `--enable-intinf-as-int` for cv_compute, but it makes the
# bootstrap noticeably slower here, so leave it off.
polyml
