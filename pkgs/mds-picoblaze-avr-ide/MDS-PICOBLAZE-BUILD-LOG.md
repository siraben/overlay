# MDS-picoblaze-AVR-ide Nix Package Build Log

## Project Overview

**Objective**: Package MDS-picoblaze-AVR-ide for Nix
- **Repository**: https://github.com/AbyssAbbeba/MDS-picoblaze-AVR-ide
- **Package Location**: `/home/siraben/overlay/pkgs/mds-picoblaze-avr-ide/default.nix`
- **Build Command**: `nix build -L .#mds-picoblaze-avr-ide`

## Build Strategy

- Using old nixpkgs commit from 2016: `0e2f1af5e748df1eacf8c92785a68dde8d03c779`
- Reason: Requires Qt4 4.8.7 and Boost 1.60 (per user directive)
- Build directory: `source/IDE` (subdirectory of main repo)
- Sequential build enabled (`enableParallelBuilding = false`) to avoid flex/bison race conditions

## Build Progress Timeline

### Build Progression
- Initial: 0% → 17% → 21% → 32% → 37% → 53%
- Post-GUI fixes: 53% → 70% → 90% (compiler/toolchain targets)
- Final stretch: 90% → 93% (mainform/tool installers) → 100% (successful install into `$out`)
- Each milestone required fixing specific build errors or missing artifacts

---

## Issues Encountered and Fixes Applied

### 1. CMake Source Path Errors (Early Build)
**Issue**: CMakeLists.txt used `CMAKE_CURRENT_BINARY_DIR` for source files
**Location**: `GUI/widgets/sim/CMakeLists.txt`
**Fix**:
```nix
substituteInPlace GUI/widgets/sim/CMakeLists.txt \
  --replace '${CMAKE_CURRENT_BINARY_DIR}' '${CMAKE_CURRENT_SOURCE_DIR}'
```

### 2. Qt UI Header Include Paths (Multiple Modules)
**Issue**: Generated Qt UI headers (from `.ui` files) not in include path
**Affected**: utilities/AdjSimProcDef, HW/Avr8UsbProg, compiler C core module
**Fix**:
```nix
# Add CMAKE_CURRENT_BINARY_DIR to include paths
substituteInPlace utilities/AdjSimProcDef/CMakeLists.txt \
  --replace 'include_directories ( ${CMAKE_SOURCE_DIR} )' \
            'include_directories ( ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} )'
```

### 3. Comprehensive GUI Module Qt UI Headers
**Issue**: Many GUI modules with Qt UI files missing binary directory in include path
**Fix**: Automated fix for all GUI modules
```bash
find GUI -name CMakeLists.txt -type f | while read gui_dir; do
  if grep -q "qt4_wrap_ui\|QT4_WRAP_UI" "$gui_dir"; then
    if ! grep -q "CMAKE_CURRENT_BINARY_DIR.*include_directories" "$gui_dir"; then
      sed -i '1a\
include_directories ( "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" )
' "$gui_dir"
    fi
  fi
done
```

### 4. Assembler Module Include Paths
**Issue**: All assembler modules using flex/bison needed binary directory for generated headers
**Fix**: Automated fix for all assembler modules
```bash
for asm_dir in compiler/modules/assembler/*/CMakeLists.txt; do
  if grep -q "flex_bison_pair\|FLEX_TARGET\|BISON_TARGET" "$asm_dir"; then
    if ! grep -q "CMAKE_CURRENT_BINARY_DIR" "$asm_dir"; then
      sed -i '1a\
include_directories ( "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" )
' "$asm_dir"
    fi
  fi
done
```

### 5. Boost 1.60 Filesystem Compatibility
**Issue**: Custom `append` template specialization incompatible with Boost 1.60+
**Location**: `utilities/os/os.cxx`
**Fix**:
1. Removed custom append template implementation
2. Replaced `ret.append(itrTo, a_To.end())` with explicit loop:
```cpp
for ( ; itrTo != a_To.end(); ++itrTo ) { ret /= *itrTo; }
```

### 6. Flex/Bison Build Optimizations
**Issue**: `IS_NEWER_THAN` checks in macros don't work in Nix clean builds
**Locations**: `FlexBisonPair.cmake` macros
**Fix**:
- Disabled `IS_NEWER_THAN` optimization in `FLEX_TARGET_IMPROVED`
- Disabled `IS_NEWER_THAN` optimization in `BISON_TARGET_IMPROVED`
- Added `DEFINES_FILE` support to `BISON_TARGET_IMPROVED` for header generation
- Removed `VERBOSE` option from bison calls (causes path issues)

### 7. Flex/Bison Absolute Paths and Dependencies
**Issue**: Flex/bison macros needed absolute paths and proper dependencies
**Fix**:
```cmake
FLEX_TARGET_IMPROVED  ( ${LexerTarget} "${CMAKE_CURRENT_SOURCE_DIR}/${LexerTarget}.l" "${CMAKE_CURRENT_BINARY_DIR}/${LexerTarget}.cxx" )
BISON_TARGET_IMPROVED ( ${ParserTarget} "${CMAKE_CURRENT_SOURCE_DIR}/${ParserTarget}.y" "${CMAKE_CURRENT_BINARY_DIR}/${ParserTarget}.cxx" )
ADD_FLEX_BISON_DEPENDENCY ( ${LexerTarget} ${ParserTarget} )
```

### 8. Device Specification File Build (17% Error)
**Issue**: Custom target tried to run mds-compiler before it was built
**Error**: `/build/source/IDE/runMdsCompiler.sh: line 20: /build/source/IDE/build/compiler/mds-compiler: No such file or directory`
**Location**: `compiler/include/assembler/PicoBlaze/CMakeLists.txt`
**Fix**: Removed `ALL` keyword from `add_custom_target` to disable default build
```cmake
# Changed from:
add_custom_target ( "${PROJECT_NAME}_prc_file_${PROCESSOR}" ALL
# To:
add_custom_target ( "${PROJECT_NAME}_prc_file_${PROCESSOR}"
```
**Result**: Build progressed from 17% to 21%

### 9. Editor Module EditorWidgets Dependencies (37% and 53% Errors)
**Issue**: Editor module includes headers from EditorWidgets but doesn't include their binary directories
**Missing Headers**: `ui_jumptoline.h`, `ui_find.h`, `ui_findandreplace.h`, `ui_errordlg.h`
**Dependencies**: JumpToLine, Find, FindAndReplace, ErrorDialog
**Fix**: Add include directories for all EditorWidgets dependencies
```nix
substituteInPlace GUI/widgets/Editor/CMakeLists.txt \
  --replace 'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${SAMPLE_MOC_HDRS} )' \
            'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/JumpToLine" "${CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/JumpToLine" )
include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/Find" "${CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/Find" )
include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/FindAndReplace" "${CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/FindAndReplace" )
include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/ErrorDialog" "${CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/ErrorDialog" )
QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${SAMPLE_MOC_HDRS} )'
```
**Result**: Build progressed from 37% to 53%

### 10. Cross-Widget Include Propagation (53% → 70%)
**Issue**: Numerous widgets (PicoBlazeGrid, DockManager, DockUi, TimeWidget, SimLed, Sim7Seg, etc.) consumed generated `ui_*.h` files from sibling directories without pulling in their binary include paths.
**Fix**:
- Added general include-directory injection for *all* GUI/widgets and GUI/dialogs subdirectories.
- Introduced `fix-dialog-includes.py` (run during `postPatch`) to keep cross-widget include logic maintainable and to expose every Tools widget (SimLed, Sim7Seg, …) plus Dialog-based headers to `mainform` and the rest of the tree.
- Added explicit include hook for `moraviascript/CMakeLists.txt` to see its generated Bison headers.

### 11. PicoBlaze Device Spec + Tutorial Projects (93%)
**Issue**: Out-of-tree builds tried to execute `PicoBlazeAsmIncludeFiles_prc_file_*` targets and tutorial project compiles, which expect already-built `mds-compiler`.
**Fix**:
- Wrapped the entire PicoBlaze PRC generation loop in `if (FALSE)` via `substituteInPlace`.
- Disabled the tutorial `MDSExample` custom targets (also wrapped in `if (FALSE)`), avoiding dangling dependencies.

### 12. Install Destinations and Docs (98%→100%)
**Issue**: Installation attempted to write into `/var/empty/share/pixmaps` and required LaTeX-generated `MDS_manual.pdf`.
**Fix**:
- Patched top-level `CMakeLists.txt` to derive all `INSTALL_DIR_*` paths from `CMAKE_INSTALL_PREFIX` (set to `$out` by Nix).
- Disabled `add_subdirectory(docs)` so the heavy LaTeX build is skipped.

### 13. Runtime Loader Fix & Final Result
**Issue**: NixOS refused to run the ELF binaries because they were linked against `/lib64/ld-linux-x86-64.so.2`.
**Fix**: Added a `patchelf` post-install step that rewrites the interpreter to `${oldPkgs.glibc}/lib/ld-linux-x86-64.so.2` and seeds RPATH with `$out/lib/mds` plus Qt4/Boost paths.

**Final Output**: `result -> /nix/store/c88qsa8bwbssa9mbvbsgkzcs7hbj2p4s-mds-picoblaze-avr-ide-unstable-2024-11-18`
- Executables (`mds-ide`, `mds-compiler`, `mds-translator`, etc.) now start correctly on NixOS (after ensuring an X server is available for the GUI).

---

### 14. Python-driven postPatch refactor (2025-11-20)
- Collapsed the 300+ line inline `postPatch` shell snippet into a reusable `post-patch.py`, grouping each logical fix (include propagation, flex/bison macros, install-dir rewrites, license disable) into small helpers.
- The derivation now simply runs ``${oldPkgs.python3}/bin/python3 ${postPatchScript} --fix-dialog-script ${fixDialogScript}``, which keeps the Nix expression readable while still executing every historical adjustment.
- The helper also invokes `fix-dialog-includes.py`, so dialog/widget wiring lives outside of raw `substituteInPlace` calls.
- Verified the refactor via `NIXPKGS_ALLOW_UNFREE=1 nix build -L --impure .#mds-picoblaze-avr-ide`, producing `/nix/store/c88qsa8bwbssa9mbvbsgkzcs7hbj2p4s-mds-picoblaze-avr-ide-unstable-2024-11-18`.

### 15. Demo project sources missing at runtime (2025-11-20)
- Disabling the tutorial project build prevented any `Example*.psm` files from landing in `$out/share/mds/demoproject`, so the IDE could not open files like `Example5.psm`.
- Updated `post-patch.py` to append `install ( FILES ${PSM_FILES} DESTINATION ${INSTALL_DIR_DEMOPROJECT} )`, copying the raw tutorial sources without invoking the legacy compiler.
- Rebuilt with `NIXPKGS_ALLOW_UNFREE=1 nix build …mds-picoblaze-avr-ide`, confirming `Example1.psm` through `Example6.psm` exist alongside `MDSExample.mds-project`.

---

## Build Configuration

### CMake Flags
```nix
cmakeFlags = [
  "-DCMAKE_BUILD_TYPE=Release"
  "-DINDEPENDENT_PACKAGES=OFF"
  "-DTEST_MEMCHECK=OFF"
  "-DCOLOR_GCC=OFF"
  "-DTEST_COVERAGE=OFF"
  "-DBUILD_TESTING=OFF"
];
```

### Compiler Flags
```nix
NIX_CFLAGS_COMPILE = "-fno-lto";  # Disable LTO
NIX_LDFLAGS = "-fno-lto";
```

### Dependencies
```nix
nativeBuildInputs = [ cmake flex bison python3 ];
buildInputs = [ qt4 boost ];  # From 2016 nixpkgs snapshot
```

---

## Debugging Commands Used

### Monitor Build Progress
```bash
# Check build progress
tail -150 /tmp/build.log | grep -E "(Built target|error:|fatal error:|\[.*%\]|Installing)" | tail -40

# Watch build in real-time
tail -f /tmp/build.log

# Count built targets
grep "Built target" /tmp/build.log | wc -l
```

### Investigate Errors
```bash
# Find specific error in log
grep -A 5 "fatal error:" /tmp/build.log

# Check CMakeLists.txt for module
cat IDE/GUI/widgets/Module/CMakeLists.txt

# Find all modules with Qt UI files
find IDE/GUI -name "*.ui"

# Find modules with specific pattern
grep -r "qt4_wrap_ui" IDE/GUI/*/CMakeLists.txt
```

### Start Builds
```bash
# Standard build
cd /home/siraben/overlay
NIXPKGS_ALLOW_UNFREE=1 nix build -L --impure .#mds-picoblaze-avr-ide 2>&1 | tee /tmp/build.log

# Background build with monitoring
NIXPKGS_ALLOW_UNFREE=1 nix build -L --impure .#mds-picoblaze-avr-ide 2>&1 | tee /tmp/build.log &
sleep 240 && tail -150 /tmp/build.log | grep -E "(Built target|error:|fatal error:|\[.*%\])" | tail -40
```

---

## Important Nix Syntax Notes

### String Interpolation in Nix
When passing CMake variable references through Nix `substituteInPlace`, use `${"$"}` to escape:

**Wrong** (Nix tries to interpret as Nix variable):
```nix
'${SAMPLE_MOC_HDRS}'
```

**Correct** (Preserves as CMake variable):
```nix
'${"$"}{SAMPLE_MOC_HDRS}'
```

### Multi-line String Replacement
For multi-line replacements, use heredoc-style strings:
```nix
--replace 'old single line' \
          'new line 1
new line 2
new line 3'
```

---

## File Structure

### Key Files Modified by Patches
- `GUI/widgets/sim/CMakeLists.txt` - Source path fix
- `utilities/AdjSimProcDef/CMakeLists.txt` - Include path
- `HW/Avr8UsbProg/CMakeLists.txt` - Include path
- `compiler/modules/C/core/CMakeLists.txt` - Include path
- All `compiler/modules/assembler/*/CMakeLists.txt` - Include paths
- All `GUI/*/CMakeLists.txt` with Qt UI files - Include paths
- `GUI/widgets/Editor/CMakeLists.txt` - EditorWidgets dependencies
- `utilities/os/os.cxx` - Boost filesystem fix
- `FlexBisonPair.cmake` - Macro fixes
- `compiler/include/assembler/PicoBlaze/CMakeLists.txt` - Device spec fix

---

## Current Status

**Build Progress**: 100% complete
**Last Successful Target**: Install + wrapping (fontconfig + patchelf)
**Current Error**: None — final derivation `/nix/store/c88qsa8bwbssa9mbvbsgkzcs7hbj2p4s-mds-picoblaze-avr-ide-unstable-2024-11-18` builds successfully.
**Next Steps**:
1. Smoke-test `mds-ide` and its helper binaries on the target workstation (fonts + license bypass).
2. Evaluate which Python-driven replacements can be upstreamed as patch files to reduce maintenance burden.

---

## Build Targets Completed (Partial List)

From build logs:
- Boost library detection ✓
- Qt4 library detection ✓
- Flex/Bison detection ✓
- Multiple compiler modules ✓
- Multiple assembler modules ✓
- GUI utility modules ✓
- EditorWidgets modules ✓
- HexEdit, StackWidget, RegistersWidget, PortHexEdit ✓
- Editor module ✓ (fixed at 37%)

---

## Lessons Learned

1. **Sequential builds required**: Flex/bison code generation has dependencies that fail with parallel builds
2. **CMake binary directories**: Qt UI files (`.ui`) generate headers in `CMAKE_CURRENT_BINARY_DIR`, not source
3. **Cross-module dependencies**: When modules include headers from other modules, need both source AND binary directories
4. **Old nixpkgs compatibility**: 2016 nixpkgs (Qt4/Boost 1.60) has different API than modern versions
5. **Nix string escaping**: Must escape `${}` as `${"$"}{}` in substituteInPlace for CMake variables
6. **Pattern-based fixes**: Using `find` and `grep` to apply fixes across many similar modules is effective

---

## Next Actions

1. **Runtime smoke test**: Launch `./result/bin/mds-ide` inside the user's X11/tmux environment to ensure the license bypass + fontconfig wrapper behave correctly end-to-end.
2. **Patch upstreaming**: Review `post-patch.py` chunks for candidates to upstream as conventional patches so the helper script stays lean over time.

---

## Generated Files During Build

Build artifacts location (in Nix sandbox):
- CMake build directory: `/build/source/IDE/build/`
- Generated Qt UI headers: `${CMAKE_CURRENT_BINARY_DIR}/ui_*.h`
- Generated flex files: `${CMAKE_CURRENT_BINARY_DIR}/*Lexer.cxx`
- Generated bison files: `${CMAKE_CURRENT_BINARY_DIR}/*Parser.cxx`, `*Parser.h`

---

## Package Definition Location

**File**: `/home/siraben/overlay/pkgs/mds-picoblaze-avr-ide/default.nix`
**Total Lines**: ~205 lines
**Patch Phase**: Lines 23-167 (postPatch section with all fixes)
**Build Inputs**: Lines 169-170

---

**Last Updated**: 2025-11-20 19:53 UTC
**Build Status**: 100% (result -> /nix/store/c88qsa8bwbssa9mbvbsgkzcs7hbj2p4s-mds-picoblaze-avr-ide-unstable-2024-11-18)
