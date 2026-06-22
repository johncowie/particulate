#!/usr/bin/env python3
"""Bump version across plugin.json and marketplace.json.

Usage:
  bump-version.py patch    # 0.1.0 -> 0.1.1
  bump-version.py minor    # 0.1.0 -> 0.2.0
  bump-version.py major    # 0.1.0 -> 1.0.0
  bump-version.py get      # print current version
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
PLUGIN_JSON = ROOT / ".claude-plugin" / "plugin.json"
MARKETPLACE_JSON = ROOT / ".claude-plugin" / "marketplace.json"


def read_version():
    return json.loads(PLUGIN_JSON.read_text())["version"]


def parse(version):
    m = re.fullmatch(r"(\d+)\.(\d+)\.(\d+)", version)
    if not m:
        raise ValueError(f"Unrecognised version: {version}")
    return int(m[1]), int(m[2]), int(m[3])


def bump(command):
    version = read_version()
    major, minor, patch = parse(version)

    if command == "get":
        print(version)
        return
    elif command == "patch":
        new = f"{major}.{minor}.{patch + 1}"
    elif command == "minor":
        new = f"{major}.{minor + 1}.0"
    elif command == "major":
        new = f"{major + 1}.0.0"
    else:
        raise ValueError(f"Unknown command: {command}")

    plugin = json.loads(PLUGIN_JSON.read_text())
    plugin["version"] = new
    PLUGIN_JSON.write_text(json.dumps(plugin, indent=2) + "\n")

    market = json.loads(MARKETPLACE_JSON.read_text())
    for plugin_entry in market.get("plugins", []):
        if plugin_entry.get("name") == "particulate":
            plugin_entry["source"]["ref"] = f"v{new}"
    MARKETPLACE_JSON.write_text(json.dumps(market, indent=2) + "\n")

    print(new)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(1)
    bump(sys.argv[1])
