from __future__ import annotations

import html
import os
import re
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path
from string import Template

ROOT = Path(__file__).resolve().parents[1]
PROJECT_DIR = ROOT / "Project"
DIST_DIR = ROOT / "dist"
LOVEJS_BASE = (
    "https://raw.githubusercontent.com/"
    "TannerRogalsky/love.js/6fa910c2a28936c3ec4eaafb014405a765382e08/"
    "release-compatibility"
)

HTML_TEMPLATE = Template(
    """<!doctype html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
  <title>$title</title>
  <style>
    :root {
      color-scheme: dark;
      --bg: #0b1220;
      --panel: #121a2b;
      --accent: #8ec3e3;
      --text: #e6eef8;
      --muted: #9fb3c8;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      background:
        radial-gradient(circle at top, #1a2740 0%, var(--bg) 55%),
        var(--bg);
      color: var(--text);
      font-family: Arial, Helvetica, sans-serif;
    }
    main {
      width: min(100%, 980px);
      padding: 24px;
      text-align: center;
    }
    .frame {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 16px;
      border-radius: 18px;
      background: rgba(18, 26, 43, 0.92);
      box-shadow: 0 16px 48px rgba(0, 0, 0, 0.35);
    }
    canvas {
      max-width: 100%;
      height: auto;
      border-radius: 12px;
      image-rendering: pixelated;
      image-rendering: crisp-edges;
    }
    #canvas { display: none; }
    p {
      margin-top: 12px;
      color: var(--muted);
      font-size: 0.95rem;
    }
    a { color: var(--accent); }
  </style>
</head>
<body>
  <main>
    <h1>$title</h1>
    <div class=\"frame\">
      <canvas id=\"canvas\" width=\"$width\" height=\"$height\" oncontextmenu=\"event.preventDefault()\"></canvas>
      <canvas id=\"loadingCanvas\" width=\"$width\" height=\"$height\" oncontextmenu=\"event.preventDefault()\"></canvas>
    </div>
    <p>Built for GitHub Pages with <a href=\"https://github.com/TannerRogalsky/love.js\">Love.js</a>.</p>
  </main>

  <script>
    const loadingCanvas = document.getElementById('loadingCanvas');
    const loadingContext = loadingCanvas.getContext('2d');

    function drawLoadingText(text) {
      const canvas = loadingContext.canvas;
      loadingContext.fillStyle = '#8ec3e3';
      loadingContext.fillRect(0, 0, canvas.width, canvas.height);
      loadingContext.fillStyle = '#0b5675';
      loadingContext.textAlign = 'center';
      loadingContext.font = '28px Arial';
      loadingContext.fillText(text, canvas.width / 2, canvas.height / 2);
      loadingContext.font = '18px Arial';
      loadingContext.fillText('Powered by LÖVE + Emscripten', canvas.width / 2, canvas.height / 2 - 50);
    }

    window.addEventListener('keydown', function (event) {
      if ([32, 37, 38, 39, 40].includes(event.keyCode)) {
        event.preventDefault();
      }
    }, false);

    const Module = {
      arguments: ['./'],
      print: console.log.bind(console),
      printErr: console.error.bind(console),
      canvas: (function () {
        const canvas = document.getElementById('canvas');
        canvas.addEventListener('webglcontextlost', function (event) {
          alert('WebGL context lost. Please reload the page.');
          event.preventDefault();
        }, false);
        return canvas;
      })(),
      didSyncFS: false,
      totalDependencies: 0,
      remainingDependencies: 0,
      setStatus: function (text) {
        if (text) {
          drawLoadingText(text);
        } else if (Module.didSyncFS && Module.remainingDependencies === 0) {
          Module.callMain(Module.arguments);
          loadingCanvas.style.display = 'none';
          document.getElementById('canvas').style.display = 'block';
        }
      },
      monitorRunDependencies: function (left) {
        this.remainingDependencies = left;
        this.totalDependencies = Math.max(this.totalDependencies, left);
        const done = this.totalDependencies - left;
        this.setStatus(left ? `Preparing... (${done}/${this.totalDependencies})` : 'All downloads complete.');
      }
    };

    Module.setStatus('Downloading...');
    window.onerror = function () {
      Module.setStatus('A runtime error occurred. Check the browser console for details.');
    };
  </script>
  <script src=\"game.js\"></script>
  <script async src=\"love.js\"></script>
</body>
</html>
"""
)


def parse_conf_value(pattern: str, default: str) -> str:
    conf_path = PROJECT_DIR / "conf.lua"
    if not conf_path.exists():
        return default

    contents = conf_path.read_text(encoding="utf-8")
    match = re.search(pattern, contents)
    return match.group(1) if match else default



def get_title() -> str:
    return parse_conf_value(r't\.title\s*=\s*["\'](.+?)["\']', ROOT.name)



def get_canvas_size() -> tuple[str, str]:
    width = parse_conf_value(r"t\.window\.width\s*=\s*(\d+)", "800")
    height = parse_conf_value(r"t\.window\.height\s*=\s*(\d+)", "600")
    return width, height



def download_file(url: str, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url) as response:
        destination.write_bytes(response.read())



def find_file_packager() -> Path:
    candidates: list[Path] = []

    emsdk = os.environ.get("EMSDK")
    if emsdk:
        candidates.append(Path(emsdk) / "upstream" / "emscripten" / "tools" / "file_packager.py")

    emscripten = os.environ.get("EMSCRIPTEN")
    if emscripten:
        em_path = Path(emscripten)
        candidates.extend(
            [
                em_path / "tools" / "file_packager.py",
                em_path / "file_packager.py",
            ]
        )

    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError(
        "Could not find Emscripten's file_packager.py. "
        "Install EMSDK and ensure the EMSDK or EMSCRIPTEN environment variable is available."
    )



def build_game_data() -> None:
    file_packager = find_file_packager()
    command = [
        sys.executable,
        str(file_packager),
        str(DIST_DIR / "game.data"),
        "--preload",
        f"{PROJECT_DIR}@/",
        f"--js-output={DIST_DIR / 'game.js'}",
    ]
    subprocess.run(command, check=True, cwd=ROOT)



def prepare_dist() -> None:
    if not PROJECT_DIR.exists():
        raise FileNotFoundError(f"Missing game source folder: {PROJECT_DIR}")

    if DIST_DIR.exists():
        shutil.rmtree(DIST_DIR)
    DIST_DIR.mkdir(parents=True, exist_ok=True)

    title = html.escape(get_title())
    width, height = get_canvas_size()
    index_html = HTML_TEMPLATE.safe_substitute(title=title, width=width, height=height)
    (DIST_DIR / "index.html").write_text(index_html, encoding="utf-8")
    (DIST_DIR / ".nojekyll").write_text("", encoding="utf-8")

    download_file(f"{LOVEJS_BASE}/love.js", DIST_DIR / "love.js")
    download_file(f"{LOVEJS_BASE}/love.js.mem", DIST_DIR / "love.js.mem")



def main() -> int:
    prepare_dist()
    build_game_data()
    print(f"Love.js site generated in: {DIST_DIR}")
    return 0



if __name__ == "__main__":
    raise SystemExit(main())
