#!/usr/bin/env python3
"""Generate tmt/build.fmf and container.yml from active Fedora releases."""

import sys
from pathlib import Path

import jinja2
from fedora_distro_aliases import get_distro_aliases

REPO_ROOT = Path(__file__).parent.parent

TEMPLATES = {
    REPO_ROOT / "tmt" / "build.fmf.j2": REPO_ROOT / "tmt" / "build.fmf",
    REPO_ROOT / ".github" / "workflows" / "container.yml.j2": REPO_ROOT / ".github" / "workflows" / "container.yml",
}


def get_active_fedora_versions() -> list[int]:
    try:
        aliases = get_distro_aliases()
    except (OSError, ValueError) as exc:
        print(f"Failed to query active Fedora releases: {exc}", file=sys.stderr)
        sys.exit(1)

    versions = []
    for distro in aliases.get("fedora-stable", []):
        version = distro.get("version_number")
        if version and version.isdigit():
            versions.append(int(version))

    return sorted(versions)


def render_template(template_path: Path, output_path: Path, context: dict) -> None:
    template_text = template_path.read_text()
    template = jinja2.Template(template_text, keep_trailing_newline=True, trim_blocks=True, lstrip_blocks=True)
    output = template.render(**context)
    output_path.write_text(output)
    print(f"Written: {output_path}")


def main() -> None:
    versions = get_active_fedora_versions()
    if not versions:
        print("ERROR: No active Fedora releases found.", file=sys.stderr)
        sys.exit(1)

    print(f"Active Fedora releases: {versions}")

    context = {"versions": versions}
    for template_path, output_path in TEMPLATES.items():
        render_template(template_path, output_path, context)


if __name__ == "__main__":
    main()
