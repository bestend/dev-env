#!/usr/bin/env bash
set -euo pipefail

./tests/test-dev-image-layout.sh
./tests/test-dependency-update-workflow.sh
for f in scripts/*.sh tests/*.sh; do
  bash -n "$f"
done
python3 -m py_compile scripts/update_dependency_versions.py
python3 -m json.tool .devcontainer/devcontainer.json >/dev/null

if command -v yq >/dev/null 2>&1; then
  yq '.' .github/workflows/docker-publish.yml >/dev/null
  yq '.' .github/workflows/dependency-refresh.yml >/dev/null
else
  python3 - <<'PY'
import yaml
for path in [
    '.github/workflows/docker-publish.yml',
    '.github/workflows/dependency-refresh.yml',
]:
    with open(path) as fh:
        yaml.safe_load(fh)
    print(f'{path} ok')
PY
fi

echo 'static verification ok'
