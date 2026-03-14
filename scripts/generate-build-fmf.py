#!/usr/bin/env python3
"""Generate tmt/build.fmf and update the container.yml matrix from active Fedora releases."""

import re
import sys
from pathlib import Path

import jinja2
import requests

BODHI_URL = "https://bodhi.fedoraproject.org/releases?rows_per_page=100&state=current"
REPO_ROOT = Path(__file__).parent.parent
TEMPLATE_PATH = REPO_ROOT / "tmt" / "build.fmf.j2"
BUILD_FMF_PATH = REPO_ROOT / "tmt" / "build.fmf"
CONTAINER_YML_PATH = REPO_ROOT / ".github" / "workflows" / "container.yml"

# Markers for the matrix block in container.yml
MATRIX_START = "        include:\n"
MATRIX_END = "\n    container:\n"


def get_active_fedora_versions() -> list[int]:
    response = requests.get(BODHI_URL, timeout=30)
    response.raise_for_status()
    releases = response.json().get("releases", [])

    versions = []
    for release in releases:
        name = release.get("name", "")
        match = re.fullmatch(r"F(\d+)", name)
        if match:
            versions.append(int(match.group(1)))

    return sorted(versions)


def render_matrix_include(versions: list[int]) -> str:
    lines = ["        include:\n"]
    for version in versions:
        lines.append(f'          - version: "{version}"\n')
        lines.append(f"            plan: /tmt/build/f{version}\n")
    lines.append('          - version: rawhide\n')
    lines.append('            plan: /tmt/build/rawhide\n')
    return "".join(lines)


def update_container_yml(versions: list[int]) -> None:
    text = CONTAINER_YML_PATH.read_text()
    start_idx = text.index(MATRIX_START)
    end_idx = text.index(MATRIX_END, start_idx)
    new_matrix = render_matrix_include(versions)
    text = text[:start_idx] + new_matrix + text[end_idx:]
    CONTAINER_YML_PATH.write_text(text)
    print(f"Updated matrix: {CONTAINER_YML_PATH}")


def main() -> None:
    versions = get_active_fedora_versions()
    if not versions:
        print("ERROR: No active Fedora releases found from Bodhi API.", file=sys.stderr)
        sys.exit(1)

    print(f"Active Fedora releases: {versions}")

    template_text = TEMPLATE_PATH.read_text()
    template = jinja2.Template(template_text, keep_trailing_newline=True, trim_blocks=True, lstrip_blocks=True)
    output = template.render(versions=versions)
    BUILD_FMF_PATH.write_text(output)
    print(f"Written: {BUILD_FMF_PATH}")

    update_container_yml(versions)


if __name__ == "__main__":
    main()
