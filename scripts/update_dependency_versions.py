#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
import urllib.request
from pathlib import Path
from typing import Callable

ROOT = Path(__file__).resolve().parent.parent
DOCKERFILE = ROOT / "Dockerfile"
ENV_EXAMPLE = ROOT / ".env.example"


def fetch_json(url: str) -> dict | list:
    req = urllib.request.Request(url, headers={"User-Agent": "bestend-dev-env-updater"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def npm_latest(package_name: str) -> str:
    data = fetch_json(f"https://registry.npmjs.org/{package_name}/latest")
    return str(data["version"])


def github_latest_release(owner: str, repo: str) -> str:
    data = fetch_json(f"https://api.github.com/repos/{owner}/{repo}/releases/latest")
    return str(data["tag_name"]).removeprefix("v")


def pypi_latest(package_name: str) -> str:
    data = fetch_json(f"https://pypi.org/pypi/{package_name}/json")
    return str(data["info"]["version"])


def latest_lts_node_major() -> str:
    data = fetch_json("https://nodejs.org/dist/index.json")
    for release in data:
        if release.get("lts"):
            version = str(release["version"]).removeprefix("v")
            return version.split(".", 1)[0]
    raise RuntimeError("Could not determine latest Node.js LTS major")


VERSION_RESOLVERS: dict[str, Callable[[], str]] = {
    "NODE_MAJOR": latest_lts_node_major,
    "PNPM_VERSION": lambda: npm_latest("pnpm"),
    "CODEX_VERSION": lambda: npm_latest("@openai/codex"),
    "CLAUDE_CODE_VERSION": lambda: npm_latest("@anthropic-ai/claude-code"),
    "CODE_SERVER_VERSION": lambda: github_latest_release("coder", "code-server"),
    "UV_VERSION": lambda: pypi_latest("uv"),
    "LAZYGIT_VERSION": lambda: github_latest_release("jesseduffield", "lazygit"),
}


def replace_line_value(text: str, pattern: str, replacement: str) -> str:
    updated, count = re.subn(pattern, replacement, text, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(f"Expected exactly one match for pattern: {pattern}")
    return updated


def update_env_example(text: str, versions: dict[str, str]) -> str:
    for key, value in versions.items():
        text = replace_line_value(text, rf"^{key}=.*$", f"{key}={value}")
    return text


def update_dockerfile(text: str, versions: dict[str, str]) -> str:
    for key, value in versions.items():
        text = replace_line_value(text, rf"^ARG {key}=.*$", f"ARG {key}={value}")
    return text




def main() -> int:
    versions = {key: resolver() for key, resolver in VERSION_RESOLVERS.items()}
    print(json.dumps(versions, indent=2, sort_keys=True))

    env_text = ENV_EXAMPLE.read_text()
    docker_text = DOCKERFILE.read_text()

    new_env = update_env_example(env_text, versions)
    new_docker = update_dockerfile(docker_text, versions)
    changed = False
    if new_env != env_text:
        ENV_EXAMPLE.write_text(new_env)
        changed = True
    if new_docker != docker_text:
        DOCKERFILE.write_text(new_docker)
        changed = True

    print("changed=true" if changed else "changed=false")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
