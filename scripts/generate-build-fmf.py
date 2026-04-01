#!/usr/bin/env python3
"""Generate CI configs and docs from active Fedora releases."""

import sys
from dataclasses import dataclass
from pathlib import Path

import jinja2
from fedora_distro_aliases import get_distro_aliases

REPO_ROOT = Path(__file__).parent.parent

# Templates that use the "versions" context (CI configs)
CI_TEMPLATES = {
    REPO_ROOT / "tmt" / "build.fmf.j2": REPO_ROOT / "tmt" / "build.fmf",
    REPO_ROOT / ".github" / "workflows" / "container.yml.j2": REPO_ROOT / ".github" / "workflows" / "container.yml",
}

# Templates that use the "distros" context (docs)
DOC_TEMPLATES = {
    REPO_ROOT / "docs" / "getting-started.md.j2": REPO_ROOT / "docs" / "getting-started.md",
    REPO_ROOT / "docs" / "uninstalling.md.j2": REPO_ROOT / "docs" / "uninstalling.md",
}

# Map Fedora release states to human-readable labels
STATE_LABELS = {
    "current": None,
    "frozen": "Branched",
    "pending": "Branched",
}


@dataclass
class Distro:
    """A supported distro variant for nix-toolbox."""

    name: str
    tag: str
    label: str | None = None


def get_fedora_releases() -> tuple[list[int], dict[int, str]]:
    """Return sorted unique version numbers and a mapping of version -> state."""
    try:
        aliases = get_distro_aliases()
    except (OSError, ValueError) as exc:
        print(f"Failed to query active Fedora releases: {exc}", file=sys.stderr)
        sys.exit(1)

    versions: list[int] = []
    states: dict[int, str] = {}
    for distro in aliases.get("fedora-branched", []):
        version = distro.get("version_number")
        if version and version.isdigit():
            v = int(version)
            if v not in states:
                versions.append(v)
            states[v] = distro.get("state", "")

    return sorted(versions), states


def build_distro_list(versions: list[int], states: dict[int, str]) -> list[dict]:
    """Build the list of supported distros from Fedora versions."""
    stable_versions = [v for v in versions if states.get(v) == "current"]
    latest_stable = max(stable_versions) if stable_versions else max(versions)
    distros = []

    for version in versions:
        state = states.get(version, "")
        if version == latest_stable:
            label = "latest"
        else:
            label = STATE_LABELS.get(state)

        distros.append(Distro(
            name=f"Fedora {version}",
            tag=str(version),
            label=label,
        ))

    distros.append(Distro(name="Fedora Rawhide", tag="rawhide", label="Development"))

    return [d.__dict__ for d in distros]


def main() -> None:
    versions, states = get_fedora_releases()
    if not versions:
        print("ERROR: No active Fedora releases found.", file=sys.stderr)
        sys.exit(1)

    print(f"Active Fedora releases: {versions}")

    distros = build_distro_list(versions, states)
    stable_versions = [v for v in versions if states.get(v) == "current"]
    latest_stable = max(stable_versions) if stable_versions else max(versions)

    for template_path, output_path in CI_TEMPLATES.items():
        render_template(template_path, output_path, {"versions": versions})

    doc_context = {
        "distros": distros,
        "oldest": str(versions[0]),
        "latest": str(latest_stable),
    }
    for template_path, output_path in DOC_TEMPLATES.items():
        render_template(template_path, output_path, doc_context)


def render_template(template_path: Path, output_path: Path, context: dict) -> None:
    template_text = template_path.read_text()
    template = jinja2.Template(template_text, keep_trailing_newline=True, trim_blocks=True, lstrip_blocks=True)
    output = template.render(**context)
    output_path.write_text(output)
    print(f"Written: {output_path}")


if __name__ == "__main__":
    main()
