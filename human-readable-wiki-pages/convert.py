#!/usr/bin/env python3
"""
Converts the markdown wiki pages to Factorio locales and Lua GUI code.

Reads .md files from the same directory as this script, then patches:
  - locale/en/*.cfg            (searches all .cfg files for '; BEGIN/END GENERATED' markers)
  - classes/guis/**/*.lua      (searches all .lua files for '-- BEGIN/END GENERATED' markers)

Defaults to locale/en/guis.cfg and classes/guis/city-view-pages/howto-pages.lua when
appending new sentinel blocks for a page that doesn't have them yet.
For the Lua file the generated add_page wrapper uses 'how-tos' as category and
{name}-text1 as localised_name.
"""

import argparse
import re
import time
from enum import Enum, auto
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
MOD_ROOT = SCRIPT_DIR.parent
LOCALE_DIR = MOD_ROOT / "locale" / "en"
DEFAULT_LOCALE_FILE = LOCALE_DIR / "guis.cfg"
CODE_DIR = MOD_ROOT / "classes" / "guis"
DEFAULT_CODE_FILE = CODE_DIR / "city-view-pages" / "howto-pages.lua"

CODE_INDENT = "        "  # 8 spaces / 2 'tabs'


class LineType(Enum):
    Paragraph = auto()
    H1 = auto()
    H2 = auto()
    H3 = auto()
    List = auto()
    PageLink = auto()
    Separator = auto()


def find_file_with_marker(directory, glob, marker):
    """Return the first file matching glob in directory that contains marker, or None."""
    for path in sorted(directory.glob(glob)):
        if marker in path.read_text(encoding="utf-8"):
            return path
    return None


def apply_markup(s):
    s = re.sub(r'\[item=(?P<content>.*?)\]',
               r'[font=default-bold][color=#80CC33] [item=\g<content>] __ITEM__\g<content>__[/color][/font]', s)
    s = re.sub(r'\[fluid=(?P<content>.*?)\]',
               r'[font=default-bold][color=#80CC33] [fluid=\g<content>] __FLUID__\g<content>__[/color][/font]', s)
    s = re.sub(r'\[technology=(?P<content>.*?)\]',
               r'[font=default-bold][color=#80CC33] [technology=\g<content>] __TECHNOLOGY__\g<content>__[/color][/font]', s)
    s = re.sub(r'\[recipe=(?P<content>.*?)\]',
               r'[font=default-bold][color=#80CC33] [recipe=\g<content>] __RECIPE__\g<content>__[/color][/font]', s)
    s = re.sub(r'\[entity=(?P<content>.*?)\]',
               r'[font=default-bold][color=#80CC33] [entity=\g<content>] __ENTITY__\g<content>__[/color][/font]', s)
    s = re.sub(r'\[caste=(?P<content>.*?)\]',
               lambda m: f'[font=default-bold][color=#80CC33] [virtual-signal=signal-{m.group("content")}] {m.group("content").capitalize()}[/color][/font]', s)
    s = re.sub(r'\*\*(?P<content>.*?)\*\*', r'[font=default-bold]\g<content>[/font]', s)
    s = re.sub(r'\*(?P<content>.*?)\*', r'[color=#CCCCCC]\g<content>[/color]', s)
    return s


def classify(s):
    if s.startswith("###"):
        return LineType.H3, s[3:].lstrip()
    if s.startswith("##"):
        return LineType.H2, s[2:].lstrip()
    if s.startswith("#"):
        return LineType.H1, s[1:].lstrip()
    if s.startswith("- "):
        return LineType.List, s[2:]
    if s.startswith("[linked-page="):
        return LineType.PageLink, s
    if s.startswith("---"):
        return LineType.Separator, ""
    return LineType.Paragraph, s


def process_md(filepath):
    name = filepath.stem

    # Group into blank-line-separated blocks; consecutive paragraph lines within a
    # block are merged into a single locale entry (standard markdown convention).
    blocks = []
    current = []
    for line in filepath.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped:
            current.append(stripped)
        elif current:
            blocks.append(current)
            current = []
    if current:
        blocks.append(current)

    elements = []
    for block in blocks:
        first_type, _ = classify(apply_markup(block[0]))
        if first_type == LineType.Paragraph and len(block) > 1:
            merged = " ".join(apply_markup(l) for l in block)
            elements.append({"type": LineType.Paragraph, "text": merged, "locale_key": f"{name}-text{len(elements) + 1}"})
        else:
            for raw in block:
                s = apply_markup(raw)
                line_type, text = classify(s)
                elements.append({"type": line_type, "text": text, "locale_key": f"{name}-text{len(elements) + 1}"})

    locale_content = build_locale(elements)
    code_content = build_code(elements)

    locale_begin = f"; BEGIN GENERATED: {name}"
    locale_end = f"; END GENERATED: {name}"
    locale_file = find_file_with_marker(LOCALE_DIR, "*.cfg", locale_begin) or DEFAULT_LOCALE_FILE
    if not patch_file(locale_file, locale_begin, locale_end, locale_content):
        print(f"  [{name}] No locale sentinel found - appending new section to {DEFAULT_LOCALE_FILE.name}")
        append_to_locale(name, locale_content)
    else:
        print(f"  [{name}] Updated locale in {locale_file.name}")

    code_begin = f"{CODE_INDENT}-- BEGIN GENERATED: {name}"
    code_end = f"{CODE_INDENT}-- END GENERATED: {name}"
    code_file = find_file_with_marker(CODE_DIR, "**/*.lua", code_begin) or DEFAULT_CODE_FILE
    if not patch_file(code_file, code_begin, code_end, code_content):
        print(f"  [{name}] No code sentinel found - appending new add_page block to {DEFAULT_CODE_FILE.name}")
        append_to_code(name, code_content)
    else:
        print(f"  [{name}] Updated code in {code_file.name}")


def build_locale(elements):
    lines = [
        f"{el['locale_key']}={el['text']}"
        for el in elements
        if el["type"] not in (LineType.PageLink, LineType.Separator)
    ]
    return "\n".join(lines) + "\n"


def build_code(elements):
    lines = []
    list_buffer = []
    in_list = False

    def flush_list():
        nonlocal in_list
        in_list = False
        items = f",\n{CODE_INDENT}        ".join(list_buffer)
        lines.append(
            f"{CODE_INDENT}Gui.Elements.Label.list(\n"
            f"{CODE_INDENT}    container,\n"
            f"{CODE_INDENT}    {{\n"
            f"{CODE_INDENT}        {items}\n"
            f"{CODE_INDENT}    }}\n"
            f"{CODE_INDENT})"
        )
        list_buffer.clear()

    for el in elements:
        if in_list and el["type"] != LineType.List:
            flush_list()

        t, k = el["type"], el["locale_key"]

        if t == LineType.Paragraph:
            lines.append(f'{CODE_INDENT}Gui.Elements.Label.paragraph(container, {{"city-view.{k}"}})')
        elif t == LineType.H1:
            lines.append(f'{CODE_INDENT}Gui.Elements.Label.heading_1(container, {{"city-view.{k}"}})')
        elif t == LineType.H2:
            lines.append(f'{CODE_INDENT}Gui.Elements.Label.heading_2(container, {{"city-view.{k}"}})')
        elif t == LineType.H3:
            lines.append(f'{CODE_INDENT}Gui.Elements.Label.heading_3(container, {{"city-view.{k}"}})')
        elif t == LineType.PageLink:
            m = re.match(r'\[linked-page=(?P<category>[\w-]+)/(?P<page>[\w-]+)\]', el["text"])
            if m:
                lines.append(f'{CODE_INDENT}Gui.Elements.Button.page_link(container, "{m.group("category")}", "{m.group("page")}")')
            else:
                print(f"  Warning: malformed page link: {el['text']}")
        elif t == LineType.Separator:
            lines.append(f'{CODE_INDENT}Gui.Elements.Utils.separator_line(container)')
        elif t == LineType.List:
            in_list = True
            list_buffer.append(f'{{"city-view.{k}"}}')

    if list_buffer:
        flush_list()

    return "\n".join(lines) + "\n"


def patch_file(filepath, begin_marker, end_marker, new_content):
    """Replace content between markers. Returns True if markers were found."""
    text = filepath.read_text(encoding="utf-8")
    pattern = re.compile(
        rf"({re.escape(begin_marker)}\n).*?({re.escape(end_marker)})",
        re.DOTALL
    )
    result = [False]

    def replacer(m):
        result[0] = True
        return m.group(1) + new_content + m.group(2)

    new_text = pattern.sub(replacer, text)
    if result[0]:
        filepath.write_text(new_text, encoding="utf-8")
    return result[0]


def append_to_locale(name, content):
    text = DEFAULT_LOCALE_FILE.read_text(encoding="utf-8")
    block = f"\n; BEGIN GENERATED: {name}\n{content}; END GENERATED: {name}\n"
    # Insert before [report-name] section if it exists, otherwise append at end
    if "\n[report-name]" in text:
        text = text.replace("\n[report-name]", block + "\n[report-name]", 1)
    else:
        text = text.rstrip("\n") + "\n" + block
    DEFAULT_LOCALE_FILE.write_text(text, encoding="utf-8")


def append_to_code(name, content):
    text = DEFAULT_CODE_FILE.read_text(encoding="utf-8")
    block = (
        f"\nGui.CityView.add_page {{\n"
        f"    name = \"{name}\",\n"
        f"    category = \"how-tos\",  -- TODO: verify category\n"
        f"    localised_name = {{\"city-view.{name}-text1\"}},\n"
        f"    creator = function(container)\n"
        f"{CODE_INDENT}-- BEGIN GENERATED: {name}\n"
        f"{content}"
        f"{CODE_INDENT}-- END GENERATED: {name}\n"
        f"    end\n"
        f"}}\n"
    )
    DEFAULT_CODE_FILE.write_text(text.rstrip("\n") + "\n" + block, encoding="utf-8")


def watch_mode(md_filter):
    """Watch SCRIPT_DIR for .md changes and reprocess on save. Requires watchdog."""
    try:
        from watchdog.observers import Observer
        from watchdog.events import FileSystemEventHandler
    except ImportError:
        print("Watch mode requires watchdog")
        return

    initial = md_filter or sorted(SCRIPT_DIR.glob("*.md"))
    for filepath in initial:
        print(f"Processing {filepath.name}...")
        process_md(filepath)
    print("\nWatching for changes... (Ctrl+C to stop)")

    class Handler(FileSystemEventHandler):
        def __init__(self):
            self._debounce = {}

        def _handle(self, path):
            if path.suffix != ".md" or path.parent != SCRIPT_DIR:
                return
            if md_filter and path not in md_filter:
                return
            now = time.time()
            if now - self._debounce.get(path, 0) < 0.5:
                return
            self._debounce[path] = now
            print(f"\nChanged: {path.name}")
            process_md(path)

        def on_modified(self, event):
            if not event.is_directory:
                self._handle(Path(event.src_path))

        def on_created(self, event):
            if not event.is_directory:
                self._handle(Path(event.src_path))

        def on_moved(self, event):
            # Handles atomic saves (e.g. VS Code safe-write)
            if not event.is_directory:
                self._handle(Path(event.dest_path))

    observer = Observer()
    observer.schedule(Handler(), str(SCRIPT_DIR), recursive=False)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopped.")
        observer.stop()
    observer.join()


def main():
    parser = argparse.ArgumentParser(description="Convert markdown wiki pages to Factorio locale and Lua code.")
    parser.add_argument("files", nargs="*", metavar="FILE", help="Specific .md files to process (default: all)")
    parser.add_argument("--watch", "-w", action="store_true", help="Watch for .md changes and reprocess automatically (requires watchdog installed)")
    args = parser.parse_args()

    if args.files:
        md_files = []
        for name in args.files:
            path = SCRIPT_DIR / name
            if not path.exists():
                print(f"File not found: {path}")
                return
            md_files.append(path)
    else:
        md_files = sorted(SCRIPT_DIR.glob("*.md"))

    if args.watch:
        watch_mode(md_files if args.files else None)
        return

    if not md_files:
        print("No .md files found.")
        return

    for filepath in md_files:
        print(f"Processing {filepath.name}...")
        process_md(filepath)

    print("Done.")


if __name__ == "__main__":
    main()
