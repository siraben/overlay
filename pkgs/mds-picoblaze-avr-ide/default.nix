{ fetchFromGitHub }:

let
  # Use old nixpkgs from 2016 with Qt4 and Boost 1.60
  oldPkgs = import (fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "0e2f1af5e748df1eacf8c92785a68dde8d03c779";  # 2016, has Qt4 and Boost 1.60
    sha256 = "sha256-z4b++crB5VaDGSSObZWfxQwisa4g94QK7DZrSKgDn3o=";
  }) { config.allowUnfree = true; };

in oldPkgs.stdenv.mkDerivation rec {
  name = "mds-picoblaze-avr-ide-unstable-2024-11-18";

  src = fetchFromGitHub {
    owner = "AbyssAbbeba";
    repo = "MDS-picoblaze-AVR-ide";
    rev = "afc0cf7fd115ce063303f27d0bc03dc9f146e19b";
    sha256 = "sha256-E5s5537rAb9xv6ayrySjyVvSinNoOh6gq4cnw6Cp6mI=";
  };

  sourceRoot = "source/IDE";

  postPatch = ''
    echo "=== Starting postPatch phase ==="

    # Fix incorrect use of CMAKE_CURRENT_BINARY_DIR for source files
    substituteInPlace GUI/widgets/sim/CMakeLists.txt \
      --replace '${"$"}{CMAKE_CURRENT_BINARY_DIR}' '${"$"}{CMAKE_CURRENT_SOURCE_DIR}'

    # Add CMAKE_CURRENT_BINARY_DIR to include paths for Qt UI headers and generated flex/bison headers
    substituteInPlace utilities/AdjSimProcDef/CMakeLists.txt \
      --replace 'include_directories ( ${"$"}{CMAKE_SOURCE_DIR} )' \
                'include_directories ( ${"$"}{CMAKE_SOURCE_DIR} ${"$"}{CMAKE_CURRENT_BINARY_DIR} )'

    substituteInPlace HW/Avr8UsbProg/CMakeLists.txt \
      --replace 'include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/utilities/MCUDataFiles/"' \
                'include_directories ( ${"$"}{CMAKE_CURRENT_BINARY_DIR} "${"$"}{CMAKE_SOURCE_DIR}/utilities/MCUDataFiles/"'

    # Add CMAKE_CURRENT_SOURCE_DIR and CMAKE_CURRENT_BINARY_DIR to compiler module C core include path
    sed -i '/compiler\/core\/" )/a\
include_directories ( "${"$"}{CMAKE_CURRENT_SOURCE_DIR}" "${"$"}{CMAKE_CURRENT_BINARY_DIR}" )
' compiler/modules/C/core/CMakeLists.txt

    # Add CMAKE_CURRENT_BINARY_DIR to all assembler module include paths for generated headers
    for asm_dir in compiler/modules/assembler/*/CMakeLists.txt; do
      if grep -q "flex_bison_pair\|FLEX_TARGET\|BISON_TARGET" "$asm_dir"; then
        if ! grep -q "CMAKE_CURRENT_BINARY_DIR" "$asm_dir"; then
          sed -i '1a\
include_directories ( "${"$"}{CMAKE_CURRENT_SOURCE_DIR}" "${"$"}{CMAKE_CURRENT_BINARY_DIR}" )
' "$asm_dir"
        fi
      fi
    done

    # Add CMAKE_CURRENT_BINARY_DIR to all GUI module include paths for Qt UI headers
    find GUI -name CMakeLists.txt -type f | while read gui_dir; do
      if grep -q "qt4_wrap_ui\|QT4_WRAP_UI" "$gui_dir"; then
        if ! grep -q "CMAKE_CURRENT_BINARY_DIR.*include_directories" "$gui_dir"; then
          sed -i '1a\
include_directories ( "${"$"}{CMAKE_CURRENT_SOURCE_DIR}" "${"$"}{CMAKE_CURRENT_BINARY_DIR}" )
' "$gui_dir"
        fi
      fi
    done

    # Propagate include directories for every widget (source + binary) so cross-widget ui_*.h headers resolve
    substituteInPlace GUI/widgets/CMakeLists.txt \
      --replace 'set(CMAKE_VERBOSE_MAKEFILE OFF)

' 'set(CMAKE_VERBOSE_MAKEFILE OFF)

# Ensure each widget directory is visible to all children for both source and generated headers.
file(GLOB WIDGET_INCLUDE_DIRS "${"$"}{CMAKE_CURRENT_SOURCE_DIR}/*")
foreach(widget_dir ${"$"}{WIDGET_INCLUDE_DIRS})
    if (IS_DIRECTORY ${"$"}{widget_dir})
        get_filename_component(widget_name ${"$"}{widget_dir} NAME)
        include_directories("${"$"}{widget_dir}")
        include_directories("${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/${"$"}{widget_name}")
    endif()
endforeach()

'

    # Ensure Project headers include STL containers used in moc outputs
    substituteInPlace GUI/project/project.h \
      --replace '#include <set>' '#include <set>
#include <vector>
#include <string>
#include <utility>'

    # Make widget headers visible to all GUI subdirectories
    substituteInPlace GUI/CMakeLists.txt \
      --replace 'include_directories ( ${"$"}{CMAKE_BINARY_DIR}
                        "${"$"}{CMAKE_CURRENT_BINARY_DIR}/mainform/" )' 'include_directories ( ${"$"}{CMAKE_BINARY_DIR}
                        "${"$"}{CMAKE_CURRENT_BINARY_DIR}/mainform/" )

# Expose all widget include paths (source + binary) to the entire GUI tree.
set(MDS_WIDGET_DIR "${"$"}{CMAKE_CURRENT_SOURCE_DIR}/widgets")
file(GLOB GUI_WIDGET_INCLUDE_DIRS "${"$"}{MDS_WIDGET_DIR}/*")
foreach(widget_dir ${"$"}{GUI_WIDGET_INCLUDE_DIRS})
    if (IS_DIRECTORY ${"$"}{widget_dir})
        get_filename_component(widget_name ${"$"}{widget_dir} NAME)
        include_directories("${"$"}{widget_dir}")
        include_directories("${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/${"$"}{widget_name}")
    endif()
endforeach()

# Expose all dialog include paths as well.
set(MDS_DIALOG_DIR "${"$"}{CMAKE_CURRENT_SOURCE_DIR}/dialogs")
file(GLOB GUI_DIALOG_INCLUDE_DIRS "${"$"}{MDS_DIALOG_DIR}/*")
foreach(dialog_dir ${"$"}{GUI_DIALOG_INCLUDE_DIRS})
    if (IS_DIRECTORY ${"$"}{dialog_dir})
        get_filename_component(dialog_name ${"$"}{dialog_dir} NAME)
        include_directories("${"$"}{dialog_dir}")
        include_directories("${"$"}{CMAKE_BINARY_DIR}/GUI/dialogs/${"$"}{dialog_name}")
    endif()
endforeach()
'

    # Ensure project configuration dialog can reach project headers
    substituteInPlace GUI/dialogs/projectcfg/CMakeLists.txt \
      --replace 'set(CMAKE_VERBOSE_MAKEFILE OFF)
' 'set(CMAKE_VERBOSE_MAKEFILE OFF)

include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/project" "${"$"}{CMAKE_BINARY_DIR}/GUI/project" )
'

    substituteInPlace GUI/dialogs/projectdlg/CMakeLists.txt \
      --replace 'set(CMAKE_VERBOSE_MAKEFILE OFF)
' 'set(CMAKE_VERBOSE_MAKEFILE OFF)

include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/project" "${"$"}{CMAKE_BINARY_DIR}/GUI/project" )
'

    # Allow dialog subdirectories to include each other's generated headers and expose them to mainform
    ${oldPkgs.python3}/bin/python3 ${./fix-dialog-includes.py}

    # Ensure moraviascript sources can see generated parser headers
    substituteInPlace moraviascript/CMakeLists.txt \
      --replace 'project ( MScript )' 'project ( MScript )
include_directories ( "${"$"}{CMAKE_CURRENT_SOURCE_DIR}" "${"$"}{CMAKE_CURRENT_BINARY_DIR}" )'

    # Disable runtime license certificate checks (software now open-source)
    substituteInPlace GUI/main.cpp \
      --replace '#ifndef MDS_VARIANT_TRIAL' '#if 0 /* License verification disabled for Nix build */'

    # Make installation directories respect CMAKE_INSTALL_PREFIX
    substituteInPlace CMakeLists.txt \
      --replace 'set ( INSTALL_DIR_PREFIX "/usr/" )' 'set ( INSTALL_DIR_PREFIX "${"$"}{CMAKE_INSTALL_PREFIX}/" )' \
      --replace 'set ( INSTALL_DIR_BIN         "${"$"}{INSTALL_DIR_PREFIX}bin" )' 'set ( INSTALL_DIR_BIN         "${"$"}{CMAKE_INSTALL_PREFIX}/bin" )' \
      --replace 'set ( INSTALL_DIR_LIB         "${"$"}{INSTALL_DIR_PREFIX}lib/mds" )' 'set ( INSTALL_DIR_LIB         "${"$"}{CMAKE_INSTALL_PREFIX}/lib/mds" )' \
      --replace 'set ( INSTALL_DIR_DOC         "${"$"}{INSTALL_DIR_PREFIX}doc/mds" )' 'set ( INSTALL_DIR_DOC         "${"$"}{CMAKE_INSTALL_PREFIX}/doc/mds" )' \
      --replace 'set ( INSTALL_DIR_SHARE       "${"$"}{INSTALL_DIR_PREFIX}share/mds" )' 'set ( INSTALL_DIR_SHARE       "${"$"}{CMAKE_INSTALL_PREFIX}/share/mds" )' \
      --replace 'set ( INSTALL_DIR_DEMOPROJECT "${"$"}{INSTALL_DIR_PREFIX}share/mds/demoproject" )' 'set ( INSTALL_DIR_DEMOPROJECT "${"$"}{CMAKE_INSTALL_PREFIX}/share/mds/demoproject" )' \
      --replace 'set ( INSTALL_DIR_INCLUDE     "${"$"}{INSTALL_DIR_PREFIX}include/mds" )' 'set ( INSTALL_DIR_INCLUDE     "${"$"}{CMAKE_INSTALL_PREFIX}/include/mds" )' \
      --replace 'set ( INSTALL_DIR_MAIN_SHARE    "/usr/share" )' 'set ( INSTALL_DIR_MAIN_SHARE    "${"$"}{CMAKE_INSTALL_PREFIX}/share" )'

    # Disable documentation subdir (requires LaTeX toolchain not available)
    substituteInPlace CMakeLists.txt \
      --replace 'add_subdirectory ( docs )' '# add_subdirectory ( docs ) - disabled for Nix build'

    # Fix Editor module to include binary directories of all EditorWidgets it depends on
    substituteInPlace GUI/widgets/Editor/CMakeLists.txt \
      --replace 'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )' \
                'include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/JumpToLine" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/JumpToLine" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/Find" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/Find" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/FindAndReplace" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/FindAndReplace" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/EditorWidgets/ErrorDialog" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/EditorWidgets/ErrorDialog" )
QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )'

    # Fix PicoBlazeGrid module to include binary directories of TimeWidget it depends on
    substituteInPlace GUI/widgets/PicoBlazeGrid/CMakeLists.txt \
      --replace 'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )' \
                'include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/TimeWidget" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/TimeWidget" )
QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )'

    # Fix DockManager module to include binary directories of all widget dependencies
    substituteInPlace GUI/widgets/DockManager/CMakeLists.txt \
      --replace 'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )' \
                'include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/CallWatcher" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/CallWatcher" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/RegWatcher" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/RegWatcher" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/ExtAppOutput" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/ExtAppOutput" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/PicoBlazeGrid" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/PicoBlazeGrid" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/BreakpointList" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/BreakpointList" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/BookmarkList" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/BookmarkList" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/TabBar" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/TabBar" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/Editor" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/Editor" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/CompileInfo" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/CompileInfo" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/WelcomeScr" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/WelcomeScr" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/AsmMacroAnalyser" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/AsmMacroAnalyser" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/HelpDockWidget" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/HelpDockWidget" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/HelpWidget" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/HelpWidget" )
QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )'

    # Fix DockUi module to include binary directories of all widget dependencies
    substituteInPlace GUI/widgets/DockUi/CMakeLists.txt \
      --replace 'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )' \
                'include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/CallWatcher" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/CallWatcher" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/RegWatcher" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/RegWatcher" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/ExtAppOutput" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/ExtAppOutput" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/PicoBlazeGrid" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/PicoBlazeGrid" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/BreakpointList" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/BreakpointList" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/BookmarkList" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/BookmarkList" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/CompileInfo" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/CompileInfo" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/WelcomeScr" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/WelcomeScr" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/AsmMacroAnalyser" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/AsmMacroAnalyser" )
include_directories ( "${"$"}{CMAKE_SOURCE_DIR}/GUI/widgets/HelpDockWidget" "${"$"}{CMAKE_BINARY_DIR}/GUI/widgets/HelpDockWidget" )
QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${"$"}{SAMPLE_MOC_HDRS} )'

    # Fix Boost 1.60 filesystem compatibility - remove custom append template
    substituteInPlace utilities/os/os.cxx \
      --replace 'namespace boost
{
    #if BOOST_VERSION <= 104800
        namespace filesystem3
    #else
        namespace filesystem
    #endif
    {
        template < >
            path & path::append< typename path::iterator > ( typename path::iterator begin,
                                                             typename path::iterator end,
                                                             const codecvt_type & /*cvt*/ )
            {
                for( ; begin != end ; ++begin )
                {
                    *this /= *begin;
                }

                return *this;
            }
    }
}' \
                'namespace boost
{
    // Removed custom append implementation - incompatible with Boost 1.60
}'

    # Fix Boost 1.60 filesystem compatibility - use loop instead of append()
    substituteInPlace utilities/os/os.cxx \
      --replace 'ret.append ( itrTo, a_To.end() );' \
                'for ( ; itrTo != a_To.end(); ++itrTo ) { ret /= *itrTo; }'

    # Disable IS_NEWER_THAN optimization in FLEX_TARGET_IMPROVED - doesn't work in Nix clean builds
    substituteInPlace FlexBisonPair.cmake \
      --replace 'macro ( FLEX_TARGET_IMPROVED )
    if ( "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{ARGV1}" IS_NEWER_THAN "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{ARGV2}" )
        FLEX_TARGET ( ${"$"}{ARGV} )
    else()
        set ( FLEX_${"$"}{ARGV0}_OUTPUTS "${"$"}{ARGV2}" )
    endif()
endmacro()' \
                'macro ( FLEX_TARGET_IMPROVED )
    FLEX_TARGET ( ${"$"}{ARGV} )
endmacro()'

    # Disable IS_NEWER_THAN optimization and add DEFINES_FILE support in BISON_TARGET_IMPROVED
    substituteInPlace FlexBisonPair.cmake \
      --replace 'macro ( BISON_TARGET_IMPROVED )
    if ( "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{ARGV1}" IS_NEWER_THAN "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{ARGV2}" )
        BISON_TARGET ( ${"$"}{ARGV} )
    else()
        set ( BISON_${"$"}{ARGV0}_OUTPUTS "${"$"}{ARGV2}" )
    endif()
endmacro()' \
                'macro ( BISON_TARGET_IMPROVED Name Input Output )
    # Get base name without extension for header file
    get_filename_component(OutputBase "${"$"}{Output}" NAME_WE)
    get_filename_component(OutputDir "${"$"}{Output}" PATH)
    set(HeaderFile "${"$"}{OutputDir}/${"$"}{OutputBase}.h")
    # Call BISON_TARGET with DEFINES_FILE to generate header
    BISON_TARGET ( ${"$"}{Name} "${"$"}{Input}" "${"$"}{Output}" DEFINES_FILE "${"$"}{HeaderFile}" ${"$"}{ARGN} )
endmacro()'

    # Remove VERBOSE option from bison calls - causes path issues
    substituteInPlace FlexBisonPair.cmake \
      --replace 'BISON_TARGET_IMPROVED ( ${"$"}{ParserTarget} "${"$"}{ParserTarget}.y" "${"$"}{ParserTarget}.cxx" VERBOSE "${"$"}{ParserTarget}.output" )' \
                'BISON_TARGET_IMPROVED ( ${"$"}{ParserTarget} "${"$"}{ParserTarget}.y" "${"$"}{ParserTarget}.cxx" )'

    # Use absolute paths for flex/bison outputs and add dependency
    substituteInPlace FlexBisonPair.cmake \
      --replace 'FLEX_TARGET_IMPROVED  ( ${"$"}{LexerTarget} "${"$"}{LexerTarget}.l" "${"$"}{LexerTarget}.cxx" )
    BISON_TARGET_IMPROVED ( ${"$"}{ParserTarget} "${"$"}{ParserTarget}.y" "${"$"}{ParserTarget}.cxx" )' \
                'FLEX_TARGET_IMPROVED  ( ${"$"}{LexerTarget} "${"$"}{CMAKE_CURRENT_SOURCE_DIR}/${"$"}{LexerTarget}.l" "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{LexerTarget}.cxx" )
    BISON_TARGET_IMPROVED ( ${"$"}{ParserTarget} "${"$"}{CMAKE_CURRENT_SOURCE_DIR}/${"$"}{ParserTarget}.y" "${"$"}{CMAKE_CURRENT_BINARY_DIR}/${"$"}{ParserTarget}.cxx" )
    ADD_FLEX_BISON_DEPENDENCY ( ${"$"}{LexerTarget} ${"$"}{ParserTarget} )'

    # Disable building device specification files - they cause dependency/path issues in Nix builds
    # These are auxiliary precompiled include files that can be generated on-demand by the IDE
    substituteInPlace compiler/include/assembler/PicoBlaze/CMakeLists.txt \
      --replace '# Build device specification files.
foreach ( PROCESSOR "kcpsm1" "kcpsm1cpld" "kcpsm2" "kcpsm3" "kcpsm6" )' \
                '# Build device specification files - DISABLED for Nix build
# These auxiliary files can be generated on-demand by the IDE
if ( FALSE )
foreach ( PROCESSOR "kcpsm1" "kcpsm1cpld" "kcpsm2" "kcpsm3" "kcpsm6" )' \
      --replace 'endforeach ( PROCESSOR )' 'endforeach ( PROCESSOR )
endif()'

    substituteInPlace GUI/resources/projects/MDSExample/CMakeLists.txt \
      --replace 'file ( GLOB PSM_FILES *.psm )
foreach ( PSM_FILE ${"$"}{PSM_FILES} )' 'file ( GLOB PSM_FILES *.psm )
if ( FALSE )
foreach ( PSM_FILE ${"$"}{PSM_FILES} )' \
      --replace 'endforeach ( PSM_FILE )' 'endforeach ( PSM_FILE )
endif()'
  '';

  nativeBuildInputs = with oldPkgs; [ cmake flex bison python3 patchelf ];
  buildInputs = with oldPkgs; [ qt4 boost ];

  # Disable LTO (Link Time Optimization) which causes issues with old code
  NIX_CFLAGS_COMPILE = "-fno-lto";
  NIX_LDFLAGS = "-fno-lto";

  # Use single-threaded build to avoid race conditions with flex/bison
  enableParallelBuilding = false;

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DINDEPENDENT_PACKAGES=OFF"
    "-DTEST_MEMCHECK=OFF"
    "-DCOLOR_GCC=OFF"
    "-DTEST_COVERAGE=OFF"
    "-DBUILD_TESTING=OFF"
  ];

  postInstall = let
    runtimeLibs = oldPkgs.lib.makeLibraryPath [ oldPkgs.qt4 oldPkgs.boost oldPkgs.stdenv.cc.cc.lib ];
    ldso = "${oldPkgs.glibc}/lib/ld-linux-x86-64.so.2";
    fontconfigPath = "${oldPkgs.fontconfig}/etc/fonts";
    wrapTargets = [
      "mds-ide"
      "mds-translator"
      "mds-proc-sim"
      "mds-disasm"
      "mds-compiler"
    ];
    wrapTargetsString = builtins.concatStringsSep " " wrapTargets;
  in ''
    for exe in $out/bin/*; do
      if [ -x "$exe" ] && patchelf --print-interpreter "$exe" >/dev/null 2>&1; then
        patchelf --set-interpreter ${ldso} \
                 --set-rpath "$out/lib:$out/lib/mds:${runtimeLibs}" \
                 "$exe"
      fi
    done

    fontsConf="$out/etc/mds-fonts.conf"
    mkdir -p "$out/etc"
    cat > "$fontsConf" <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>${oldPkgs.dejavu_fonts}/share/fonts</dir>
</fontconfig>
EOF

    for target in ${wrapTargetsString}; do
      exe="$out/bin/$target"
      if [ -x "$exe" ] && [ ! -h "$exe" ]; then
        mv "$exe" "$exe".orig
        cat > "$exe" <<EOF
#!/bin/sh
export FONTCONFIG_FILE=$fontsConf
export FONTCONFIG_PATH=${fontconfigPath}
exec "$exe".orig "\$@"
EOF
        chmod +x "$exe"
      fi
    done
  '';

  meta = with oldPkgs.lib; {
    description = "Picoblaze IDE - simulator, compiler, disassembler and more";
    longDescription = ''
      MDS provides all the necessary functionality to develop software part of a
      PicoBlaze application, including source code editor, assembler, disassembler,
      and simulator. Besides that there is also a number of tools and functions to
      make your work easier, the sole purpose of MDS is to save your time and
      enable development of more complex applications.
    '';
    homepage = "https://github.com/AbyssAbbeba/MDS-picoblaze-AVR-ide";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
