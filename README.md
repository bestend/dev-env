# dev-env

올인원 개발용 Docker 환경 레포입니다.

포함 항목:
- Ubuntu 24.04 기반 이미지
- zsh + oh-my-zsh + powerlevel10k
- fzf, zoxide, bat, eza, direnv
- tmux + TPM + resurrect + continuum + yank
- Node.js 22, pnpm, yarn, Python 3, uv, pipx
- gh, ripgrep, fd, jq, yq, tree, htop 등
- OpenAI Codex CLI
- Anthropic Claude Code
- code-server
- 선택형 SSH 서버
- VS Code Dev Containers 설정

## 빠른 시작

```bash
cp .env.example .env
./tests/test-dev-image-layout.sh
```

빌드:

```bash
docker build -t bestend/dev-env:local .
```

개발 컨테이너:

```bash
docker compose up -d dev
```

SSH 프로필:

```bash
docker compose --profile ssh up -d ssh
```

code-server 프로필:

```bash
docker compose --profile code-server up -d code-server
```

## 검증

정적 검증:

```bash
./tests/test-dev-image-layout.sh
bash -n scripts/*.sh tests/*.sh
python3 -m json.tool .devcontainer/devcontainer.json >/dev/null
```

런타임 검증:

```bash
./tests/test-dev-image-runtime.sh bestend/dev-env:local
./tests/test-dev-image-services.sh bestend/dev-env:local
```

## Docker Hub 배포

`main` 브랜치에 push 되면 GitHub Actions가 먼저 정적 검증 + 이미지 빌드 + 런타임/서비스 테스트를 수행하고, 모두 통과한 경우에만 Docker Hub로 푸시합니다.

태그 규칙:
- `YYYYMMDDHH-<shortsha>`
- `latest`

예시:
- `docker.io/bestend/dev-env:2026032811-abc1234`
- `docker.io/bestend/dev-env:latest`

### 필요한 GitHub Secrets
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

## 참고
- code-server 확장 사전설치 중 `ms-python.vscode-pylance` 는 현재 레지스트리에서 찾지 못할 수 있습니다.
- 기본 powerlevel10k 아이콘 표시에는 Nerd Font가 필요합니다. 권장 폰트: `MesloLGS NF`.
