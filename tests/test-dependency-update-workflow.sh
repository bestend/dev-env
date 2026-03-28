#!/usr/bin/env bash
set -euo pipefail

test -f scripts/update_dependency_versions.py
python3 -m py_compile scripts/update_dependency_versions.py

grep -q "cron: '0 17 \* \* \*'" .github/workflows/dependency-refresh.yml
grep -q 'actions: write' .github/workflows/dependency-refresh.yml
grep -q 'contents: write' .github/workflows/dependency-refresh.yml
grep -q 'scripts/update_dependency_versions.py' .github/workflows/dependency-refresh.yml
grep -q 'gh workflow run docker-publish.yml' .github/workflows/dependency-refresh.yml

echo 'dependency refresh workflow test passed'
