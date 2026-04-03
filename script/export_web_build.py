#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile


STATIC_FILES = (
    ("Web/favicon.png", "favicon.png"),
    ("Web/robots.txt", "robots.txt"),
    ("Web/sitemap.xml", "sitemap.xml"),
    ("Assets/Icons/Logo.png", "logo.png"),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export the Godot Web preset and package the result.",
    )
    parser.add_argument(
        "--godot-bin",
        default=os.environ.get("GODOT_BIN", "godot"),
        help="Godot executable to use. Default: GODOT_BIN or 'godot'.",
    )
    parser.add_argument(
        "--skip-import",
        action="store_true",
        help="Skip the initial Godot import pass.",
    )
    parser.add_argument(
        "--skip-package",
        action="store_true",
        help="Skip creating the dist zip artifact.",
    )
    return parser.parse_args()


def run_command(command: list[str], *, cwd: Path) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, check=True)


def package_directory(source_dir: Path, output_zip: Path) -> None:
    output_zip.parent.mkdir(parents=True, exist_ok=True)
    if output_zip.exists():
        output_zip.unlink()

    with zipfile.ZipFile(
        output_zip,
        mode="w",
        compression=zipfile.ZIP_DEFLATED,
        compresslevel=9,
    ) as archive:
        for path in sorted(source_dir.rglob("*")):
            if not path.is_file():
                continue
            archive.write(path, arcname=path.relative_to(source_dir))


def main() -> int:
    args = parse_args()
    project_root = Path(__file__).resolve().parent.parent
    web_build_dir = project_root / "build" / "web"
    dist_zip = project_root / "dist" / "ultimate-myanmar-typing-wizard-web.zip"

    web_build_dir.mkdir(parents=True, exist_ok=True)

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

        run_command(
            [
                args.godot_bin,
                "--headless",
                "--recovery-mode",
                "--path",
                str(project_root),
                "--export-release",
                "Web",
                str(web_build_dir / "index.html"),
            ],
            cwd=project_root,
        )
    except FileNotFoundError:
        print(
            "Could not find the Godot executable: %s" % args.godot_bin,
            file=sys.stderr,
        )
        return 1
    except subprocess.CalledProcessError as exc:
        return exc.returncode

    for source_relative, target_name in STATIC_FILES:
        source_path = project_root / source_relative
        target_path = web_build_dir / target_name
        shutil.copy2(source_path, target_path)

    (web_build_dir / ".nojekyll").touch()
    (web_build_dir / "index.png").unlink(missing_ok=True)

    if not args.skip_package:
        package_directory(web_build_dir, dist_zip)
        print("Created %s" % dist_zip)

    print("Web build ready at %s" % web_build_dir)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
