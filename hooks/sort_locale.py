#!/usr/bin/env python3
"""Sorts the entries of tagged blocks in Factorio locale files.

A block is tagged by a comment line that contains "[sorted]", e.g.

    ; Food [sorted]
    apple=Apple
    avocado=Avocado

The block is every "key=value" line that follows the comment directly. It ends at the first blank
line, comment or section header. Blocks without the tag are left alone, because their order is
often deliberate.

Usage:
    sort_locale.py [--check] [FILE ...]

Without files, all .cfg files in locale/ are handled. With --check nothing is written; the exit
code is 1 if a file would change. Without --check the exit code is always 0.
"""

import argparse
import sys
from pathlib import Path

TAG = "[sorted]"
REPO_ROOT = Path(__file__).resolve().parent.parent


def is_entry(line):
    stripped = line.strip()
    return bool(stripped) and not stripped.startswith((";", "#", "[")) and "=" in stripped


def entry_key(line):
    return line.split("=", 1)[0].strip()


def sort_lines(lines):
    """Returns the lines with every tagged block sorted by key."""
    result = []
    index = 0
    while index < len(lines):
        line = lines[index]
        result.append(line)
        index += 1

        if line.lstrip().startswith(";") and TAG in line:
            block = []
            while index < len(lines) and is_entry(lines[index]):
                block.append(lines[index])
                index += 1
            # sorted() is stable: entries with the same key keep their order
            result.extend(sorted(block, key=entry_key))

    return result


def sort_file(path, check):
    """Sorts one file. Returns True if the file was (or would be) changed."""
    # newline="" keeps the line endings exactly as they are
    with open(path, encoding="utf-8", newline="") as file:
        content = file.read()

    lines = content.split("\n")
    sorted_content = "\n".join(sort_lines(lines))
    if sorted_content == content:
        return False

    if not check:
        with open(path, "w", encoding="utf-8", newline="") as file:
            file.write(sorted_content)
    return True


def main():
    parser = argparse.ArgumentParser(description="Sort the tagged blocks of Factorio locale files.")
    parser.add_argument("files", nargs="*", type=Path, help="locale files (default: all in locale/)")
    parser.add_argument("--check", action="store_true", help="don't write, exit with 1 if a file is unsorted")
    args = parser.parse_args()

    files = args.files or sorted((REPO_ROOT / "locale").rglob("*.cfg"))

    changed = [path for path in files if sort_file(path, args.check)]
    for path in changed:
        print(("unsorted: " if args.check else "sorted: ") + str(path))

    sys.exit(1 if args.check and changed else 0)


if __name__ == "__main__":
    main()
