# Design: 올인원 개발용 Docker 개발 환경

## 승인된 방향
사용자 승인: 2026-03-28 대화에서 "니가 추천한거 모두 진행" 요청으로 다음 선택을 확정.

- 단일 올인원 개발 이미지
- `powerlevel10k` 기본 테마
- `code-server` 포함
- pinned `@openai/codex` / pinned `@anthropic-ai/claude-code`
- zsh/fzf/tmux/git UX 사전 구성
- dotfiles bake-in + override 가능 구조

## 아키텍처
- `Dockerfile`: 전체 멀티스테이지/단일 산출 이미지
- `scripts/`: 설치 및 설정 스크립트
- `home/`: 기본 dotfiles
- `.devcontainer/`: VS Code Remote Containers 진입점
- `docker-compose.yml`: dev / ssh / code-server profiles
- `tests/`: 레포/컨테이너 스모크 테스트

## 선택지 비교
### A. npm 기반 Codex/Claude 설치 + code-server 포함 + p10k
- 장점: 재현 가능, 버전 pin 용이, 단일 이미지 전략과 궁합 좋음
- 단점: 이미지 크기 증가

### B. 바이너리 혼합 설치
- 장점: 일부 도구는 더 독립적
- 단점: 업데이트/경로 관리 복잡

### C. 도구별 별도 이미지
- 장점: 더 가벼움
- 단점: 사용자 요구와 불일치

## 채택안
A 채택.

## 구현 요약
- Ubuntu 24.04 기반
- dev 사용자 + sudo
- Node LTS, Python, uv, gh
- zsh + oh-my-zsh + powerlevel10k + fzf/zoxide/bat/eza/direnv
- tmux + TPM + resurrect/continuum/yank
- code-server + 사전 설치 확장
- Codex/Claude pinned npm global
- secrets는 env/volume로만 주입

## 테스트 전략
1. 파일/구성 스캐폴딩 테스트
2. docker build 테스트
3. 컨테이너 내부 CLI 가용성 테스트
4. shell/tmux/theme smoke test
5. code-server/extension smoke test
6. secret bake-in 점검
