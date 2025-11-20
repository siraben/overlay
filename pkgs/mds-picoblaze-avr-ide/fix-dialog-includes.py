#!/usr/bin/env python3

"""
Inject shared include_directories for GUI dialogs and mainform.

This keeps the CMake files closer to upstream while still ensuring that
generated ui_*.h headers from other subdirectories are visible.
"""

from pathlib import Path


ROOT = Path(".").resolve()


def insert_snippet(file: Path, marker: str, addition: str) -> None:
    text = file.read_text()
    if addition in text:
        return
    if marker not in text:
        raise SystemExit("marker not found in {}".format(file))
    file.write_text(text.replace(marker, marker + addition, 1))


def main() -> None:
    dialogs_path = ROOT / "GUI" / "dialogs" / "CMakeLists.txt"
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
    insert_snippet(dialogs_path, dialogs_marker, dialogs_addition)

    mainform_path = ROOT / "GUI" / "mainform" / "CMakeLists.txt"
    mainform_marker = "project ( Mainform )\n\n"
    tools_dir = ROOT / "GUI" / "widgets" / "Tools"
    tool_lines = []
    if tools_dir.is_dir():
        for subdir in sorted(p for p in tools_dir.iterdir() if p.is_dir()):
            name = subdir.name
            tool_lines.append(
                'include_directories ( '
                '"${CMAKE_SOURCE_DIR}/GUI/widgets/Tools/%s" '
                '"${CMAKE_BINARY_DIR}/GUI/widgets/Tools/%s" )\n' % (name, name)
            )

    mainform_addition = (
        'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/project" '
        '"${CMAKE_BINARY_DIR}/GUI/project" )\n'
        'include_directories ( "${CMAKE_SOURCE_DIR}/GUI/dialogs/projectdlg" '
        '"${CMAKE_BINARY_DIR}/GUI/dialogs/projectdlg" )\n'
        + "".join(tool_lines)
        + "\n"
    )
    insert_snippet(mainform_path, mainform_marker, mainform_addition)


if __name__ == "__main__":
    main()
