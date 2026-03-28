# 올인원 개발용 Docker 이미지

## 포함 구성
- Ubuntu 24.04
- zsh + oh-my-zsh + powerlevel10k
- fzf, zoxide, bat, eza, direnv
- tmux + TPM + resurrect + continuum + yank
- git + delta + lazygit
- Node.js 22, pnpm, yarn, Python 3, pipx, uv
- gh, jq, yq, rg, fd, tree, htop 등
- OpenAI Codex CLI (`@openai/codex`)
- Anthropic Claude Code (`@anthropic-ai/claude-code`)
- code-server
- VS Code Dev Containers 진입점
- 선택형 SSH 서버

## 빠른 시작
```bash
cp .env.example .env
docker compose build dev
docker compose up -d dev
```

## VS Code Dev Containers
- VS Code에서 이 폴더를 열고 Reopen in Container 선택
- 기본 셸은 `zsh`
- 기본 폰트는 `MesloLGS NF` 권장

## code-server
```bash
docker compose --profile code-server up -d code-server
```
접속: `http://localhost:${CODE_SERVER_PORT:-8080}`

### 인증
- 기본은 `CODE_SERVER_AUTH=password`
- `.env` 의 `CODE_SERVER_PASSWORD` 변경 권장

### 확장 사전 설치
이미지 빌드 시 아래 확장을 선설치 시도한다.
- ms-python.python
- ms-python.vscode-pylance
- dbaeumer.vscode-eslint
- esbenp.prettier-vscode
- ms-azuretools.vscode-docker
- eamodio.gitlens
- EditorConfig.EditorConfig

직접 추가 설치 예시:
```bash
code-server --install-extension <extension-id>
```

## SSH
```bash
docker compose --profile ssh up -d ssh
ssh -p 2222 dev@localhost
```

기본 정책:
- root 로그인 금지
- password auth 금지
- key 기반 인증만 허용

### authorized_keys 주입
예:
```bash
docker compose run --rm -e ENABLE_SSHD=true -e AUTHORIZED_KEYS_SOURCE=/workspace/.dev-env-overrides/authorized_keys dev sleep infinity
```
또는 volume mount 로 `$HOME/.ssh/authorized_keys` 제공.

## Codex / Claude 설치 전략
### Codex
- 패키지: `@openai/codex`
- 방식: pinned npm global install
- 이유: Docker 빌드 재현성과 버전 고정이 쉬움

### Claude Code
- 패키지: `@anthropic-ai/claude-code`
- 방식: pinned npm global install
- 이유: native installer 대안보다 Docker 빌드 재현성이 좋음

### 인증 정보
- 이미지에 bake 하지 않음
- 환경변수/volume mount 로 주입
- 필요 시 사용자 홈의 tool config 디렉토리를 외부 volume 으로 유지

## zsh / powerlevel10k / 폰트
- 기본 테마는 `powerlevel10k`
- 아이콘이 정상 표시되려면 **Nerd Font** 필요
- 권장 폰트: `MesloLGS NF`

## override 포인트
둘 중 하나에 사용자 커스텀 설정 추가 가능:
- `/workspace/.dev-env-overrides/.zshrc`
- `~/.dev-env-overrides/.zshrc`

## 테스트
레이아웃 테스트:
```bash
./tests/test-dev-image-layout.sh
```

컨테이너 런타임 테스트(도커 필요):
```bash
./tests/test-dev-image-runtime.sh all-in-one-dev:latest
```

## 주의
- 이 저장소 환경에는 현재 `docker` 바이너리가 없어서 실제 이미지 build/run 검증은 도커가 있는 환경에서 수행해야 한다.
