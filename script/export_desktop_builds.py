#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys
import zipfile


BUILD_TARGETS = (
    {
        "preset": "Linux/X11",
        "export_path": "build/linux/UltimateMyanmarTypingWizard.x86_64",
        "archive_name": "ultimate-myanmar-typing-wizard-linux-x86_64.zip",
    },
    {
        "preset": "Windows Desktop",
        "export_path": "build/windows/UltimateMyanmarTypingWizard.exe",
        "archive_name": "ultimate-myanmar-typing-wizard-windows-x86_64.zip",
    },
    {
        "preset": "macOS",
        "export_path": "build/mac/UltimateMyanmarTypingWizard.app",
        "archive_name": "ultimate-myanmar-typing-wizard-macos-universal.zip",
    },
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export desktop Godot presets and package them for release uploads.",
    )
    parser.add_argument(
        "--godot-bin",
        default="godot",
        help="Godot executable to use. Default: godot.",
    )
    parser.add_argument(
        "--skip-import",
        action="store_true",
        help="Skip the initial Godot import pass.",
    )
    return parser.parse_args()


def run_command(command: list[str], *, cwd: Path) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def package_path(source_path: Path, output_zip: Path) -> None:
    output_zip.parent.mkdir(parents=True, exist_ok=True)
    if output_zip.exists():
        output_zip.unlink()

    with zipfile.ZipFile(
        output_zip,
        mode="w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    ) as archive:
        if source_path.is_file():
            archive.write(source_path, arcname=source_path.name)
            return

        for path in sorted(source_path.rglob("*")):
            if not path.is_file():
                continue
            archive.write(path, arcname=path.relative_to(source_path.parent))


def main() -> int:
    args = parse_args()
    project_root = Path(__file__).resolve().parent.parent
    dist_dir = project_root / "dist"

    try:
        if not args.skip_import:
            run_command(
                [
                    args.godot_bin,
                    "--headless",
                    "--recovery-mode",
                    "--path",
                    str(project_root),
                    "--import",
                ],
                cwd=project_root,
            )

        for target in BUILD_TARGETS:
            export_path = project_root / target["export_path"]
            export_path.parent.mkdir(parents=True, exist_ok=True)

            run_command(
                [
                    args.godot_bin,
                    "--headless",
                    "--recovery-mode",
                    "--path",
                    str(project_root),
                    "--export-release",
                    target["preset"],
                    str(export_path),
                ],
                cwd=project_root,
            )

            archive_path = dist_dir / target["archive_name"]
            package_path(export_path, archive_path)
            print("Created %s" % archive_path)

    except FileNotFoundError:
        print(
            "Could not find the Godot executable: %s" % args.godot_bin,
            file=sys.stderr,
        )
        return 1
    except subprocess.CalledProcessError as exc:
        return exc.returncode

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
