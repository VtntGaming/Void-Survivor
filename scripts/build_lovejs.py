from __future__ import annotations

import html
import json
import os
import re
import shutil
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
  <link rel=\"icon\" href=\"data:,\">
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

    var Module = window.Module || {};
    Object.assign(Module, {
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
    });
    window.Module = Module;

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



def build_game_data() -> None:
    """Pack Project/ into game.data + game.js compatible with old Love.js runtime."""
    data_path = DIST_DIR / "game.data"
    js_path = DIST_DIR / "game.js"

    # Collect all files under Project/
    files_meta: list[dict] = []
    offset = 0

    with open(data_path, "wb") as data_file:
        for root, _dirs, filenames in sorted(os.walk(PROJECT_DIR)):
            for fname in sorted(filenames):
                src = Path(root) / fname
                rel = src.relative_to(PROJECT_DIR).as_posix()
                content = src.read_bytes()
                data_file.write(content)
                files_meta.append({
                    "filename": "/" + rel,
                    "start": offset,
                    "end": offset + len(content),
                })
                offset += len(content)

    # Collect unique directory paths to create
    dirs_to_create: list[tuple[str, str]] = []
    seen_dirs: set[str] = set()
    for fm in files_meta:
        parts = fm["filename"].lstrip("/").split("/")
        for i in range(len(parts) - 1):
            parent = "/" + "/".join(parts[:i]) if i > 0 else "/"
            child = parts[i]
            key = parent + "/" + child
            if key not in seen_dirs:
                seen_dirs.add(key)
                dirs_to_create.append((parent, child))

    # Build game.js — old Love.js compatible (no async, no Module parameter)
    js_lines = []
    js_lines.append("var Module = typeof Module !== 'undefined' ? Module : {};")
    js_lines.append("if (!Module['expectedDataFileDownloads']) Module['expectedDataFileDownloads'] = 0;")
    js_lines.append("Module['expectedDataFileDownloads']++;")
    js_lines.append("(function() {")
    js_lines.append("  var PACKAGE_NAME = 'game.data';")
    js_lines.append("  var REMOTE_PACKAGE_NAME = 'game.data';")
    js_lines.append("  var PACKAGE_PATH = '';")
    js_lines.append("  if (typeof window === 'object') {")
    js_lines.append("    PACKAGE_PATH = window['encodeURIComponent'](window.location.pathname.substring(0, window.location.pathname.lastIndexOf('/')) + '/');")
    js_lines.append("  }")
    js_lines.append("  var REMOTE_PACKAGE_BASE = 'game.data';")
    js_lines.append("  var REMOTE_PACKAGE_NAME = Module['locateFile'] ? Module['locateFile'](REMOTE_PACKAGE_BASE, '') : REMOTE_PACKAGE_BASE;")
    js_lines.append(f"  var REMOTE_PACKAGE_SIZE = {offset};")
    js_lines.append(f"  var metadata = {json.dumps({'files': files_meta})};")
    js_lines.append("")
    js_lines.append("  function fetchRemotePackage(packageName, packageSize, callback, errback) {")
    js_lines.append("    var xhr = new XMLHttpRequest();")
    js_lines.append("    xhr.open('GET', packageName, true);")
    js_lines.append("    xhr.responseType = 'arraybuffer';")
    js_lines.append("    xhr.onprogress = function(event) {")
    js_lines.append("      var url = packageName;")
    js_lines.append("      var size = packageSize;")
    js_lines.append("      if (event.total) size = event.total;")
    js_lines.append("      if (event.loaded) {")
    js_lines.append("        if (!Module['dataFileDownloads']) Module['dataFileDownloads'] = {};")
    js_lines.append("        Module['dataFileDownloads'][url] = { loaded: event.loaded, total: size };")
    js_lines.append("        var total = 0, loaded = 0, num = 0;")
    js_lines.append("        for (var d in Module['dataFileDownloads']) {")
    js_lines.append("          var data = Module['dataFileDownloads'][d];")
    js_lines.append("          total += data.total; loaded += data.loaded; num++;")
    js_lines.append("        }")
    js_lines.append("        if (Module['setStatus']) Module['setStatus']('Downloading data... (' + loaded + '/' + total + ')');")
    js_lines.append("      }")
    js_lines.append("    };")
    js_lines.append("    xhr.onerror = function(event) { if (errback) errback(); else throw new Error('NetworkError for: ' + packageName); };")
    js_lines.append("    xhr.onload = function(event) {")
    js_lines.append("      if (xhr.status == 200 || xhr.status == 304 || xhr.status == 206 || (xhr.status == 0 && xhr.response)) {")
    js_lines.append("        callback(xhr.response);")
    js_lines.append("      } else {")
    js_lines.append("        throw new Error(xhr.statusText + ' : ' + xhr.responseURL);")
    js_lines.append("      }")
    js_lines.append("    };")
    js_lines.append("    xhr.send(null);")
    js_lines.append("  }")
    js_lines.append("")
    js_lines.append("  function processPackageData(arrayBuffer) {")
    js_lines.append("    Module['finishedDataFileDownloads']++;")
    js_lines.append("    var byteArray = new Uint8Array(arrayBuffer);")
    js_lines.append("    var files = metadata['files'];")
    js_lines.append("    for (var i = 0; i < files.length; ++i) {")
    js_lines.append("      var name = files[i]['filename'];")
    js_lines.append("      var data = byteArray.subarray(files[i]['start'], files[i]['end']);")
    js_lines.append("      Module['FS_createDataFile'](name, null, data, true, true, true);")
    js_lines.append("    }")
    js_lines.append("    Module['removeRunDependency']('datafile_game.data');")
    js_lines.append("  }")
    js_lines.append("")
    js_lines.append("  function loadPackage() {")
    # Create directories
    for parent, child in dirs_to_create:
        js_lines.append(f"    Module['FS_createPath']({json.dumps(parent)}, {json.dumps(child)}, true, true);")
    js_lines.append("    Module['addRunDependency']('datafile_game.data');")
    js_lines.append("    if (!Module['preloadResults']) Module['preloadResults'] = {};")
    js_lines.append("    Module['preloadResults'][PACKAGE_NAME] = { fromCache: false };")
    js_lines.append("    fetchRemotePackage(REMOTE_PACKAGE_NAME, REMOTE_PACKAGE_SIZE, processPackageData);")
    js_lines.append("  }")
    js_lines.append("")
    js_lines.append("  if (Module['calledRun']) {")
    js_lines.append("    loadPackage();")
    js_lines.append("  } else {")
    js_lines.append("    if (!Module['preRun']) Module['preRun'] = [];")
    js_lines.append("    Module['preRun'].push(loadPackage);")
    js_lines.append("  }")
    js_lines.append("})();")

    js_path.write_text("\n".join(js_lines) + "\n", encoding="utf-8")



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
