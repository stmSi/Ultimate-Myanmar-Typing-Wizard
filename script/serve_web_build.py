#!/usr/bin/env python3

from __future__ import annotations

import argparse
import http.server
import mimetypes
import pathlib
import shutil
import socketserver
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Serve the exported Godot Web build from build/web.",
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8000,
        help="Local port to use. Default: 8000.",
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Host/interface to bind. Default: 127.0.0.1.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    project_root = pathlib.Path(__file__).resolve().parent.parent
    web_build_dir = project_root / "build" / "web"
    index_file = web_build_dir / "index.html"

    if not index_file.is_file():
        print(
            "Web build not found at %s.\nExport the Web build first."
            % index_file,
            file=sys.stderr,
        )
        return 1

    mimetypes.add_type("application/wasm", ".wasm")

    class WebBuildHandler(http.server.SimpleHTTPRequestHandler):
        def __init__(self, *handler_args, **handler_kwargs):
            super().__init__(
                *handler_args,
                directory=str(web_build_dir),
                **handler_kwargs,
            )

        def do_GET(self) -> None:
            if "If-Modified-Since" in self.headers:
                self.headers.replace_header("If-Modified-Since", "")
            if "If-None-Match" in self.headers:
                del self.headers["If-None-Match"]
            super().do_GET()

        def do_HEAD(self) -> None:
            if "If-Modified-Since" in self.headers:
                self.headers.replace_header("If-Modified-Since", "")
            if "If-None-Match" in self.headers:
                del self.headers["If-None-Match"]
            super().do_HEAD()

        def end_headers(self) -> None:
            self.send_header("Cache-Control", "no-store, max-age=0")
            self.send_header("Pragma", "no-cache")
            self.send_header("Expires", "0")
            super().end_headers()

        def copyfile(self, source, outputfile) -> None:
            try:
                shutil.copyfileobj(source, outputfile)
            except BrokenPipeError:
                pass

    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer((args.host, args.port), WebBuildHandler) as httpd:
        print("Serving %s" % web_build_dir)
        print("Open http://%s:%d/" % (args.host, args.port))
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
