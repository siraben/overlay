#!/usr/bin/env python3

from pathlib import Path
from typing import Iterable

ROOT = Path.cwd()


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write(path: Path, data: str) -> None:
    path.write_text(data, encoding="utf-8")


def replace(path: Path, old: str, new: str, *, count: int = None) -> None:
    text = read(path)
    if old not in text:
        raise SystemExit("pattern not found in {}: {!r}".format(path, old))
    if count is None:
        text = text.replace(old, new)
    else:
        text = text.replace(old, new, count)
    write(path, text)


def prepend_if_missing(path: Path, snippet: str) -> None:
    text = read(path)
    if snippet in text:
        return
    write(path, snippet + text)


def insert_after_marker(path: Path, marker: str, addition: str) -> None:
    text = read(path)
    if addition in text:
        return
    if marker not in text:
        raise SystemExit("marker not found in {}".format(path))
    write(path, text.replace(marker, marker + addition, 1))


def ensure_cmake_includes(paths: Iterable[Path], needles: Iterable[str]) -> None:
    snippet = 'include_directories ( "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" )\n'
    for path in paths:
        text = read(path)
        if snippet in text:
            continue
        if not any(needle in text for needle in needles):
            continue
        write(path, snippet + text)


def update_include_blocks() -> None:
    replacements = [
        ("GUI/widgets/sim/CMakeLists.txt", "${CMAKE_CURRENT_BINARY_DIR}", "${CMAKE_CURRENT_SOURCE_DIR}"),
        ("utilities/AdjSimProcDef/CMakeLists.txt", "include_directories ( ${CMAKE_SOURCE_DIR} )", "include_directories ( ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} )"),
        (
            "HW/Avr8UsbProg/CMakeLists.txt",
            'include_directories ( "${CMAKE_SOURCE_DIR}/utilities/MCUDataFiles/"',
            'include_directories ( ${CMAKE_CURRENT_BINARY_DIR} "${CMAKE_SOURCE_DIR}/utilities/MCUDataFiles/"',
        ),
    ]
    for rel, old, new in replacements:
        replace(ROOT / rel, old, new)

    replace(
        ROOT / "compiler/modules/C/core/CMakeLists.txt",
        'include_directories ( "${CMAKE_SOURCE_DIR}"\n                      "${CMAKE_SOURCE_DIR}/compiler/core/" )\n',
        'include_directories ( "${CMAKE_SOURCE_DIR}"\n                      "${CMAKE_SOURCE_DIR}/compiler/core/" )\ninclude_directories ( "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" )\n',
        count=1,
    )

    assembler_paths = sorted((ROOT / "compiler/modules/assembler").glob("*/CMakeLists.txt"))
    ensure_cmake_includes(assembler_paths, ("flex_bison_pair", "FLEX_TARGET", "BISON_TARGET"))

    gui_paths = sorted((ROOT / "GUI").rglob("CMakeLists.txt"))
    ensure_cmake_includes(gui_paths, ("qt4_wrap_ui", "QT4_WRAP_UI"))


def propagate_widget_includes() -> None:
    replace(
        ROOT / "GUI/widgets/CMakeLists.txt",
        'set(CMAKE_VERBOSE_MAKEFILE OFF)\n\n',
        'set(CMAKE_VERBOSE_MAKEFILE OFF)\n\n# Ensure each widget directory is visible to all children for both source and generated headers.\nfile(GLOB WIDGET_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/*")\nforeach(widget_dir ${WIDGET_INCLUDE_DIRS})\n    if (IS_DIRECTORY ${widget_dir})\n        get_filename_component(widget_name ${widget_dir} NAME)\n        include_directories("${widget_dir}")\n        include_directories("${CMAKE_BINARY_DIR}/GUI/widgets/${widget_name}")\n    endif()\nendforeach()\n\n',
    )

    replace(
        ROOT / "GUI/project/project.h",
        '#include <set>',
        '#include <set>\n#include <vector>\n#include <string>\n#include <utility>',
    )

    replace(
        ROOT / "GUI/CMakeLists.txt",
        'include_directories ( ${CMAKE_BINARY_DIR}\n                        "${CMAKE_CURRENT_BINARY_DIR}/mainform/" )',
        'include_directories ( ${CMAKE_BINARY_DIR}\n                        "${CMAKE_CURRENT_BINARY_DIR}/mainform/" )\n\n# Expose all widget include paths (source + binary) to the entire GUI tree.\nset(MDS_WIDGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/widgets")\nfile(GLOB GUI_WIDGET_INCLUDE_DIRS "${MDS_WIDGET_DIR}/*")\nforeach(widget_dir ${GUI_WIDGET_INCLUDE_DIRS})\n    if (IS_DIRECTORY ${widget_dir})\n        get_filename_component(widget_name ${widget_dir} NAME)\n        include_directories("${widget_dir}")\n        include_directories("${CMAKE_BINARY_DIR}/GUI/widgets/${widget_name}")\n    endif()\nendforeach()\n\n# Expose all dialog include paths as well.\nset(MDS_DIALOG_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dialogs")\nfile(GLOB GUI_DIALOG_INCLUDE_DIRS "${MDS_DIALOG_DIR}/*")\nforeach(dialog_dir ${GUI_DIALOG_INCLUDE_DIRS})\n    if (IS_DIRECTORY ${dialog_dir})\n        get_filename_component(dialog_name ${dialog_dir} NAME)\n        include_directories("${dialog_dir}")\n        include_directories("${CMAKE_BINARY_DIR}/GUI/dialogs/${dialog_name}")\n    endif()\nendforeach()',
    )

    for rel in (
        "GUI/dialogs/projectcfg/CMakeLists.txt",
        "GUI/dialogs/projectdlg/CMakeLists.txt",
    ):
        replace(
            ROOT / rel,
            'set(CMAKE_VERBOSE_MAKEFILE OFF)\n\n',
            'set(CMAKE_VERBOSE_MAKEFILE OFF)\n\ninclude_directories ( "${CMAKE_SOURCE_DIR}/GUI/project" "${CMAKE_BINARY_DIR}/GUI/project" )\n\n',
        )

    patch_dialog_and_mainform_includes()


def patch_widget_dependencies() -> None:
    widgets = {
        "GUI/widgets/Editor/CMakeLists.txt": [
            "EditorWidgets/JumpToLine",
            "EditorWidgets/Find",
            "EditorWidgets/FindAndReplace",
            "EditorWidgets/ErrorDialog",
        ],
        "GUI/widgets/PicoBlazeGrid/CMakeLists.txt": ["TimeWidget"],
        "GUI/widgets/DockManager/CMakeLists.txt": [
            "CallWatcher",
            "RegWatcher",
            "ExtAppOutput",
            "PicoBlazeGrid",
            "BreakpointList",
            "BookmarkList",
            "TabBar",
            "Editor",
            "CompileInfo",
            "WelcomeScr",
            "AsmMacroAnalyser",
            "HelpDockWidget",
            "HelpWidget",
        ],
        "GUI/widgets/DockUi/CMakeLists.txt": [
            "CallWatcher",
            "RegWatcher",
            "ExtAppOutput",
            "PicoBlazeGrid",
            "BreakpointList",
            "BookmarkList",
            "CompileInfo",
            "WelcomeScr",
            "AsmMacroAnalyser",
            "HelpDockWidget",
        ],
    }

    for rel, deps in widgets.items():
        snippet_lines = []
        for dep in deps:
            snippet_lines.append(
                'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/%s" "${CMAKE_BINARY_DIR}/GUI/widgets/%s" )'
                % (dep, dep)
            )
        snippet = "\n".join(snippet_lines) + "\nQT4_WRAP_CPP( SAMPLE_MOC_SRCS ${SAMPLE_MOC_HDRS} )"
        replace(
            ROOT / rel,
            'QT4_WRAP_CPP( SAMPLE_MOC_SRCS ${SAMPLE_MOC_HDRS} )',
            snippet,
        )


def adjust_project_configuration() -> None:
    replace(
        ROOT / "moraviascript/CMakeLists.txt",
        'project ( MScript )',
        'project ( MScript )\ninclude_directories ( "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}" )',
    )

    replace(
        ROOT / "GUI/main.cpp",
        '#ifndef MDS_VARIANT_TRIAL',
        '#if 0 /* License verification disabled for Nix build */',
    )

    cmake_root = ROOT / "CMakeLists.txt"
    layout_replacements = {
        'set ( INSTALL_DIR_PREFIX "/usr/" )': 'set ( INSTALL_DIR_PREFIX "${CMAKE_INSTALL_PREFIX}/" )',
        'set ( INSTALL_DIR_BIN         "${INSTALL_DIR_PREFIX}bin" )': 'set ( INSTALL_DIR_BIN         "${CMAKE_INSTALL_PREFIX}/bin" )',
        'set ( INSTALL_DIR_LIB         "${INSTALL_DIR_PREFIX}lib/mds" )': 'set ( INSTALL_DIR_LIB         "${CMAKE_INSTALL_PREFIX}/lib/mds" )',
        'set ( INSTALL_DIR_DOC         "${INSTALL_DIR_PREFIX}doc/mds" )': 'set ( INSTALL_DIR_DOC         "${CMAKE_INSTALL_PREFIX}/doc/mds" )',
        'set ( INSTALL_DIR_SHARE       "${INSTALL_DIR_PREFIX}share/mds" )': 'set ( INSTALL_DIR_SHARE       "${CMAKE_INSTALL_PREFIX}/share/mds" )',
        'set ( INSTALL_DIR_DEMOPROJECT "${INSTALL_DIR_PREFIX}share/mds/demoproject" )': 'set ( INSTALL_DIR_DEMOPROJECT "${CMAKE_INSTALL_PREFIX}/share/mds/demoproject" )',
        'set ( INSTALL_DIR_INCLUDE     "${INSTALL_DIR_PREFIX}include/mds" )': 'set ( INSTALL_DIR_INCLUDE     "${CMAKE_INSTALL_PREFIX}/include/mds" )',
        'set ( INSTALL_DIR_MAIN_SHARE    "/usr/share" )': 'set ( INSTALL_DIR_MAIN_SHARE    "${CMAKE_INSTALL_PREFIX}/share" )',
    }
    for old, new in layout_replacements.items():
        replace(cmake_root, old, new)

    replace(cmake_root, 'add_subdirectory ( docs )', '# add_subdirectory ( docs ) - disabled for Nix build')


def patch_boost_filesystem() -> None:
    replace(
        ROOT / "utilities/os/os.cxx",
        'namespace boost\n{\n    #if BOOST_VERSION <= 104800\n        namespace filesystem3\n    #else\n        namespace filesystem\n    #endif\n    {\n        template < >\n            path & path::append< typename path::iterator > ( typename path::iterator begin,\n                                                             typename path::iterator end,\n                                                             const codecvt_type & /*cvt*/ )\n            {\n                for( ; begin != end ; ++begin )\n                {\n                    *this /= *begin;\n                }\n\n                return *this;\n            }\n    }\n}',
        'namespace boost\n{\n    // Removed custom append implementation - incompatible with Boost 1.60\n}',
    )

    replace(
        ROOT / "utilities/os/os.cxx",
        'ret.append ( itrTo, a_To.end() );',
        'for ( ; itrTo != a_To.end(); ++itrTo ) { ret /= *itrTo; }',
    )


def patch_flex_bison_macros() -> None:
    flex_path = ROOT / "FlexBisonPair.cmake"
    replace(
        flex_path,
        'macro ( FLEX_TARGET_IMPROVED )\n    if ( "${CMAKE_CURRENT_BINARY_DIR}/${ARGV1}" IS_NEWER_THAN "${CMAKE_CURRENT_BINARY_DIR}/${ARGV2}" )\n        FLEX_TARGET ( ${ARGV} )\n    else()\n        set ( FLEX_${ARGV0}_OUTPUTS "${ARGV2}" )\n    endif()\nendmacro()',
        'macro ( FLEX_TARGET_IMPROVED )\n    FLEX_TARGET ( ${ARGV} )\nendmacro()',
    )

    replace(
        flex_path,
        'macro ( BISON_TARGET_IMPROVED )\n    if ( "${CMAKE_CURRENT_BINARY_DIR}/${ARGV1}" IS_NEWER_THAN "${CMAKE_CURRENT_BINARY_DIR}/${ARGV2}" )\n        BISON_TARGET ( ${ARGV} )\n    else()\n        set ( BISON_${ARGV0}_OUTPUTS "${ARGV2}" )\n    endif()\nendmacro()',
        'macro ( BISON_TARGET_IMPROVED Name Input Output )\n    # Get base name without extension for header file\n    get_filename_component(OutputBase "${Output}" NAME_WE)\n    get_filename_component(OutputDir "${Output}" PATH)\n    set(HeaderFile "${OutputDir}/${OutputBase}.h")\n    # Call BISON_TARGET with DEFINES_FILE to generate header\n    BISON_TARGET ( ${Name} "${Input}" "${Output}" DEFINES_FILE "${HeaderFile}" ${ARGN} )\nendmacro()',
    )

    replace(
        flex_path,
        'BISON_TARGET_IMPROVED ( ${ParserTarget} "${ParserTarget}.y" "${ParserTarget}.cxx" VERBOSE "${ParserTarget}.output" )',
        'BISON_TARGET_IMPROVED ( ${ParserTarget} "${ParserTarget}.y" "${ParserTarget}.cxx" )',
    )

    replace(
        flex_path,
        'FLEX_TARGET_IMPROVED  ( ${LexerTarget} "${LexerTarget}.l" "${LexerTarget}.cxx" )\n    BISON_TARGET_IMPROVED ( ${ParserTarget} "${ParserTarget}.y" "${ParserTarget}.cxx" )',
        'FLEX_TARGET_IMPROVED  ( ${LexerTarget} "${CMAKE_CURRENT_SOURCE_DIR}/${LexerTarget}.l" "${CMAKE_CURRENT_BINARY_DIR}/${LexerTarget}.cxx" )\n    BISON_TARGET_IMPROVED ( ${ParserTarget} "${CMAKE_CURRENT_SOURCE_DIR}/${ParserTarget}.y" "${CMAKE_CURRENT_BINARY_DIR}/${ParserTarget}.cxx" )\n    ADD_FLEX_BISON_DEPENDENCY ( ${LexerTarget} ${ParserTarget} )',
    )


def disable_auxiliary_generators() -> None:
    replace(
        ROOT / "compiler/include/assembler/PicoBlaze/CMakeLists.txt",
        '# Build device specification files.\nforeach ( PROCESSOR "kcpsm1" "kcpsm1cpld" "kcpsm2" "kcpsm3" "kcpsm6" )',
        '# Build device specification files - DISABLED for Nix build\n# These auxiliary files can be generated on-demand by the IDE\nif ( FALSE )\nforeach ( PROCESSOR "kcpsm1" "kcpsm1cpld" "kcpsm2" "kcpsm3" "kcpsm6" )',
    )

    replace(
        ROOT / "compiler/include/assembler/PicoBlaze/CMakeLists.txt",
        'endforeach ( PROCESSOR )',
        'endforeach ( PROCESSOR )\nendif()',
    )

    demo_path = ROOT / "GUI/resources/projects/MDSExample/CMakeLists.txt"
    replace(
        demo_path,
        'file ( GLOB PSM_FILES *.psm )\nforeach ( PSM_FILE ${PSM_FILES} )',
        'file ( GLOB PSM_FILES *.psm )\nif ( FALSE )\nforeach ( PSM_FILE ${PSM_FILES} )',
    )
    replace(demo_path, 'endforeach ( PSM_FILE )', 'endforeach ( PSM_FILE )\nendif()')

    install_snippet = (
        "# Install demo project source files without invoking mds-compiler.\n"
        "install ( FILES ${PSM_FILES} DESTINATION ${INSTALL_DIR_DEMOPROJECT} )\n\n"
    )
    marker = '# List of additional files that will be cleaned as a part of the "make clean" stage.'
    insert_after_marker(demo_path, marker, install_snippet)


def patch_dialog_and_mainform_includes() -> None:
    dialogs_path = ROOT / "GUI/dialogs/CMakeLists.txt"
    dialogs_marker = (
        "# ------------------------------------------------------------------------------\n"
        "# GENERAL OPTIONS\n"
        "# ------------------------------------------------------------------------------\n\n"
    )
    dialogs_addition = (
        'file(GLOB DIALOG_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/*")\n'
        "foreach(dialog_dir ${DIALOG_INCLUDE_DIRS})\n"
        "    if (IS_DIRECTORY ${dialog_dir})\n"
        "        get_filename_component(dialog_name ${dialog_dir} NAME)\n"
        '        include_directories("${dialog_dir}")\n'
        '        include_directories("${CMAKE_BINARY_DIR}/GUI/dialogs/${dialog_name}")\n'
        "    endif()\n"
        "endforeach()\n\n"
    )
    insert_after_marker(dialogs_path, dialogs_marker, dialogs_addition)

    mainform_path = ROOT / "GUI/mainform/CMakeLists.txt"
    mainform_marker = "project ( Mainform )\n\n"
    tools_dir = ROOT / "GUI/widgets/Tools"
    tool_lines = []
    if tools_dir.is_dir():
        for subdir in sorted(p for p in tools_dir.iterdir() if p.is_dir()):
            name = subdir.name
            tool_lines.append(
                'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/widgets/Tools/%s" "${CMAKE_BINARY_DIR}/GUI/widgets/Tools/%s" )\n'
                % (name, name)
            )

    mainform_addition = (
        'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/project" "${CMAKE_BINARY_DIR}/GUI/project" )\n'
        'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/dialogs/projectdlg" "${CMAKE_BINARY_DIR}/GUI/dialogs/projectdlg" )\n'
        + "".join(tool_lines)
        + "\n"
    )
    insert_after_marker(mainform_path, mainform_marker, mainform_addition)


def run() -> None:
    update_include_blocks()
    propagate_widget_includes()
    patch_widget_dependencies()
    adjust_project_configuration()
    patch_boost_filesystem()
    patch_flex_bison_macros()
    disable_auxiliary_generators()


if __name__ == "__main__":
    run()
